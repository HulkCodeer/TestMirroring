//
//  PaymentStatusViewController.swift
//  evInfra
//
//  Created by bulacode on 04/07/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import SwiftyJSON
import Material

class PaymentStatusViewController: UIViewController {

    let STATUS_READY = 0
    let STATUS_START = 1
    let STATUS_FINISH = 2
    
    let TIMER_COUNT_NORMAL_TICK = 5 // 30 30초 주기로 충전 상태 가져옴. 시연을 위해 임시 5초
    let TIMER_COUNT_COMPLETE_TICK = 5 // TODO test 위해 10초로 변경. 시그넷 충전기 테스트 후 시간 정할 것.
    
    @IBOutlet weak var lbChargeComment: UILabel!
    @IBOutlet weak var circleView: CircularProgressBar!
    
    @IBOutlet weak var lbChargePower: UILabel!
    @IBOutlet weak var lbChargeSpeed: UILabel!
    @IBOutlet weak var lbChargeFee: UILabel!
    @IBOutlet weak var lbChargeBerry: UILabel!
    @IBOutlet weak var lbChargeTotalFee: UILabel!
    
    @IBOutlet weak var chronometer: Chronometer!

    @IBOutlet weak var btnStopCharging: UIButton!
    @IBOutlet weak var btnStopChargingView: UIView!
    
    @IBOutlet weak var btnUseBerry: UIButton!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var chargingStartTime = ""
    var isStopCharging = false

    var cpId: String = ""
    var connectorId: String = ""
    var chargingStatus = ChargingStatus.init()
    
    // 충전속도 계산
    var preChargingKw: String = ""
    var preUpdateTime: String = ""
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareView()
        prepareNotificationCenter()
        
        requestOpenCharger()
    }
    
    override func viewDidLayoutSubviews() {
        btnSetBorder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startTimer(tick: TIMER_COUNT_NORMAL_TICK)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeTimer()
        chronometer.stop()

        removeNotificationCenter()
    }

    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "충전하기"
        navigationController?.isNavigationBarHidden = false
    }
    
    func prepareView() {
        circleView.labelSize = 60
        circleView.safePercent = 100
        
        btnStopCharging.isEnabled = false
    }
    
    func prepareNotificationCenter() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(requestStatusFromFCM), name: Notification.Name(FCMManager.FCM_REQUEST_PAYMENT_STATUS), object: nil)
    }
   
    func removeNotificationCenter() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: Notification.Name(FCMManager.FCM_REQUEST_PAYMENT_STATUS), object: nil)
    }
    
    func btnSetBorder() {
        let borderColor = UIColor(hex: "#22C1BB")
        let startColor = UIColor(hex: "#2CE0BB").cgColor
        let endColor = UIColor(hex: "#33A2DA").cgColor
        
        btnUseBerry.roundCorners(.allCorners, radius: 20, borderColor: borderColor, borderWidth: 4)
        
        btnStopCharging.setRoundGradient(startColor: startColor, endColor: endColor)
    }
    
    @objc func requestStatusFromFCM(notification: Notification) {
        if let userInfo = notification.userInfo {
            let cmd = userInfo[AnyHashable("cmd")] as! String
            if cmd == "charging_end" {
                self.stopCharging()
            } else {
                let delayTime = DispatchTime.now() + .seconds(1)
                DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                    self.requestChargingStatus()
                })
            }
        }
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    @IBAction func onClickUsePoint(_ sender: Any) {
        let usePointVC = self.storyboard?.instantiateViewController(withIdentifier: "UsePointController") as! UsePointViewController
        self.present(usePointVC, animated: true, completion: nil)
    }
    
    @IBAction func onClickStopCharging(_ sender: Any) {
        showStopChargingDialog()
    }
    
    func showStopChargingDialog() {
        var title = "충전 종료"
        var msg = "확인 버튼을 누르면 충전이 종료됩니다."
        if chargingStatus.status == STATUS_READY {
            title = "충전 취소";
            msg = "확인 버튼을 누르면 충전이 취소됩니다.";
        }
    
        let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in
            self.showProgress()

            self.btnStopCharging.isEnabled = false
            self.btnStopCharging.setTitle("충전 중지 요청중입니다.", for: .disabled)
            self.btnStopCharging.setTitleColor(UIColor(rgb: 0x15435C), for: .disabled)
            self.isStopCharging = true
            
            self.requestStopCharging()
        })
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler:{ (ACTION) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        
        var actions = Array<UIAlertAction>()
        actions.append(ok)
        actions.append(cancel)
        UIAlertController.showAlert(title: title, message: msg, actions: actions)
    }
}

extension PaymentStatusViewController {
    func broadCastFCMPayoad(payload: [AnyHashable: Any]) {
        let cmd = payload["cmd"] as! String
        let time = payload["time"] as! String
        if cmd == "charging_start" {
            self.chargingStartTime = time
            self.chronometer.setBase(base: self.getChargingStartTime())
            self.chronometer.start()
        }
    }
    
    func startTimer(tick : Int) {
        removeTimer()
        var index = 0
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(tick), repeats: true) { (timer) in
            self.requestChargingStatus()
            index = index + 1
        }
        timer.fire()
    }
    
    func removeTimer() {
        timer.invalidate()
        timer = Timer()
    }
    
    // charging id가 있을 경우 충전중인 상태이므로
    // charging id가 없을 경우에만 충전기에 충전 시작을 요청함
    func requestOpenCharger() {
        let chargingId = getChargingId()
        if chargingId.isEmpty {
            showProgress()
            Server.openCharger(cpId: cpId, connectorId: connectorId) { (isSuccess, value) in
                self.hideProgress()
                if isSuccess {
                    let json = JSON(value)
                    self.responseOpenCharger(response: json)
                } else {
                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 충전하기 페이지 종료후 재시도 바랍니다.")
                }
            }
        }
    }
    
    func requestStopCharging() {
        let chargingId = getChargingId()
        if chargingId.isEmpty {
            Snackbar().show(message: "오류가 발생하였습니다. 충전하기 페이지 종료후 재시도 바랍니다.")
        } else {
            Server.stopCharging(chargingId: chargingId) { (isSuccess, value) in
                self.hideProgress()
                if isSuccess {
                    self.responseStop(response: JSON(value))
                } else {
                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 충전하기 페이지 종료후 재시도 바랍니다.")
                }
            }
        }
    }
    
    func requestChargingStatus() {
        let chargingId = getChargingId()
        if !chargingId.isEmpty {
            Server.getChargingStatus(chargingId: chargingId) { (isSuccess, value) in
                self.hideProgress()
                if isSuccess {
                    self.responseChargingStatus(response: JSON(value))
                } else {
                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 충전하기 페이지 종료후 재시도 바랍니다.")
                }
            }
        }
    }
    
    func responseOpenCharger(response: JSON) {
        if response.isEmpty {
            return
        }
        switch (response["code"].stringValue) {
        case "1000":
            lbChargeComment.text = "충전 커넥터를 차량과 연결 후 \n잠시만 기다려 주세요 "
            setChargingId(chargerId: response["charging_id"].stringValue)
        default:
            Snackbar().show(message:response["msg"].stringValue)
        }
    }
    
    func responseChargingStatus(response: JSON) {
        if response.isEmpty {
            return
        }
        updateDataStructAtResponse(response: response)
        
        switch (chargingStatus.resultCode) {
        case 1000:
            if chargingStatus.status == STATUS_FINISH {
                stopCharging()
            } else {
                updateChargingStatus()
            }
        
        default: // error
            Snackbar().show(message: chargingStatus.msg ?? "")
        }
    }

    func updateDataStructAtResponse(response: JSON) {
        chargingStatus.resultCode = response["code"].int ?? 9000
        chargingStatus.status = response["status"].int ?? STATUS_READY
        chargingStatus.cpId = response["cp_id"].string ?? ""
        chargingStatus.startDate = response["s_date"].string ?? ""
        chargingStatus.updateTime = response["u_date"].string ?? ""
        chargingStatus.chargingRate = response["rate"].string ?? "0"
        chargingStatus.chargingKw = response["c_kw"].string ?? "0"
        chargingStatus.usedPoint = response["u_point"].string ?? ""
        chargingStatus.fee = response["fee"].string ?? ""
        chargingStatus.stationName = response["snm"].string ?? ""
        chargingStatus.companyId = response["company_id"].string ?? ""
    }
    
    func responseStop(response: JSON) {
        if response.isEmpty {
            return
        }
        switch (response["code"].stringValue) {
        case "1000":
            startTimer(tick: TIMER_COUNT_COMPLETE_TICK)
            
        case "2003": // CHARGING_CANCEL 충전 하기전에 취소
            Snackbar().show(message: "충전을 취소하였습니다.")
            self.navigationController?.pop()

        default:
            Snackbar().show(message:response["msg"].stringValue)
        }
    }
    
    func setChargingId(chargerId: String) {
        UserDefault().saveString(key: UserDefault.Key.CHARGING_ID, value: chargerId)
    }
    
    func getChargingId() -> String {
        return UserDefault().readString(key: UserDefault.Key.CHARGING_ID)
    }
    
    func showProgress() {
        indicator.isHidden = false
        indicator.startAnimating()
    }
    
    func hideProgress() {
        indicator.stopAnimating()
        indicator.isHidden = true
    }
}

// chronometer
extension PaymentStatusViewController {
    func updateChargingStatus() {
        if let status = chargingStatus.status {
            if status < STATUS_READY || status > STATUS_FINISH {
                return
            }
        }

        // GSC 외에는 충전 중지 할 수 없으므로 충전 중지 버튼 disable
        if let companyId = chargingStatus.companyId {
            if companyId.elementsEqual(CompanyInfo.COMPANY_ID_GSC) {
                if isStopCharging == false {
                    btnStopCharging.isEnabled = true
                }
            } else {
                btnStopCharging.isEnabled = false
            }
        }
        
        // 포인트
        var point = 0.0;
        if let pointStr = chargingStatus.usedPoint, !pointStr.isEmpty {
            lbChargeBerry.text = pointStr.currency() + " B"
            point = Double(pointStr) ?? 0.0
            if point > 0 {
//                mBtnRemovePoint.setVisibility(View.VISIBLE);
//                mBtnUsePoint.setBackground(getResources().getDrawable(R.drawable.btn_selector_gray));
//                mBtnUsePoint.setTextColor(getResources().getColor(R.color.normal_btn_bg_gray));

                btnUseBerry.setTitle("베리 수정하기", for: .normal)
            } else {
//                mBtnRemovePoint.setVisibility(View.GONE);
//                mBtnUsePoint.setBackground(getResources().getDrawable(R.drawable.btn_selector_green));
//                mBtnUsePoint.setTextColor(getResources().getColor(R.color.normal_btn_bg_green));

                btnUseBerry.setTitle("베리 사용하기", for: .normal)
            }
        }
        
        if chargingStatus.status == STATUS_READY {
            lbChargeComment.text = "충전 커넥터를 차량과 연결 후 잠시만 기다려 주세요"
            btnStopCharging.setTitle("충전 취소", for: .normal)
        } else {
            lbChargeComment.text = "충전이 진행중입니다"
            if (btnStopCharging.isEnabled) {
                btnStopCharging.setTitle("충전 종료", for: .normal)
            }
            
            // 충전진행시간
            if chargingStartTime.isEmpty || !chargingStartTime.elementsEqual(chargingStatus.startDate ?? "") {
                chargingStartTime = chargingStatus.startDate ?? ""
            }

            if !chargingStartTime.isEmpty {
                chronometer.setBase(base: getChargingStartTime())
                chronometer.start()
            }
            
            // 충전률
            if let chargingRate = Double(chargingStatus.chargingRate ?? "0") {
                if chargingRate > 0.0 {
                    circleView.setRateProgress(progress: Double(chargingRate))
                }
            }
            
            if let chargingKw = chargingStatus.chargingKw {
                // 충전량
                let chargePower = "\(chargingKw) Kw"
                lbChargePower.text = chargePower

                if let feeStr = chargingStatus.fee {
                    // 충전 요금
                    lbChargeFee.text = feeStr.currency() + " 원"
                    
                    // 총 결제 금액
                    let fee = feeStr.parseDouble() ?? 0.0
                    let totalFee = (fee > point) ? fee - point : 0
                    lbChargeTotalFee.text = String(totalFee).currency() + " 원"
                }
                
                // 충전속도
                if let updateTime = chargingStatus.updateTime {
                    if (!preChargingKw.isEmpty && !preUpdateTime.isEmpty && !preUpdateTime.elementsEqual(updateTime)) {
                        // 시간차이 계산. 충전량 계산. 속도 계산
                        let preDate = Date().toDate(data: preUpdateTime)
                        let updateDate = Date().toDate(data: updateTime)
                        let sec = Double(updateDate?.timeIntervalSince(preDate!) ?? 0)

                        // 충전량 계산
                        let chargingKw = chargingKw.parseDouble()! - self.preChargingKw.parseDouble()!

                        // 속도 계산: 충전량 / 시간 * 3600
                        if (sec > 0 && chargingKw > 0) {
                            let speed = chargingKw / sec * 3600
                            self.lbChargeSpeed.text = "\((speed * 100).rounded() / 100) Kw"
                        }
                    } else {
                        self.lbChargeSpeed.text = "0 Kw"
                    }
                    preChargingKw = chargingStatus.chargingKw ?? ""
                    preUpdateTime = chargingStatus.updateTime ?? ""
                }
            }
        }
    }
    
    func stopCharging() {
        removeTimer()
        chronometer.stop()
        let paymentResultVc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentResultViewController") as! PaymentResultViewController
        var vcArray = self.navigationController?.viewControllers
        vcArray!.removeLast()
        vcArray!.append(paymentResultVc)
        self.navigationController?.setViewControllers(vcArray!, animated: true)
    }
    
    func getChargingStartTime() -> Double {
        let date = Date().toDate(data: chargingStartTime)
        return Double(date!.timeIntervalSince1970)
    }
}

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
import M13Checkbox

class PaymentStatusViewController: UIViewController {

    let STATUS_READY = 0
    let STATUS_START = 1
    let STATUS_FINISH = 2
    
    let TIMER_COUNT_NORMAL_TICK = 5 // 30 30초 주기로 충전 상태 가져옴. 시연을 위해 임시 5초
    let TIMER_COUNT_COMPLETE_TICK = 5 // TODO test 위해 10초로 변경. 시그넷 충전기 테스트 후 시간 정할 것.
    
    
    @IBOutlet weak var lbStationName: UILabel!
    @IBOutlet weak var lbChargeStatus: UILabel!
    @IBOutlet weak var circleView: CircularProgressBar!
    @IBOutlet weak var lbChargeComment: UILabel!
    
    @IBOutlet weak var lbChargePower: UILabel!
    @IBOutlet weak var chronometer: Chronometer!
    @IBOutlet weak var lbChargeSpeed: UILabel!
    
    @IBOutlet weak var viewDiscount: UIView!
    @IBOutlet weak var lbDiscountMsg: UILabel!
    @IBOutlet weak var lbDiscountAmount: UILabel!
    
    @IBOutlet weak var lbSavedPoint: UILabel!
    @IBOutlet weak var lbPreUsePoint: UILabel!
    
    @IBOutlet weak var viewUsePoint: UIView!
    @IBOutlet weak var tfUsePoint: UITextField!
    @IBOutlet weak var btnUsePointAll: UIButton!
    @IBOutlet weak var viewUseAlways: UIView!
    @IBOutlet weak var lbUseAlways: UILabel!
    @IBOutlet weak var cbUseAlways: M13Checkbox!
    
    @IBOutlet weak var lbChargeFee: UILabel!
    @IBOutlet weak var lbChargeBerry: UILabel!
    @IBOutlet weak var lbChargeTotalFee: UILabel!
    
    @IBOutlet weak var viewPayDiscount: UIView!
    @IBOutlet weak var lbPayDiscountMsg: UILabel!
    @IBOutlet weak var lbPayDiscountAmount: UILabel!
    
    @IBOutlet weak var btnStopCharging: UIButton!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet var payResultViewHeight: NSLayoutConstraint!
    @IBOutlet var scrollview_bottom: NSLayoutConstraint!
    var chargingStartTime = ""
    var isStopCharging = false

    var cpId: String = ""
    var connectorId: String = ""
    var chargingStatus = ChargingStatus.init()
    
    // 충전속도 계산
    var preChargingKw: String = ""
    var preUpdateTime: String = ""
    
    var myPoint = 0 // 소유 베리
    var willUsePoint = 0 // 사용예정 베리 (충전 계산 시 적용될 최종 베리)
    var alwaysUsePoint = 0 // 항상 사용할 베리 (베리사용 설정)
    var prevAlwaysUsePoint = 0 // 설정이 변경되었을 경우 되돌릴 설정베리값
    
    var timer = Timer()
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "충전 진행 상태 화면"
        prepareActionBar()
        prepareView()
        prepareTextField()
        prepareNotificationCenter()
        
        requestOpenCharger()
        requestPointInfo()
    }
    
    override func viewDidLayoutSubviews() {
        btnUsePointAll.layer.cornerRadius = 4
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startTimer(tick: TIMER_COUNT_NORMAL_TICK)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeTimer()
        chronometer.stop()

        removeNotificationCenter()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "충전중"
        navigationController?.isNavigationBarHidden = false
    }
    
    func prepareView() {
        let tapTouch = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        view.addGestureRecognizer(tapTouch)
        
        let tapViewUseAlways = UITapGestureRecognizer(target: self, action: #selector(self.handleViewUseAlways))
                                                   
        viewUseAlways.addGestureRecognizer(tapViewUseAlways)
                                                   
        cbUseAlways.boxType = .square
        cbUseAlways.isEnabled = false
        circleView.safePercent = 100
        
        btnStopCharging.isEnabled = false
        btnStopCharging.layer.backgroundColor = UIColor(named: "background-disabled")!.cgColor
        btnStopCharging.setTitleColor(UIColor(named: "content-disabled")!, for: .normal)
        
        tfUsePoint.clearButtonMode = .whileEditing
        tfUsePoint.layer.cornerRadius = 6
        tfUsePoint.layer.masksToBounds = true
        tfUsePoint.layer.borderColor = UIColor(named: "content-disabled")?.cgColor
        tfUsePoint.layer.borderWidth = 1.0
    }
    
    func prepareNotificationCenter() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(requestStatusFromFCM), name: Notification.Name(FCMManager.FCM_REQUEST_PAYMENT_STATUS), object: nil)
    }
   
    func removeNotificationCenter() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: Notification.Name(FCMManager.FCM_REQUEST_PAYMENT_STATUS), object: nil)
    }
    
    // MARK: - KeyBoardHeight
    @objc func keyboardWillShow(_ notification: Notification) {
        var keyboardHeight: CGFloat = 0
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height  + CGFloat(16.0)
        }
        self.scrollview_bottom.constant = keyboardHeight - self.btnStopCharging.frame.height
        self.tfUsePoint.layer.masksToBounds = true
        self.tfUsePoint.layer.borderColor = UIColor(named: "content-primary")?.cgColor
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.scrollview_bottom.constant = 0
        self.tfUsePoint.layer.masksToBounds = false
        self.tfUsePoint.layer.borderColor = UIColor(named: "content-disabled")?.cgColor
        if let point = Int(tfUsePoint.text! as String) {
            savePoint(point: point)
        }
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
    fileprivate func handleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc
    fileprivate func handleViewUseAlways(recognizer: UITapGestureRecognizer) {
        var preUsePoint = willUsePoint
        if cbUseAlways.checkState == .checked {
            preUsePoint = prevAlwaysUsePoint
        }
        
        Server.setUsePoint(usePoint: preUsePoint, useNow: false) {
            (isSuccess, value) in
            let json = JSON(value)
            self.responseSetUsePoint(response: json)
        }
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    @IBAction func onClickUseAll(_ sender: Any) {
        tfUsePoint.text = String(myPoint)
        savePoint(point: myPoint)
    }
    
    @IBAction func onClickStopCharging(_ sender: Any) {
        showStopChargingDialog()
    }
    
    func showStopChargingDialog() {
        var title = "충전 종료 및 결제하기"
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
    
    func savePoint(point: Int) {
        if point != willUsePoint && point >= 0 {
            Server.usePoint(point: point) { (isSuccess, value) in
                if isSuccess {
                    let json = JSON(value)
                    self.responseUsePoint(response: json)
                } else {
                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료 후 재시도 바랍니다.")
                }
            }
        }
    }
    
    func requestPointInfo() {
        Server.getPoint() { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json.isEmpty {
                    return
                }
                switch (json["code"].stringValue) {
                case "1000":
                    var totalPoint = json["point"].intValue
                    var usePoint = json["use_point"].intValue
                    if totalPoint < 0 {
                        totalPoint = 0
                    }
                    self.myPoint = totalPoint
                    self.lbSavedPoint.text = "\(String(totalPoint).currency()) 베리"
                    
                    if usePoint < 0 {
                        usePoint = self.myPoint
                    }
                    self.willUsePoint = usePoint
                    self.alwaysUsePoint = usePoint
                    self.prevAlwaysUsePoint = usePoint
                    
                    self.updateBerryUse(point: self.willUsePoint)
                    
                default:
                    Snackbar().show(message:json["msg"].stringValue)
                }
            }
        }
    }
    
    // charging id가 있을 경우 충전중인 상태이므로
    // charging id가 없을 경우에만 충전기에 충전 시작을 요청함
    func requestOpenCharger() {
        let chargingId = getChargingId()
        if chargingId.isEmpty {
            showProgress()
            lbChargeStatus.text = "충전 요청중"
            lbChargeComment.text = "충전 요청중 입니다.\n잠시만 기다려 주세요."
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
    
    func responseSetUsePoint(response: JSON) {
        if response.isEmpty {
            return
        }
        if response["code"].stringValue == "1000" {
            let point = response["use_point"].stringValue
            alwaysUsePoint = Int(point as String)!
            updateBerryUse(point: willUsePoint)
        }
    }
    
    func responseUsePoint(response: JSON) {
        if response.isEmpty {
            return
        }
        if response["code"].stringValue == "1000" {
            let point = response["point"].stringValue
            willUsePoint = Int(point as String)!
            updateBerryUse(point: willUsePoint)
        }
    }
    
    func responseOpenCharger(response: JSON) {
        if response.isEmpty {
            return
        }
        switch (response["code"].stringValue) {
        case "1000":
            lbChargeComment.text = "충전 커넥터를 차량과 연결 후\n잠시만 기다려 주세요 "
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
        chargingStatus.discountAmt = response["discount_amt"].string ?? ""
        chargingStatus.discountMsg = response["discount_msg"].string ?? ""
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

extension PaymentStatusViewController {
    func updateChargingStatus() {
        if let status = chargingStatus.status {
            if status < STATUS_READY || status > STATUS_FINISH {
                return
            }
        }
        
        if let stationName = chargingStatus.stationName {
            lbStationName.text = stationName
        }
        
        if let companyId = chargingStatus.companyId {
            // GSC 외에는 충전 중지 할 수 없으므로 충전 중지 버튼 disable
            if companyId.elementsEqual(CompanyInfo.COMPANY_ID_GSC) {
                if isStopCharging == false {
                    btnStopCharging.isEnabled = true
                    
                    btnStopCharging.layer.backgroundColor = UIColor(named: "background-positive")!.cgColor
                    btnStopCharging.setTitleColor(UIColor(named: "content-primary")!, for: .normal)
                }
            } else if companyId.elementsEqual(CompanyInfo.COMPANY_ID_KEPCO) {
                btnStopCharging.isUserInteractionEnabled = false
                btnStopCharging.backgroundColor = UIColor(named: "background-disabled")
                btnStopCharging.setTitleColor(UIColor(named: "content-disabled"), for: .normal)
                if MemberManager.shared.isPartnershipClient(clientId: 23) { // 한전&SK -> 포인트사용 block
                    viewUsePoint.isHidden = true
                }
            }
        }
        
        if chargingStatus.status == STATUS_READY {
            lbChargeStatus.text = "충전 대기"
            lbChargeComment.text = "충전 커넥터를 차량과 연결 후\n잠시만 기다려 주세요"
            btnStopCharging.setTitle("충전 취소", for: .normal)
        } else {
            lbChargeStatus.textColor = UIColor(named: "content-positive")
            lbChargeComment.text = "충전중"
            btnStopCharging.setTitle("충전 종료 및 결제하기", for: .normal)
                      
            
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
                lbChargeStatus.text = "\(Int(chargingRate))%"
            }
            
            // 포인트
            var point = 0.0
            if let pointStr = chargingStatus.usedPoint, !pointStr.isEmpty {
                lbPreUsePoint.text = "\(pointStr.currency()) 베리"
                point = Double(pointStr) ?? 0.0
                willUsePoint = Int(point)
                updateBerryUse(point: willUsePoint)
            }
            
            if let chargingKw = chargingStatus.chargingKw {
                // 충전량
                let chargePower = "\(chargingKw)kWh"
                lbChargePower.text = chargePower

                var discountAmt = 0.0
                if let discountMsg = chargingStatus.discountMsg, !discountMsg.isEmpty {
                    lbDiscountMsg.text = discountMsg
                    
                    discountAmt = Double(chargingStatus.discountAmt!) ?? 0.0
                    var discountStr = chargingStatus.discountAmt!.currency()
                    if discountAmt != 0 {
                        discountStr = "- " + discountStr
                    }
                    lbDiscountAmount.text = "\(discountStr) 원"
                    lbPayDiscountAmount.text = "\(discountStr) 원"
                    lbPayDiscountMsg.text = discountMsg
                } else {
                    viewDiscount.isHidden = true
                    viewPayDiscount.isHidden = true
                    payResultViewHeight.constant = 263 //315 - 52
                }
                
                if let feeStr = chargingStatus.fee {
                    // 충전 요금
                    lbChargeFee.text = feeStr.currency() + " 원"
                    
                    // 총 결제 금액
                    let fee = feeStr.parseDouble() ?? 0.0
                    var totalFee = (fee > discountAmt) ? fee - discountAmt : 0
                    point = Double((willUsePoint > myPoint) ? myPoint : willUsePoint)
                    if totalFee > point {
                        totalFee -= point
                    } else {
                        point = totalFee
                        totalFee = 0
                    }
                    lbChargeTotalFee.text = String(totalFee).currency()
                    var berryStr = String(point).currency()
                    if point != 0 {
                        berryStr = "- " + berryStr
                    }
                    lbChargeBerry.text = "\(berryStr) 베리"
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
                    }
                    preChargingKw = chargingStatus.chargingKw ?? preChargingKw
                    preUpdateTime = chargingStatus.updateTime ?? preUpdateTime
                }
            }
        }
    }
    
    func updateBerryUse(point: Int) {
        if point == myPoint {
            btnUsePointAll.layer.backgroundColor = UIColor(named: "background-disabled")?.cgColor
            btnUsePointAll.setTitleColor(UIColor(named: "content-disabled"), for: .normal)
        } else {
            btnUsePointAll.layer.backgroundColor = UIColor(named: "background-secondary")?.cgColor
            btnUsePointAll.setTitleColor(UIColor(named: "content-primary"), for: .normal)
        }
        
        lbPreUsePoint.text = "\(String(point).currency()) 베리"
        if point != alwaysUsePoint { // 설정베리와 사용베리가 다른경우
            lbUseAlways.textColor = UIColor(named: "content-primary")
            cbUseAlways.checkState = .unchecked
            viewUseAlways.isUserInteractionEnabled = true
        } else {
            if alwaysUsePoint == prevAlwaysUsePoint { // 설정베리가 변경된적 없는 경우
                lbUseAlways.textColor = UIColor(named: "content-tertiary")
                viewUseAlways.isUserInteractionEnabled = false
                
                if prevAlwaysUsePoint == 0 {
                    cbUseAlways.checkState = .unchecked
                } else {
                    cbUseAlways.checkState = .checked
                }
            } else { // 설정베리가 변경되어 사용베리와 다른 경우
                lbUseAlways.textColor = UIColor(named: "content-primary")
                cbUseAlways.checkState = .checked
                viewUseAlways.isUserInteractionEnabled = true
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

extension PaymentStatusViewController: UITextFieldDelegate {
    func prepareTextField() {
        self.tfUsePoint.delegate = self
        self.tfUsePoint.keyboardType = .numberPad
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length > 5 {
            tfUsePoint.borderColor = UIColor(named: "content-negative")
            Snackbar().show(message: "베리 입력은 100,000원을 초과하여 입력하실 수 없습니다.")
            return false
        }
        
        tfUsePoint.borderColor = UIColor(named: "content-disabled")
        if newString.length > 0 {
            if let point = Int(newString as String) {
                if point > myPoint { // 내가 보유한 포인트보다 큰 수를 입력한 경우 내 포인트를 입력
                    tfUsePoint.borderColor = UIColor(named: "content-negative")
                    Snackbar().show(message: "사용 베리는 보유 베리보다 많이 입력할 수 없습니다.")
                    return false
                } else {
                    tfUsePoint.borderColor = UIColor(named: "content-primary")
                    if newString.hasPrefix("0"){
                        tfUsePoint.text = String(point)
                        return false
                    }
                    return true
                }
            } else {
                return false // 숫자 이외의 문자 입력받지 않음
            }
        }
        return true
    }
}

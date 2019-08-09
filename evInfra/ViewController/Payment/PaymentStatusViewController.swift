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

    let STATUS_READY = 0;
    let STATUS_START = 1;
    let STATUS_FINISH = 2;
    
    let TIMER_COUNT_NORMAL_TICK = 60 * 2;
    let TIMER_COUNT_COMPLETE_TICK = 10; // TODO test 위해 10초로 변경. 시그넷 충전기 테스트 후 시간 정할 것.
    
    

    @IBOutlet weak var lbChargeComment: UILabel!
    @IBOutlet weak var mCircleView: CircularProgressBar!
    
    
    @IBOutlet weak var ivChargePower: UIImageView!
    @IBOutlet weak var lbChargePowerTitle: UILabel!
    @IBOutlet weak var lbChargePower: UILabel!
    @IBOutlet weak var ivChargeTime: UIImageView!
    @IBOutlet weak var mChronometer: Chronometer!
    
    @IBOutlet weak var lbChargeTimeTitle: UILabel!

    
    @IBOutlet weak var mUserControlBtn: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    let appDelegate =  UIApplication.shared.delegate as! AppDelegate
    var chargingStartTime = "";
    let defaults = UserDefault()
    
    var point: Int = 0
    var cpId: String = ""
    var connectorId: String = ""
    var mChargingStatus = ChargingStatus.init()
    
    var mTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.paymentStatusController = self
        prepareActionBar()
        prepareView()
        prepareNotificationCenter()
        requestOpenCharger()
        startTimer(tick: TIMER_COUNT_NORMAL_TICK)
//        self.progressBar.setProgress(to: 1, withAnimation: true)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        mChronometer.stop()
        mTimer.invalidate()
        mTimer = Timer()
        removeNotificationCenter()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "충전하기"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareView(){

        self.ivChargeTime.image = UIImage(named: "ic_time")?.withRenderingMode(.alwaysTemplate)
        self.ivChargeTime.tintColor = UIColor(rgb: 0x585858)
        self.lbChargeTimeTitle.textColor = UIColor(rgb: 0x585858)
        self.mChronometer.textColor = UIColor(rgb: 0x15435C)
        
        self.ivChargePower.image = UIImage(named: "ic_charge_quantity")?.withRenderingMode(.alwaysTemplate)
        self.ivChargePower.tintColor = UIColor(rgb: 0x585858)
        self.lbChargePowerTitle.textColor = UIColor(rgb: 0x585858)
        self.lbChargePower.textColor = UIColor(rgb: 0x15435C)
        
        self.mCircleView.labelSize = 60
        self.mCircleView.safePercent = 100
    }
    func prepareNotificationCenter(){
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(requestStatusFromFCM), name: Notification.Name(FCMManager.FCM_REQUEST_PAYMENT_STATUS), object: nil)
       
    }
   
    func removeNotificationCenter(){
        let center = NotificationCenter.default
        center.removeObserver(self, name: Notification.Name(FCMManager.FCM_REQUEST_PAYMENT_STATUS), object: nil)
    }
    @objc func requestStatusFromFCM(notification: Notification) {
        if let userInfo = notification.userInfo{
            let cmd = userInfo[AnyHashable("cmd")] as! String
            if cmd == "charging_end"{
                self.stopCharging()
            }else{
                self.requestChargingStatus()
            }
        }
    }
    
        
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    @IBAction func onClickUserControl(_ sender: UIButton) {
        self.requestStopCharging()
    }
    
}

extension PaymentStatusViewController {
    func broadCastFCMPayoad(payload: [AnyHashable: Any]){
        let cmd = payload["cmd"] as! String
        let time = payload["time"] as! String
        if cmd == "charging_start" {
            self.chargingStartTime = time
            self.mChronometer.setBase(base: self.getChargingStartTime())
            self.mChronometer.start()
        }else{
            
        }
        
    }
    
    func startTimer(tick : Int){
        removeTimer()
        var index = 0
        mTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(tick), repeats: true) { (timer) in
            self.requestChargingStatus()
            index = index + 1
        }
        mTimer.fire()
    }
    
    func removeTimer(){
        mTimer.invalidate()
        mTimer = Timer()
    }
    
    func requestOpenCharger() {
        let chargingId = getChargingId();
        if chargingId.isEmpty {
            showProgress()
            Server.openCharger(cpId: cpId, connectorId: connectorId, point: point) { (isSuccess, value) in
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
        let chargingId = getChargingId();
        if chargingId.isEmpty {
            Snackbar().show(message: "오류가 발생하였습니다. 충전하기 페이지 종료후 재시도 바랍니다.")
        }else{
            Server.stopCharging(chargingId: chargingId) { (isSuccess, value) in
                self.hideProgress()
                if isSuccess {
                    let json = JSON(value)
                    self.responseStop(response: json)
                } else {
                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 충전하기 페이지 종료후 재시도 바랍니다.")
                }
            }
        }
    }
    
    func requestChargingStatus() {
        let chargingId = getChargingId();
        if (!chargingId.isEmpty) {
            
            Server.getChargingStatus(chargingId: chargingId) { (isSuccess, value) in
                self.hideProgress()
                if isSuccess {
                    let json = JSON(value)
                    self.responseChargingStatus(response: json)
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
        case "1000" :
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
        updateDataStructAtResponse(response: response);
        switch (mChargingStatus.resultCode) {
            case 1000:
            if (mChargingStatus.status == STATUS_FINISH) {
                stopCharging()
            } else {
                if (chargingStartTime.isEmpty || !chargingStartTime.elementsEqual(mChargingStatus.startDate ?? "")) {
                    chargingStartTime = mChargingStatus.startDate ?? "";
                }
                self.updateChargingStatus();
            }
            
            
            default: // error
                Snackbar().show(message: mChargingStatus.msg ?? "")
            break
        }
    }
    
    func updateDataStructAtResponse(response: JSON) {
        mChargingStatus.resultCode = response["code"].int ?? 9000
        mChargingStatus.status = Int(response["status"].string ?? "\(STATUS_READY)")
        mChargingStatus.cpId = response["cp_id"].string ?? ""
        mChargingStatus.startDate = response["s_date"].string ?? ""
        mChargingStatus.chargingRate = response["rate"].string ?? "0"
        mChargingStatus.chargingKw = response["c_kw"].string ?? "0"
        mChargingStatus.usedPoint = response["u_point"].string ?? ""
        mChargingStatus.stationName = response["snm"].string ?? ""
    }
    
    func responseStop(response: JSON) {
        if response.isEmpty {
            return
        }
        switch (response["code"].stringValue) {
            case "1000" :
                stopCharging()
                break;
            default:
                Snackbar().show(message:response["msg"].stringValue)
        }
    }
    
    func setChargingId(chargerId: String) {
        defaults.saveString(key: UserDefault.Key.CHARGING_ID, value: chargerId)
    }
    
    func getChargingId() -> String {
        return defaults.readString(key: UserDefault.Key.CHARGING_ID)
    }
    
    func showProgress(){
        indicator.isHidden = false
        indicator.startAnimating()
    }
    
    func hideProgress(){
        indicator.stopAnimating()
        indicator.isHidden = true
    }
}

//for chronometer
extension PaymentStatusViewController {
    func updateChargingStatus() {
        if let status = mChargingStatus.status{
            if status < STATUS_READY || status > STATUS_FINISH {
                return;
            }
        }
        if (mChargingStatus.status == STATUS_READY) {
            lbChargeComment.text = "충전 커넥터를 차량과 연결 후 \n잠시만 기다려 주세요"
            mUserControlBtn.titleLabel?.text = "충전취소"
        }else {
            if(chargingStartTime.isEmpty){
                return
            }else{
                mChronometer.setBase(base: getChargingStartTime())
                mChronometer.start()
                
                lbChargeComment.text = "충전이 진행중입니다"
                mUserControlBtn.titleLabel?.text = "충전종료"
            }
            if let chargingRate = Double(mChargingStatus.chargingRate ?? "0"){
                if (chargingRate > 0.0) {
                    mCircleView.setRateProgress(progress: Double(chargingRate))
                }
                
            }
            if let chargingKw = mChargingStatus.chargingKw{
                let chargePower = "\(chargingKw) Kw"
                lbChargePower.text = chargePower

            }
            
        }
    }
    
    func stopCharging(){
        removeTimer()
        mChronometer.stop()
        let paymentResultVc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentResultViewController") as! PaymentResultViewController
        var vcArray = self.navigationController?.viewControllers
        vcArray!.removeLast()
        vcArray!.append(paymentResultVc)
        self.navigationController?.setViewControllers(vcArray!, animated: true)
    }
    
    func getChargingStartTime() -> Double{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")
        let since1970 = formatter.date(from: chargingStartTime)!.timeIntervalSince1970
        return Double(since1970)
    }
}

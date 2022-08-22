//
//  PaymentResultViewController.swift
//  evInfra
//
//  Created by bulacode on 10/07/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import SwiftyJSON
import Material

internal final class PaymentResultViewController: UIViewController {
    
    @IBOutlet weak var naviTotalView: CommonNaviView!
    @IBOutlet weak var ivResultBg: UIView!
    @IBOutlet weak var ivResultIcon: UIImageView!
    @IBOutlet weak var lbResultStatus: UILabel!
    @IBOutlet weak var lbResultMsg: UILabel!
    @IBOutlet weak var lbAuthNo: UILabel!
    
    @IBOutlet weak var lbStation: UILabel!
    @IBOutlet weak var lbQuantity: UILabel!
    @IBOutlet weak var lbDurationTime: UILabel!
    
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var viewDiscount: UIView!
    @IBOutlet weak var lbDiscountMsg: UILabel!
    @IBOutlet weak var lbDiscountAmt: UILabel!
    @IBOutlet weak var lbUsedPoint: UILabel!
    @IBOutlet weak var lbPayAmount: UILabel!
    
    @IBOutlet weak var lbAuthMsg: UILabel!
    
    @IBOutlet weak var lbSavePoint: UILabel!
    @IBOutlet weak var lbTotalPoint: UILabel!
    
    @IBOutlet weak var btnAuthStatus: UIButton!
    
    @IBOutlet weak var viewBerryResult: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var viewBtnSuccess: UIStackView!
    @IBOutlet weak var btnSuccessRight: UIButton! // go main
    
    @IBOutlet weak var viewBtnFail: UIStackView!
    @IBOutlet weak var btnFailRight: UIButton! // call
    @IBOutlet weak var viewFailMsg: UIView!
    @IBOutlet var heightViewStatus: NSLayoutConstraint!
    @IBOutlet var heightViewDiscount: NSLayoutConstraint!
    
    // MARK: VARIABLE
    
    internal var chargingId = ""
    
    private var chargingStatus = ChargingStatus()
    private let defaults = UserDefault()
    
    
    // MARK: SYSTEM FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ivResultBg.layer.cornerRadius = ivResultBg.frame.height/2
        btnAuthStatus.layer.cornerRadius = 4
        btnAuthStatus.layer.borderWidth = 1
        viewBerryResult.layer.cornerRadius = 8
        btnSuccessRight.layer.cornerRadius = 6
        btnFailRight.layer.cornerRadius = 6
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "충전 완료 화면"
        
        naviTotalView.naviTitleLbl.text = "충전완료"        
        naviTotalView.backClosure = {
            GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
        }
                
        prepareView()
        showProgress()
        
        if chargingId.isEmpty {
            chargingId = getChargingId()
        }
        Server.getChargingResult(chargingId: chargingId) { (isSuccess, value) in
            self.hideProgress()
            if isSuccess {
                self.responseChargingStatus(response: JSON(value))
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 충전하기 페이지 종료후 재시도 바랍니다.")
            }
        }
    }
    
    // MARK: FUNC
            
    func prepareView() {
        lbAuthMsg.isHidden = true
        viewBtnSuccess.isHidden = true
        viewBtnFail.isHidden = true
        viewFailMsg.isHidden = true
    }
    
    @IBAction func onClickPaymentResultOk(_ sender: UIButton) {
        self.navigationController?.pop()
    }
    
    func getChargingId() -> String {
        return defaults.readString(key: UserDefault.Key.CHARGING_ID)
    }
    
    func responseChargingStatus(response: JSON) {
        if response.isEmpty {
            return
        }
        
        chargingStatus = getChargingStatusFromResponse(response: response)
        
        switch (chargingStatus.resultCode) {
        case 1000:
            updateView(chargingStatus: chargingStatus)
        default: // error
            Snackbar().show(message: chargingStatus.msg ?? "")
            break
        }
    }
    
    func getChargingStatusFromResponse(response: JSON) -> ChargingStatus {
        let chargingStatus = ChargingStatus.init()
        chargingStatus.resultCode = response["code"].int ?? 9000
        chargingStatus.msg = response["msg"].stringValue
        
        chargingStatus.stationName = response["snm"].string ?? ""
        chargingStatus.chargingKw = response["c_kw"].string ?? ""
        chargingStatus.startDate = response["s_date"].string ?? ""
        chargingStatus.endDate = response["e_date"].string ?? ""
        chargingStatus.fee = response["fee"].string ?? ""
        chargingStatus.payAmount = response["pay_amt"].string ?? ""
        chargingStatus.payAuthCode  = response["pay_code"].string ?? ""
        chargingStatus.payResultCode = response["pay_rcode"].string ?? ""
        chargingStatus.payResultMsg = response["pay_msg"].string ?? ""
        
        chargingStatus.usedPoint = response["u_point"].string ?? ""
        chargingStatus.savePoint = response["save_point"].string ?? ""
        chargingStatus.totalPoint = response["total_point"].string ?? ""
        
        chargingStatus.discountAmt = response["discount_amt"].string ?? ""
        chargingStatus.discountMsg = response["discount_msg"].string ?? ""
        return chargingStatus
    }
    
    func updateView(chargingStatus: ChargingStatus) {
        self.lbAuthNo.text = "거래번호 " + (chargingStatus.payAuthCode ?? "0")
        self.lbStation.text = chargingStatus.stationName
        if let chargingKw = chargingStatus.chargingKw {
            let chargePower = "\(chargingKw) kWh"
            lbQuantity.text = chargePower
        } else {
            self.lbQuantity.text = " - "
        }
        
        if let startTime = chargingStatus.startDate, let endTime = chargingStatus.endDate,
            let sDate = startTime.toDate(), let eDate = endTime.toDate() {
            let dayHourMinuteSecond: Set<Calendar.Component> = [.hour, .minute, .second]
            let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: sDate, to: eDate)
            if let hour = difference.hour, let minute = difference.minute, let second = difference.second {
                self.lbDurationTime.text = String(format: "%02d:%02d:%02d", hour, minute, second)
            }
        }
        
        self.lbAmount.text = "\(chargingStatus.fee?.currency() ?? "0") 원"
        if let discountMsgStr = chargingStatus.discountMsg, !discountMsgStr.isEmpty {
            let discountAmt = Double(chargingStatus.discountAmt!) ?? 0.0
            var discountStr = chargingStatus.discountAmt!.currency()
            if discountAmt != 0 {
                discountStr = "- " + discountStr
            }
            self.lbDiscountAmt.text = "\(discountStr) 원"
            self.lbDiscountMsg.text = discountMsgStr
        } else {
            self.viewDiscount.isHidden = true
            self.heightViewDiscount.constant -= 52
        }
        
        let usedPoint = Double(chargingStatus.usedPoint!) ?? 0.0
        var pointStr = chargingStatus.usedPoint!.currency()
        if usedPoint != 0 {
            pointStr = "- " + pointStr
        }
        self.lbUsedPoint.text = "\(pointStr) 베리"
        self.lbPayAmount.text = "\(chargingStatus.payAmount?.currency() ?? "0") 원"
        
        self.lbSavePoint.text = (chargingStatus.savePoint?.currency() ?? "") + " 베리"
        self.lbTotalPoint.text = (chargingStatus.totalPoint?.currency() ?? "") + " 베리"
                
        if let resultCode = chargingStatus.payResultCode {
            if resultCode.elementsEqual("8000") // 결재 승인 성공
            || resultCode.elementsEqual("8001") // 10원 미만 결제
            || resultCode.elementsEqual("8010") { // 법인 후불결제
                self.ivResultBg.backgroundColor = UIColor(named: "content-positive")
                self.ivResultIcon.image = UIImage(named: "icon_check_md")
                self.lbResultStatus.text = "충전 완료"
                self.lbResultMsg.text = "커넥터를 분리하고 커버를 닫아주세요"
                self.btnAuthStatus.layer.borderColor = UIColor(named: "content-positive")?.cgColor
                self.btnAuthStatus.setTitleColor(UIColor(named: "content-positive"), for: .normal)
                self.viewBtnSuccess.isHidden = false
            } else {
                self.ivResultBg.backgroundColor = UIColor(named: "content-negative")
                self.ivResultIcon.image = UIImage(named: "icon_close_md")
                self.lbResultStatus.text = "결제 실패"
                self.lbResultMsg.text = "하단 결제 실패 사유를 확인해주신 뒤\n결제를 재시도 해주시기 바랍니다.\n미수금이 남아있는 경우, 충전이 제한될 수 있습니다."
                self.heightViewStatus.constant = 240
                self.lbAuthMsg.isHidden = false
                self.viewFailMsg.isHidden = false
                self.lbAuthMsg.text = "실패사유 : " + (chargingStatus.payResultMsg ?? "")
                self.btnAuthStatus.layer.borderColor = UIColor(named: "content-negative")?.cgColor
                self.btnAuthStatus.setTitleColor(UIColor(named: "content-negative"), for: .normal)
                self.viewBtnFail.isHidden = false
                self.loadViewIfNeeded()
            }
        }
    }

    func showProgress() {
        indicator.isHidden = false
        indicator.startAnimating()
    }
    
    func hideProgress() {
        indicator.stopAnimating()
        indicator.isHidden = true
    }
    
    func didSelectReceipt(charge: ChargingStatus) {
        let window = UIApplication.shared.keyWindow!
        let receiptView = ReceiptView(frame: window.bounds)
        receiptView.update(status: charge)
        receiptView.tag = 100
        receiptView.isUserInteractionEnabled = true
        window.addSubview(receiptView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeSubview))
        receiptView.addGestureRecognizer(tapGesture)
    }
    
    @objc func removeSubview() {
        let window = UIApplication.shared.keyWindow!
        if let receiptView = window.viewWithTag(100) {
            receiptView.removeFromSuperview()
        }
    }
    
    @IBAction func onClickSuccessLeft(_ sender: Any) {
        // show receipt
        if let startTime = chargingStatus.startDate, let endTime = chargingStatus.endDate{
            Server.getCharges(isAllDate: false, sDate: startTime, eDate: endTime) { [self] (isSuccess, value) in
                if isSuccess {
                    if let data = value {
                        let chargeHistory = try! JSONDecoder().decode(ChargingHistoryList.self, from: data)
                        if chargeHistory.code != 1000 {
                            Snackbar().show(message: "결제 정보를 받아오지 못했습니다.")
                        } else {
                            if chargeHistory.list!.count > 0 {
                                let charge = chargeHistory.list![0]
                                self.didSelectReceipt(charge: charge)
                            }
                        }
                    }
                }
            }
        }
    }
    @IBAction func onClickSuccessRight(_ sender: Any) {
        // go main
        self.navigationController?.pop()
    }
    @IBAction func onClickFailLeft(_ sender: Any) {
        // go main
        self.navigationController?.pop()
    }
    @IBAction func onClickFailRight(_ sender: Any) {
        // repayment list
        let repayListVC = self.storyboard!.instantiateViewController(withIdentifier: "RepayListViewController") as! RepayListViewController
        var vcArray = self.navigationController?.viewControllers
        vcArray!.removeLast()
        vcArray!.append(repayListVC)
        self.navigationController?.setViewControllers(vcArray!, animated: true)
    
    }
}

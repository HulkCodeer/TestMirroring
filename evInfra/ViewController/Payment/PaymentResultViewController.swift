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

class PaymentResultViewController: UIViewController {

    @IBOutlet weak var ivStation: UIImageView!
    @IBOutlet weak var ivQuantity: UIImageView!
    
    @IBOutlet weak var ivAmount: UIImageView!
    @IBOutlet weak var ivAuthNo: UIImageView!
    @IBOutlet weak var ivAuthStatus: UIImageView!
    @IBOutlet weak var ivMessage: UIImageView!
    @IBOutlet weak var ivTime: UIImageView!
    @IBOutlet weak var ivPoint: UIImageView!
    @IBOutlet weak var ivSavePoint: UIImageView!
    
    @IBOutlet weak var lbStation: UILabel!
    @IBOutlet weak var lbQuantity: UILabel!
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbPayAmount: UILabel!
    
    @IBOutlet weak var lbAuthNo: UILabel!
    @IBOutlet weak var lbAuthStatus: UILabel!
    @IBOutlet weak var lbAuthMsg: UILabel!
    @IBOutlet weak var lbStartTime: UILabel!
    @IBOutlet weak var lbFinishTime: UILabel!
    
    @IBOutlet weak var lbUsedPoint: UILabel!
    @IBOutlet weak var lbSavePoint: UILabel!
    @IBOutlet weak var lbTotalPoint: UILabel!
    
    @IBOutlet weak var viewDiscount: UIView!
    @IBOutlet weak var lbDiscountMsg: UILabel!
    @IBOutlet weak var lbDiscountAmt: UILabel!
    @IBOutlet weak var lbPaymentFailMsg: UILabel!
    @IBOutlet weak var lbPaymentResultMsg: UILabel!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    let defaults = UserDefault()
    var chargingId = ""
    
    override func viewWillAppear(_ animated: Bool) {
        lbPaymentFailMsg.gone()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
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

    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "충전하기"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }

    func prepareView() {
        self.ivStation.image = UIImage(named: "ic_menu_ev_station")?.withRenderingMode(.alwaysTemplate)
        self.ivStation.tintColor = UIColor(rgb: 0x585858)
        self.ivQuantity.image = UIImage(named: "ic_charge_quantity")?.withRenderingMode(.alwaysTemplate)
        self.ivQuantity.tintColor = UIColor(rgb: 0x585858)
        self.ivAmount.image = UIImage(named: "ic_menu_pay_amount")?.withRenderingMode(.alwaysTemplate)
        self.ivAmount.tintColor = UIColor(rgb: 0x585858)
        self.ivAuthNo.image = UIImage(named: "ic_menu_pay_auth_no")?.withRenderingMode(.alwaysTemplate)
        self.ivAuthNo.tintColor = UIColor(rgb: 0x585858)
        self.ivAuthStatus.image = UIImage(named: "ic_menu_check")?.withRenderingMode(.alwaysTemplate)
        self.ivAuthStatus.tintColor = UIColor(rgb: 0x585858)
        self.ivMessage.image = UIImage(named: "ic_menu_message")?.withRenderingMode(.alwaysTemplate)
        self.ivMessage.tintColor = UIColor(rgb: 0x585858)
        self.ivTime.image = UIImage(named: "ic_time")?.withRenderingMode(.alwaysTemplate)
        self.ivTime.tintColor = UIColor(rgb: 0x585858)
        self.ivPoint.image = UIImage(named: "ic_menu_point")?.withRenderingMode(.alwaysTemplate)
        self.ivPoint.tintColor = UIColor(rgb: 0x585858)
        self.ivSavePoint.image = UIImage(named: "ic_menu_save_point")?.withRenderingMode(.alwaysTemplate)
        self.ivSavePoint.tintColor = UIColor(rgb: 0x585858)
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
        
        let chargingStatus = getChargingStatusFromResponse(response: response)
        
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
        self.lbPaymentResultMsg.text = "충전이 완료되었습니다.\n커넥터를 분리하고 커버를 닫아주세요."
        self.lbStation.text = chargingStatus.stationName
        if let chargingKw = chargingStatus.chargingKw {
            let chargePower = "\(chargingKw) Kw"
            lbQuantity.text = chargePower
        } else {
            self.lbQuantity.text = " - "
        }
        self.lbStartTime.text = chargingStatus.startDate
        self.lbFinishTime.text = chargingStatus.endDate
        
        self.lbAmount.text = "\(chargingStatus.fee?.currency() ?? "0") 원"
        if let discountAmtStr = chargingStatus.discountAmt, !discountAmtStr.isEmpty {
            viewDiscount.isHidden = false
            self.lbDiscountAmt.text = "\(discountAmtStr.currency()) 원"
            self.lbDiscountMsg.text = chargingStatus.discountMsg
        }
        self.lbPayAmount.text = "\(chargingStatus.payAmount?.currency() ?? "0") 원"
        
        self.lbUsedPoint.text = (chargingStatus.usedPoint?.currency() ?? "") + " 포인트"
        self.lbSavePoint.text = (chargingStatus.savePoint?.currency() ?? "") + " 포인트"
        self.lbTotalPoint.text = (chargingStatus.totalPoint?.currency() ?? "") + " 포인트"
        
        self.lbAuthNo.text = chargingStatus.payAuthCode
        
        if let resultCode = chargingStatus.payResultCode {
            if resultCode.elementsEqual("8000") // 결재 승인 성공
            || resultCode.elementsEqual("8001") // 10원 미만 결제
            || resultCode.elementsEqual("8010") { // 법인 후불결제
                self.lbAuthStatus.text = "승인성공"
                self.lbAuthMsg.text = "정상승인"
            } else {
                self.lbAuthStatus.text = "승인실패"
                self.lbPaymentFailMsg.visible()
                self.lbAuthMsg.text = chargingStatus.payResultMsg
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
}

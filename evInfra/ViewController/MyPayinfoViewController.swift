//
//  MyPayinfoViewController.swift
//  evInfra
//
//  Created by bulacode on 21/06/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import Material
import WebKit
import SwiftyJSON

class MyPayinfoViewController: UIViewController{
    
    
    let PAY_PAYMENT_SUCCESS = 8000 //결제성공
    let PAY_PAYMENT_FAIL = 8004    //VAN 실패 응답
    let PAY_PAYMENT_FAIL_LESS_AMOUNT = 8043 // 1000원 미만결제
    let PAY_PAYMENT_FAIL_CARD_LESS = 8044 //잔액부족
    let PAY_PAYMENT_FAIL_CARD_NO = 8045 //카드번호 오류
    let PAY_PAYMENT_FAIL_CARD_CERT = 8046 //인증불가 카드
    let PAY_PAYMENT_FAIL_CARD_COM = 8047 //카드사 인증 에러
    
    let PAY_REGISTER_SUCCESS = 8100 // 카드등록 성공
    let PAY_REGISTER_CANCEL_FROM_USER = 8140 // 유저에 의한 카드등록 취소
    let PAY_REGISTER_FAIL = 8144 // 카드등록 실패
    public let PAY_REGISTER_FAIL_PG = 8145 // VAN사의 Register 기타 오류 9999
    
    let PAY_CARD_DELETE_SUCCESS = 8200 // 카드삭제 성공
    let PAY_CARD_DELETE_FAIL_NO_USER = 8203 // 카드삭제 실패 (등록한 사람이 DB에 없음)
    let PAY_CARD_DELETE_FAIL = 8204 // 카드삭제 실패
    
    let PAY_MEMBER_DELETE_SUCESS = 8320 // 결제정보 멤버 삭제
    let PAY_MEMBER_DELETE_FAIL_NO_USER = 8323 //결제정보 멤버 삭제 실패 (등록한 사람이 DB에 없음)
    let PAY_MEMBER_DELETE_FAIL_DB = 8324 //DB 삭제 에러
    let PAY_MEMBER_DELETE_FAIL = 8304 // 결제정보 멤버 삭제 실패
    
    let PAY_REGISTER_MODE = 1
    let CARD_REGISTER_MODE = 2
    
    public let PAY_FINE_USER = 8800 // 유저체크
    public let PAY_NO_CARD_USER = 8801 // 카드등록 아니된 멤버
    public let PAY_NO_VERIFY_USER = 8802 // 인증 되지 않은 멤버 *헤커 의심
    public let PAY_DELETE_FAIL_USER = 8803 // 비정상적인 삭제 멤버
    public let PAY_DEBTOR_USER = 8804 // 돈안낸 유저
    public let PAY_NO_USER = 8844 // 미등록 멤버
    
    let DELETE_MODE = 0
    let CHANGE_MODE = 1
    
    @IBOutlet weak var mPayInfoView: UIView!
    @IBOutlet weak var registerCardInfo: UIView!
    @IBOutlet weak var registerInfo: UIView!
    
    @IBOutlet weak var franchiseeLabel: UILabel!
    @IBOutlet weak var vanLabel: UILabel!
    @IBOutlet weak var cardCoLabel: UILabel!
    @IBOutlet weak var cardNoLabel: UILabel!
    @IBOutlet weak var regDateLabel: UILabel!
    
    
    @IBOutlet weak var resultCodeLabel: UILabel!
    @IBOutlet weak var resultMsgLabel: UILabel!
    @IBOutlet weak var registerInfoBtnLayer: UIStackView!
    
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var changeBtn: UIButton!
    
    var registData: JSON?
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        initInfoView()
        if let regData = registData{
            showRegisteredResult(json: regData)
        }else{
            checkRegisterPayment()
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func checkRegisterPayment(){
        Server.getPayRegisterStatus { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                print("PJS payCOde HERE 1 \(value)");
                let payCode = json["pay_code"].intValue
                print("PJS payCOde HERE 1 \(json)");
                print("PJS payCOde HERE 2 \(payCode)");
                switch(payCode){
                    case self.PAY_NO_USER, self.PAY_NO_CARD_USER:
                        print("PJS payCOde HERE 3");
                        self.moveToMyPaytRegist()
                        
                        break;
                    case self.PAY_DEBTOR_USER, self.PAY_NO_VERIFY_USER, self.PAY_DELETE_FAIL_USER:
                        let ok = UIAlertAction(title: "확인", style: .default, handler:{ (ACTION) -> Void in
                            self.navigationController?.pop()
                        })
                        var actions = Array<UIAlertAction>()
                        actions.append(ok)
                        UIAlertController.showAlert(title: "알림", message: json["ResultMsg"].stringValue, actions: actions)

                    case self.PAY_FINE_USER:
                        Server.getPayRegisterInfo { (isSuccess, value) in
                            if isSuccess {
                                let json = JSON(value)
                                self.showRegisteredResult(json: json)
                            }else {
                                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
                            }
                        }
                    case self.PAY_REGISTER_FAIL_PG:
                        let ok = UIAlertAction(title: "확인", style: .default, handler:{ (ACTION) -> Void in
                            self.navigationController?.pop()
                        })
                        var actions = Array<UIAlertAction>()
                        actions.append(ok)
                        UIAlertController.showAlert(title: "알림", message: "서비스 연결상태가 좋지 않습니다.\n잠시 후 다시 시도해 주세요.", actions: actions)

                    default:
                        break;
                }
                
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            }
        }
        
    }
    
    
    func showRegisteredResult(json: JSON) {
        print("PJS HERE showRegisteredResult json = \(json)")
        let json1 = JSON(json)
        let payCode = json1["pay_code"].intValue
        let asdf = json1["ResultMsg"].stringValue
        //                    item.eventId = jsonRow["id"].intValue
        print("PJS HERE showRegisteredResult = \(payCode)  AHHH ?? \(asdf)")
        
        switch(payCode){
            case self.PAY_REGISTER_SUCCESS:
                self.registerCardInfo.isHidden = false
                self.okBtn.isHidden = false
                self.registerInfoBtnLayer.isHidden = true
                self.franchiseeLabel.text = "(주)소프트베리"
                self.vanLabel.text = "스마트로(주)"
                self.cardCoLabel.text = json["card_co"].stringValue
                self.cardNoLabel.text = json["card_nm"].stringValue
                self.regDateLabel.text = json["reg_date"].stringValue
                
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
            
            case self.PAY_REGISTER_FAIL, self.PAY_REGISTER_FAIL_PG, self.PAY_REGISTER_CANCEL_FROM_USER:
                self.registerCardInfo.isHidden = true
                self.okBtn.isHidden = false
                self.registerInfoBtnLayer.isHidden = true
                
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
            case self.PAY_MEMBER_DELETE_SUCESS, self.PAY_MEMBER_DELETE_FAIL_NO_USER, self.PAY_MEMBER_DELETE_FAIL, self.PAY_MEMBER_DELETE_FAIL_DB:
                self.registerCardInfo.isHidden = true
                self.okBtn.isHidden = false
                self.registerInfoBtnLayer.isHidden = true
                
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
                
                print("", "PJS REGIST CARD INFO \(payCode)  \(json["ResultMsg"].stringValue)"  )
                break;
            case self.PAY_FINE_USER:
                self.registerCardInfo.isHidden = false
                self.okBtn.isHidden = true
                self.registerInfoBtnLayer.isHidden = false
                self.franchiseeLabel.text = "(주)소프트베리"
                self.vanLabel.text = "스마트로(주)"
                self.cardCoLabel.text = json["card_co"].stringValue
                self.cardNoLabel.text = json["card_nm"].stringValue
                self.regDateLabel.text = json["reg_date"].stringValue
                
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
                break;
            default:
                
                self.registerCardInfo.isHidden = true
                self.okBtn.isHidden = false
                self.registerInfoBtnLayer.isHidden = true
                
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
                break;
        }
    }

    func moveToMyPaytRegist(){
        let payRegistVC = self.storyboard?.instantiateViewController(withIdentifier: "MyPayRegisterViewController") as! MyPayRegisterViewController
        var vcArray = self.navigationController?.viewControllers
        vcArray!.removeLast()
        vcArray!.append(payRegistVC)
        self.navigationController?.setViewControllers(vcArray!, animated: true)
    }
    
    func deletePayMember(){
        Server.deletePayMember { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let payCode = json["pay_code"].intValue
                
                self.registerCardInfo.isHidden = true
                self.okBtn.isHidden = false
                self.registerInfoBtnLayer.isHidden = true
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            }
        }
    }
    

    
    func initInfoView(){
        registerCardInfo.layer.shadowColor = UIColor.black.cgColor
        registerCardInfo.layer.shadowOpacity = 0.5
        registerCardInfo.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        registerInfo.layer.shadowColor = UIColor.black.cgColor
        registerInfo.layer.shadowOpacity = 0.5
        registerInfo.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "결제정보관리"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    @IBAction func onClickOkBtn(_ sender: UIButton) {
        self.navigationController?.pop()
    }
    
    @IBAction func onClickDeleteBtn(_ sender: UIButton) {
        showAlertDialog(vc: self, type: self.DELETE_MODE, completion:  {(isOkey) -> Void in
            if isOkey {
               self.deletePayMember()
            }
        })
    }
    
    @IBAction func onClickChangeBtn(_ sender: UIButton) {
        showAlertDialog(vc: self, type: self.CHANGE_MODE, completion:  {(isOkey) -> Void in
            if isOkey {
                self.moveToMyPaytRegist()
            }
        })
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    func showAlertDialog(vc: UIViewController, type: Int, completion: ((Bool) -> ())? = nil) {
        var title: String = ""
        var msg: String = ""
        
        switch(type){
            case self.DELETE_MODE:
                title = "알림"
                msg = "결제정보를 삭제하시면 결제기능을 이용할 수 없습니다.\n결제정보를 삭제 하시겠습니까?"
                break;
            case self.CHANGE_MODE:
                title = "알림"
                msg = "결제정보 변경을 진행하시면, 현재 결제정보는 이용할 수 없습니다.\n결제정보를 변경 하시겠습니까?"
                break;
            
            default:
                break;
        }
        
        let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in
            if completion != nil {
                completion!(true)
            }
        })
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler:{ (ACTION) -> Void in
            if completion != nil {
                completion!(false)
            }
        })
        
        var actions = Array<UIAlertAction>()
        actions.append(ok)
        actions.append(cancel)
        UIAlertController.showAlert(title: title, message: msg, actions: actions)
    }
}


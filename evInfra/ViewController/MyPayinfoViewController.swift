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

class MyPayinfoViewController: UIViewController, MyPayRegisterViewDelegate, RepaymentListDelegate {
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
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        initInfoView()
        
        if MemberManager().isLogin() {
            checkRegisterPayment()
        } else {
            MemberManager().showLoginAlert(vc: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func checkRegisterPayment() {
        Server.getPayRegisterStatus { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let payCode = json["pay_code"].intValue
                switch(payCode){
                    case PaymentCard.PAY_NO_USER, PaymentCard.PAY_NO_CARD_USER:
                        self.moveToMyPayRegist()
                        
                        break;
                    case PaymentCard.PAY_DEBTOR_USER:
                        let paymentStoryboard = UIStoryboard(name : "Payment", bundle: nil)
                        let repayListVC = paymentStoryboard.instantiateViewController(withIdentifier: "RepayListViewController") as! RepayListViewController
                        repayListVC.delegate = self
                        self.navigationController?.push(viewController: repayListVC)
                        break;
                    case PaymentCard.PAY_NO_VERIFY_USER, PaymentCard.PAY_DELETE_FAIL_USER:
                        let ok = UIAlertAction(title: "확인", style: .default, handler:{ (ACTION) -> Void in
                            self.navigationController?.pop()
                        })
                        var actions = Array<UIAlertAction>()
                        actions.append(ok)
                        UIAlertController.showAlert(title: "알림", message: json["ResultMsg"].stringValue, actions: actions)

                    case PaymentCard.PAY_FINE_USER:
                        Server.getPayRegisterInfo { (isSuccess, value) in
                            if isSuccess {
                                let json = JSON(value)
                                self.showRegisteredResult(json: json)
                            }else {
                                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
                            }
                        }
                    case PaymentCard.PAY_REGISTER_FAIL_PG:
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
        let json1 = JSON(json)
        let payCode = json1["pay_code"].intValue
        
        switch payCode {
            case PaymentCard.PAY_REGISTER_SUCCESS:
                self.registerInfo.isHidden = false
                self.registerCardInfo.isHidden = false
                
                // 등록 완료 -> 확인버튼
                self.showConfirmBtn(show: true)
                
                self.franchiseeLabel.text = "(주)소프트베리"
                self.vanLabel.text = "스마트로(주)"
                self.cardCoLabel.text = json["card_co"].stringValue
                self.cardNoLabel.text = json["card_nm"].stringValue
                self.regDateLabel.text = json["reg_date"].stringValue
                
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
            
            case PaymentCard.PAY_REGISTER_FAIL, PaymentCard.PAY_REGISTER_FAIL_PG:
                self.registerInfo.isHidden = false
                self.registerCardInfo.isHidden = true
            
                // 등록 실패 -> 확인버튼
                self.showConfirmBtn(show: true)
                
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
            
            case PaymentCard.PAY_REGISTER_CANCEL_FROM_USER:
                self.onCancelRegister()
            
            case PaymentCard.PAY_MEMBER_DELETE_SUCESS, PaymentCard.PAY_MEMBER_DELETE_FAIL_NO_USER, PaymentCard.PAY_MEMBER_DELETE_FAIL, PaymentCard.PAY_MEMBER_DELETE_FAIL_DB:
                self.registerInfo.isHidden = false
                self.registerCardInfo.isHidden = true
                // 삭제 -> 확인버튼
                self.showConfirmBtn(show: true)
                
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
            
            case PaymentCard.PAY_FINE_USER:
                self.registerInfo.isHidden = true
                self.registerCardInfo.isHidden = false
            
                // 조회 -> 삭제/변경 버튼
                self.showConfirmBtn(show: false)
                self.franchiseeLabel.text = "(주)소프트베리"
                self.vanLabel.text = "스마트로(주)"
                self.cardCoLabel.text = json["card_co"].stringValue
                self.cardNoLabel.text = json["card_nm"].stringValue
                self.regDateLabel.text = json["reg_date"].stringValue
                
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
            
            default:
                self.registerCardInfo.isHidden = true
                self.showConfirmBtn(show: true)
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
        }
    }

    func moveToMyPayRegist() {
        let payRegistVC = self.storyboard?.instantiateViewController(withIdentifier: "MyPayRegisterViewController") as! MyPayRegisterViewController
        payRegistVC.myPayRegisterViewDelegate = self
        navigationController?.push(viewController: payRegistVC)
    }
    
    func showConfirmBtn(show: Bool) {
        self.okBtn.isHidden = !show
        self.deleteBtn.isHidden = show
        self.changeBtn.isHidden = show
    }
    
    func deletePayMember() {
        Server.deletePayMember { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let payCode = json["pay_code"].intValue
                
                self.registerInfo.isHidden = false
                self.registerCardInfo.isHidden = true
                // 삭제 -> 확인버튼
                self.showConfirmBtn(show: true)
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            }
        }
    }
    
    func initInfoView() {
        registerCardInfo.layer.shadowColor = UIColor.black.cgColor
        registerCardInfo.layer.shadowOpacity = 0.5
        registerCardInfo.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        registerInfo.layer.shadowColor = UIColor.black.cgColor
        registerInfo.layer.shadowOpacity = 0.5
        registerInfo.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
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
                self.moveToMyPayRegist()
            }
        })
    }
    
    @objc
    fileprivate func handleBackButton() {
        guard let _navi = navigationController else { return }
        for vc in _navi.viewControllers {
            if vc is MembershipCardViewController {
                _navi.popToRootViewController(animated: true)
                return
            } else {
                _navi.pop()
            }
        }
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
    
    func finishRegisterResult(json: JSON) {
        let result = JSON(json)
        showRegisteredResult(json: result)
    }
    
    func onCancelRegister() {
        Snackbar().show(message: "결제정보 등록을 취소했습니다")
        self.navigationController?.pop()
    }
    
    func onRepaySuccess() {
        
    }
    
    func onRepayFail() {
        self.navigationController?.pop()
    }
}


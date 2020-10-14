//
//  LotteRentCertificateViewController.swift
//  evInfra
//
//  Created by SH on 2020/10/08.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Material
import UIKit
import SwiftyJSON
class LotteRentCertificateViewController : UIViewController,
        RegisterResultDelegate, MyPayRegisterViewDelegate {
    @IBOutlet var tfCarNo: UITextField!
    @IBOutlet var btnRegister: UIButton!
    
    var payRegistResult: JSON?
    var payCode : Int = -1
    var carNo : String = ""
    
    let RESULT_CONFIRM = 1
    let RESILT_NOT_CERTIFIED = 2
    let RESULT_PAY_ERROR = 3
    let RESULT_DONE = 4
    
    @IBAction func onClickRegistBtn(_ sender: Any) {
        do{
            let carNo = try tfCarNo.validatedText(validationType: .carnumber)
            var actions = Array<UIAlertAction>()
            let ok = UIAlertAction(title: "확인", style: .default, handler:{ (ACTION) -> Void in
                self.carNo = self.tfCarNo.text!
                self.certificateMember(carNo : carNo)
            })
            let cancel = UIAlertAction(title: "취소", style: .cancel, handler:{ (ACTION) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            actions.append(ok)
            actions.append(cancel)
            let msg = "\(carNo)\n위 차량번호가 맞으신가요?"
            UIAlertController.showAlert(title: "알림", message: msg, actions: actions)
        } catch {
            Snackbar().show(message: (error as! ValidationError).message)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let result = payRegistResult {
            updateAfterPayRegist(json: result)
        } else {
            tfCarNo.text = ""
        }
    }
    
    func updateAfterPayRegist(json: JSON) {
        if (json["pay_code"].intValue == PaymentCard.PAY_REGISTER_SUCCESS) {
            self.activateMember()
        } else {
            if json["resultMsg"].stringValue.isEmpty {
                Snackbar().show(message: "카드 등록을 실패하였습니다. 다시 시도해 주세요.")
            } else {
                Snackbar().show(message: json["resultMsg"].stringValue)
            }
            tfCarNo.text = ""
        }
    }
    
    func initView(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:)))
        self.view.addGestureRecognizer(tap)
        btnRegister.setDefaultBackground(cornerRadius: 20)
    }
    
    @objc
    fileprivate func handleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)

        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "롯데회원 등록"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func certificateMember(carNo : String){
        Server.certificateLotteRentaCar(carNo: carNo, completion: { [self](isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                print(json)
                switch json["code"].intValue {
                case 1000 , 1203:
                    self.showResultView(code : RESULT_CONFIRM, imgType : "SUCCESS", retry : false, callBtn : false, msg : "정보가 확인되었습니다.")
                    break
                case 1204 :
                    self.showResultView(code : RESILT_NOT_CERTIFIED, imgType : "QUESTION", retry : true, callBtn : true, msg : "기존에 등록된 회원 정보입니다.\n차량 번호를 정확하게 입력해주세요.\n\n재시도 이후에도 인증되지 않는 경우 아래 번호로 전화주시기 바랍니다.")
                    break
                case 1205 :
                    self.showResultView(code : RESILT_NOT_CERTIFIED, imgType : "ERROR", retry : true, callBtn : true, msg : "해당 차량 정보를 등록할 수 없습니다. \n정확하게 다시 입력해주세요.\n\n재시도 이후에도 인증되지 않는 경우 아래 번호로 전화주시기 바랍니다.")
                    break
                default :
                    print("out of index")
                }
            }
            else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            }
        })
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    private func showResultView(code : Int, imgType : String, retry : Bool, callBtn : Bool, msg : String){
        let resultVC = storyboard?.instantiateViewController(withIdentifier: "RegisterResultViewController") as! RegisterResultViewController
        resultVC.requestCode = code
        resultVC.imgType = imgType
        resultVC.showRetry = retry
        resultVC.showCallBtn = callBtn
        resultVC.message = msg
        resultVC.delegate = self
        self.navigationController?.push(viewController: resultVC)
    }
    
    func onConfirmBtnPressed(code : Int){
        print("okbtn")
        switch (code) {
        case RESULT_CONFIRM : //
            checkPaymentCardStatus();
            break
        case RESILT_NOT_CERTIFIED :
            break
        case RESULT_PAY_ERROR:
            self.navigationController?.popToRootViewController(animated: true)
            break
        case RESULT_DONE :
            self.navigationController?.pop()
            break
        default :
            print("out of index")
        }
    }
    
    private func activateMember(){
        print("activate!")
        Server.activateLotteRentaCar(carNo: self.carNo, completion: { [self](isSuccess, value) in
            if isSuccess {
                if self.payCode == PaymentCard.PAY_FINE_USER {
                    self.navigationController?.pop()
                } else {
                    self.showResultView(code : RESULT_DONE, imgType : "SUCCESS", retry : false, callBtn : false, msg : "등록 완료되었습니다.\n감사합니다")
                }
            }
            else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            }
        })
        
    }
    
    func moveToMyPayRegist() {
        let mainStoryboard = UIStoryboard(name : "Main", bundle: nil)
        let payRegistVC = mainStoryboard.instantiateViewController(withIdentifier: "MyPayRegisterViewController") as! MyPayRegisterViewController
        payRegistVC.myPayRegisterViewDelegate = self
        navigationController?.push(viewController: payRegistVC)
    }
    
    
    func finishRegisterResult(json: JSON){
        payRegistResult = json
    }
    
    private func checkPaymentCardStatus() {
        print("checkPaymentCardStatus")
        Server.getPayRegisterStatus { [self] (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                self.payCode = json["pay_code"].intValue
                switch self.payCode {
                    case PaymentCard.PAY_NO_USER, PaymentCard.PAY_NO_CARD_USER:
                        let ok = UIAlertAction(title: "OK", style: .default, handler:{ (ACTION) -> Void in
                            self.moveToMyPayRegist()
                        })
                        var actions = Array<UIAlertAction>()
                        actions.append(ok)
                        UIAlertController.showAlert(title: "결제 카드 등록", message: "원활한 카드 결제를 위해 카드 등록이 진행됩니다", actions: actions)
                        break
                    case PaymentCard.PAY_DEBTOR_USER, PaymentCard.PAY_NO_VERIFY_USER, PaymentCard.PAY_DELETE_FAIL_USER:
                        self.showResultView(code : RESULT_PAY_ERROR, imgType : "ERROR", retry : false, callBtn : true, msg : "미정산 금액이 있습니다.\n고객센터로 연락 바랍니다")
                        break
                    case PaymentCard.PAY_FINE_USER:
                        self.activateMember()
                        break
                    case PaymentCard.PAY_REGISTER_FAIL_PG:
                        Snackbar().show(message: "서비스 연결상태가 좋지 않습니다.\n잠시 후 다시 시도해 주세요.")

                    default:
                        break
                }
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            }
        }
    }
}


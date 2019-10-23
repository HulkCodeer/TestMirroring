//
//  MembershipCardViewController.swift
//  evInfra
//
//  Created by bulacode on 18/09/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON

class MembershipCardViewController: UIViewController, MembershipIssuanceViewDelegate, SearchAddressViewDelegate, MyPayRegisterViewDelegate {
    var membershipIssuanceView : MembershipIssuanceView? = nil
    var membershipInfoView : MembershipInfoView? = nil
    var memberData: [String: String]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        getNoticeData()
        // Do any additional setup after loading the view.
    }

    func getNoticeData() {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            
            Server.getInfoMembershipCard { (isSuccess, value) in
                if isSuccess {
                    let json = JSON(value)
                    let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                    if(json["code"].stringValue.elementsEqual("1101")){ // MBS_CARD_NOT_ISSUED 발급받은 회원카드가 없음
                        self.membershipIssuanceView = MembershipIssuanceView.init(frame: frame)
                        if let msView = self.membershipIssuanceView {
                            msView.membershipIssuanceDelegate = self
                            msView.lbIssuanceMbId.text = String(format: "%08d", UserDefault().readInt(key: UserDefault.Key.MB_ID))
                            msView.lbIssuanceNickName.text = UserDefault().readString(key: UserDefault.Key.MB_NICKNAME)
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:)))
                            msView.addGestureRecognizer(tap)
                            self.view.addSubview(msView)
                            
                        }
                    } else {
                        self.membershipInfoView = MembershipInfoView.init(frame: frame)
                        if let msView = self.membershipInfoView {
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:)))
                            msView.addGestureRecognizer(tap)
                            self.view.addSubview(msView)
                            msView.setCardInfo(cardInfo: json)
                        }
                    }
                }
            }
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
        navigationItem.titleLabel.text = "EV Infra"
        self.navigationController?.isNavigationBarHidden = false
    }

    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }

    func searchZipCode() {
        print("PJS HERE1")
        let saVC = storyboard?.instantiateViewController(withIdentifier: "SearchAddressViewController") as! SearchAddressViewController
        saVC.searchAddressDelegate = self
        navigationController?.push(viewController: saVC)
    }
    
    func verifyMemgberInfo(params: [String : String]) {
        
        guard let name = params["mb_name"],  let address = params["addr"], let detail_address = params["addr_detail"] else{
            Snackbar().show(message: "서비스 연결상태가 좋지 않습니다.\n잠시 후 다시 시도해 주세요.")
            return
        }
        self.memberData = params
        var actions = Array<UIAlertAction>()
        let ok = UIAlertAction(title: "확인", style: .default, handler:{ (ACTION) -> Void in
            self.checkPaymentCardStatus()
        })
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler:{ (ACTION) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        actions.append(ok)
        actions.append(cancel)
        let msg = " \(name) \n \(address) \n \(detail_address) \n 위주소로 회원카드를 발급하시겠습니까?"
        UIAlertController.showAlert(title: "알림", message: msg, actions: actions)
    }
    
    
    func checkPaymentCardStatus(){
        Server.getPayRegisterStatus { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let payCode = json["pay_code"].intValue
                switch(payCode){
                    case PaymentCard.PAY_NO_USER, PaymentCard.PAY_NO_CARD_USER:
                        print("PJS payCOde HERE 3");
                        self.moveToMyPaytRegist()
                        break;
                    case PaymentCard.PAY_DEBTOR_USER, PaymentCard.PAY_NO_VERIFY_USER, PaymentCard.PAY_DELETE_FAIL_USER:
                        let ok = UIAlertAction(title: "확인", style: .default, handler:{ (ACTION) -> Void in
                            self.navigationController?.pop()
                        })
                        var actions = Array<UIAlertAction>()
                        actions.append(ok)
                        UIAlertController.showAlert(title: "알림", message: json["ResultMsg"].stringValue, actions: actions)

                    case PaymentCard.PAY_FINE_USER:
                        Server.getPayRegisterInfo { (isSuccess, value) in
                            if isSuccess {
                                if let data = self.memberData{
                                    self.applyMembershipCard(params: data)
                                }else{
                                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
                                }
                                
                            }else {
                                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
                            }
                        }
                    case PaymentCard.PAY_REGISTER_FAIL_PG:
                        Snackbar().show(message: "서비스 연결상태가 좋지 않습니다.\n잠시 후 다시 시도해 주세요.")
                        

                    default:
                        break;
                }
                
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            }
        }
    }
    
    func applyMembershipCard(params: [String : String]) {
        print("PJS HERE!")
        Server.registerMembershipCard(values: params, completion: {(isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                switch (json["code"].stringValue){
                    case "1000":
                        
                        break
                    case "1101":
                        break
                    
                    default:
                        print("default")
                }
                
            }
            
        })
    }
    
    func moveToMyPaytRegist(){
        let payRegistVC = self.storyboard?.instantiateViewController(withIdentifier: "MyPayRegisterViewController") as! MyPayRegisterViewController
        payRegistVC.myPayRegisterViewDelegate = self
        navigationController?.push(viewController: payRegistVC)
    }
    
    func showValidateFailMsg(msg: String) {
        Snackbar().show(message: msg)
    }
    
    @objc
    fileprivate func handleTap(recognizer: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    // MARK: - KeyBoardHeight
    @objc func keyboardWillShow(_ notification: Notification) {
        print("Keyboard Show View is \(String(describing: type(of: self.membershipIssuanceView)))")
        if let msView = self.membershipIssuanceView {
            if  String(describing: type(of: msView)).elementsEqual("MembershipIssuanceView"){
                if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardRectangle = keyboardFrame.cgRectValue
                    let keyboardHeight = keyboardRectangle.height + CGFloat(16.0)
                    msView.showKeyBoard(keyboardHeight: keyboardHeight)
                }
            }
            
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        print("Keyboard Hide View is \(String(describing: type(of: self.membershipIssuanceView)))")
        if let msView = self.membershipIssuanceView {
            if  String(describing: type(of: msView)).elementsEqual("MembershipIssuanceView"){
                if let _: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                    msView.hideKeyBoard()
                }
            }
            
        }
//        self.scrollViewBottom.constant = 10
//        //self.scrollView.contentSize.height = scrollViewHeight
//        scrollViewUpdate()
//        self.scrollView.scrollToBottom()
    }
    
    
    func recieveAddressInfo(zonecode: String, fullRoadAddr: String) {
        print("PJS recieveAddressInfo \(zonecode)")
        if let msView = self.membershipIssuanceView {
            if  String(describing: type(of: msView)).elementsEqual("MembershipIssuanceView"){
                msView.tfZipCode.text = zonecode
                msView.tfIssuanceAddress.text = fullRoadAddr
            }
            
        }
    }
    
    func finishRegisterResult(json: JSON) {
        if (json["code"].intValue == PaymentCard.PAY_REGISTER_SUCCESS){
            if let params = self.memberData{
                applyMembershipCard(params: params)
            }else{
                Snackbar().show(message: "회원정보를 다시 입력해 주세요.")
            }
            
        }else{
            if(json["resultMsg"].stringValue.isEmpty){
                Snackbar().show(message: "카드 등록을 실패하였습니다. 다시 시도해 주세요.")
            }else{
                Snackbar().show(message: json["resultMsg"].stringValue)
            }
        }
        
    }
    
   
}

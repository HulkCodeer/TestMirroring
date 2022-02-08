//
//  MembershipInfoViewController.swift
//  evInfra
//
//  Created by SH on 2020/10/07.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import SwiftyJSON
import Material
import UIKit
class MembershipInfoViewController: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var btnModify: UIButton!
    
    @IBOutlet var tfCurPwIn: HSUnderLineTextField!
    @IBOutlet var tfPwIn: HSUnderLineTextField!
    @IBOutlet var tfPwReIn: HSUnderLineTextField!
    @IBOutlet var lbCardStatus: UILabel!
    @IBOutlet var lbCardNo: UILabel!
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    var activeTextView: Any? = nil
    
    @IBOutlet var bottomOfScrollView: NSLayoutConstraint!
    var memberInfo : MemberPartnershipInfo?
    
    @IBAction func onClickModifyBtn(_ sender: Any) {
        print("click modify")
        self.changePassword()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initView() {
        indicator.isHidden = true
        btnModify.layer.cornerRadius = 4
        let str = memberInfo?.cardNo!.replaceAll(of : "(\\d{4})(?=\\d)", with : "$1-");
        lbCardNo.text = str
        lbCardStatus.text = getCardStatusToString(status: memberInfo!.status!)
        let tap_touch = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        view.addGestureRecognizer(tap_touch)
        
    }
    
    func prepareActionBar() {
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "회원카드 관리"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    func setCardInfo(info : MemberPartnershipInfo) {
        self.memberInfo = info
    }
    
    func getCardStatusToString(status: String) -> String {
        switch (status) {
        case "0":
            return "발급 신청";
        case "1":
            return "발급 완료";
        case "2":
            return "카드 분실";
        default:
            return "상태 오류";
        }
    }
    
    // MARK: - KeyBoardHeight
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let contentInsert = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        scrollView.contentInset = contentInsert
        scrollView.scrollIndicatorInsets = contentInsert
        
        if let active = activeTextView {
            if active is UITextView {
                self.scrollView.scrollToView(view: (active as! UIView).superview!)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextView = textField
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextView = nil
    }
    
    
    @objc
    fileprivate func handleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func changePassword() {
        var chgPwParams = [String: Any]()
        do {
            chgPwParams["cur_pw"] = try tfCurPwIn.validatedText(validationType: .password)
            chgPwParams["new_pw"] = try tfPwIn.validatedText(validationType: .password)
            _ = try tfPwReIn.validatedText(validationType: .repassword(password: tfPwIn.text ?? "0000"))
            chgPwParams["card_no"] = memberInfo?.cardNo
            chgPwParams["mb_id"] = MemberManager.getMbId()
            showProgress()
            Server.changeMembershipCardPassword(values: chgPwParams, completion: {(isSuccess, value) in
                self.hideProgress()
                if isSuccess {
                    let json = JSON(value)
                    switch json["code"].stringValue {
                        case "1000":
                            let message = "비밀번호가 변경되었습니다."
                            let ok = UIAlertAction(title: "확인", style: .default, handler:{ (ACTION) -> Void in
                                self.navigationController?.pop()
                            })
                            var actions = Array<UIAlertAction>()
                            actions.append(ok)
                            UIAlertController.showAlert(title: "알림", message: message, actions: actions)
                            break
                        case "1103":
                            let ok = UIAlertAction(title: "확인", style: .default, handler:{ (ACTION) -> Void in
                            })
                            var actions = Array<UIAlertAction>()
                            actions.append(ok)
                            UIAlertController.showAlert(title: "알림", message: json["msg"].stringValue, actions: actions)
                            break
                        default:
                            print("default")
                            break
                    }
                } else {
                    Snackbar().show(message: "서버통신 오류")
                }
            })
        } catch (let error) {
            Snackbar().show(message: (error as! ValidationError).message)
        }
    }
    
    func showProgress() {
        indicator.isHidden = false
        indicator.startAnimating()
        btnModify.isEnabled = false;
        self.view.endEditing(true)
    }
    
    func hideProgress() {
        indicator.stopAnimating()
        indicator.isHidden = true
        btnModify.isEnabled = true
    }
}

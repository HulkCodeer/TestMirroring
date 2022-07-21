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
import RxSwift
import RxCocoa

internal final class MembershipInfoViewController: BaseViewController {
    
    // MARK: UI
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var btnModify: UIButton!
    
    @IBOutlet var tfCurPwIn: UITextField!
    @IBOutlet var tfPwIn: UITextField!
    @IBOutlet var tfPwReIn: UITextField!
    @IBOutlet var lbCardStatus: UILabel!
    @IBOutlet var lbCardNo: UILabel!
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    var activeTextView: Any? = nil
    
    @IBOutlet var bottomOfScrollView: NSLayoutConstraint!
    @IBAction func onClickModifyBtn(_ sender: Any) {
        self.changePassword()
    }
    @IBOutlet var currentPwErrorLbl: UILabel!
    @IBOutlet var newPwErrorLbl: UILabel!
    @IBOutlet var newPwConfirmErrorLbl: UILabel!
    
    // MARK: VARIABLE
    
    internal var memberInfo : MemberPartnershipInfo?
    
    // MARK: SYSTEM FUNC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        initView()
        
        Observable.combineLatest(tfPwIn.rx.text,
                         tfCurPwIn.rx.text,
                         tfPwReIn.rx.text)
            .map { tfPwIn, tfCurPwIn, tfPwReIn in
                guard let _tfPwIn = tfPwIn,
                      let _tfCurPwIn = tfCurPwIn,
                      let _tfPwReIn = tfPwReIn else { return false }
                                                                                
                return !_tfPwIn.isEmpty && !_tfCurPwIn.isEmpty && !_tfPwReIn.isEmpty
            }
            .bind(to: btnModify.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initView() {
        guard let _memberInfo = self.memberInfo else { return }
        indicator.isHidden = true
        btnModify.layer.cornerRadius = 4
        
        lbCardNo.text = _memberInfo.displayCardNo
        lbCardStatus.text = _memberInfo.displayStatusDescription
        
        let tap_touch = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        view.addGestureRecognizer(tap_touch)        
        
        btnModify.setBackgroundColor(Colors.backgroundDisabled.color, for: .disabled)
        btnModify.setBackgroundColor(Colors.gr5.color, for: .normal)
        
        btnModify.setTitleColor(Colors.contentDisabled.color, for: .disabled)
        btnModify.setTitleColor(Colors.contentPrimary.color, for: .normal)
        
        btnModify.isEnabled = false
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "회원카드 상세"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    func setCardInfo(info : MemberPartnershipInfo) {
        self.memberInfo = info
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
            chgPwParams["mb_id"] = MemberManager.shared.mbId
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

extension MembershipInfoViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {                        
        switch textField {
        case tfPwIn:
            guard !string.isEmpty else { return true }
            let text = textField.text ?? ""
            return text.count < 4
            
        case tfCurPwIn:
            guard !string.isEmpty else { return true }
            let text = textField.text ?? ""
            return text.count < 4
            
        case tfPwReIn:
            guard !string.isEmpty else { return true }
            let text = textField.text ?? ""
            return text.count < 4
            
        default: break
        }
        
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {                        
        switch textField {
        case tfCurPwIn:
            do {
                _ = try tfCurPwIn.validatedText(validationType: .password)
            } catch {
                currentPwErrorLbl.isHidden = false
                currentPwErrorLbl.text = (error as! ValidationError).message
            }
            
        case tfPwIn:
            
            do {
                _ = try tfPwIn.validatedText(validationType: .password)
            } catch {
                newPwErrorLbl.isHidden = false
                newPwErrorLbl.text = (error as! ValidationError).message
            }
            
        case tfPwReIn:
            do {
                _ = try tfPwReIn.validatedText(validationType: .repassword(password: tfPwIn.text ?? "0000"))
            } catch {
                newPwConfirmErrorLbl.isHidden = false
                newPwConfirmErrorLbl.text = (error as! ValidationError).message
            }
            
        default: break
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case tfCurPwIn:
            currentPwErrorLbl.text = ""
            currentPwErrorLbl.isHidden = true
            
        case tfPwIn:
            newPwErrorLbl.text = ""
            newPwErrorLbl.isHidden = true
            
        case tfPwReIn:            
            newPwConfirmErrorLbl.text = ""
            newPwConfirmErrorLbl.isHidden = true
            
        default: break
        }
    }
}

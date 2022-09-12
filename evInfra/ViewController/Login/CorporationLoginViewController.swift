//
//  CorporationLoginViewController.swift
//  evInfra
//
//  Created by SH on 2022/01/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol CorporationLoginViewControllerDelegate {
    func successSignUp()
}
class CorporationLoginViewController: UIViewController {
    @IBOutlet weak var tfCorpId: UITextField!
    @IBOutlet weak var tfCorpPwd: UITextField!
    
    var delegate: CorporationLoginViewControllerDelegate?
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfCorpId.delegate = self
        tfCorpPwd.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
        tfCorpPwd.isSecureTextEntry = true
    }
    
    
    @objc
    fileprivate func handleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func onClickLogin(_ sender: Any) {
        trySignUp()
    }
    
    func trySignUp() {
        if let id = tfCorpId.text, !id.isEmpty, id.count > 5 {
            if let pwd = tfCorpPwd.text, !pwd.isEmpty, pwd.count > 5 {
                Server.loginWithID(id: id, pwd: pwd) { (isSuccess, value) in
                    if isSuccess {
                        let json = JSON(value)
                        if json["code"].intValue != 1000 {
                            Snackbar().show(message: json["msg"].stringValue)
                        } else {
                            Snackbar().show(message: "로그인 성공")
                            MemberManager.shared.setData(data: json)
                            
                            CorpLoginEvent.complteLogin.logEvent()
                            
                            GlobalDefine.shared.mainNavi?.pop()
                            if let delegate = self.delegate {
                                delegate.successSignUp()
                            }
                        }
                    }
                }
            } else {
                Snackbar().show(message: "비밀번호를 6자 이상 입력해주세요")
            }
        } else {
            Snackbar().show(message: "아이디를 6자 이상 입력해주세요")
        }
    }
}

extension CorporationLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfCorpId {
            tfCorpPwd.becomeFirstResponder()
        } else if textField == tfCorpPwd {
            tfCorpPwd.resignFirstResponder()
            view.endEditing(true)
        }
        return true
    }
}

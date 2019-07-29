//
//  LoginViewController.swift
//  evInfra
//
//  Created by Shin Park on 2018. 8. 6..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON

class LoginViewController: UIViewController {

    @IBAction func login(_ sender: Any) {
        let session: KOSession = KOSession.shared();
        
        if session.isOpen() {
            session.close()
        }
        
        session.open(completionHandler: { (error) -> Void in
            
            if !session.isOpen() {
                if let error = error as NSError? {
                    switch error.code {
                    case Int(KOErrorCancelled.rawValue):
                        break
                    default:
                        UIAlertController.showMessage(error.description)
                    }
                }
            } else {
                self.requestMe()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareActionBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if KOSession.shared().isOpen() {
            requestMe()
        }
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "로그인"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    fileprivate func requestMe() {
        // 사용자 정보 요청
        KOSessionTask.userMeTask { [weak self] (error, me) in
            if let error = error as NSError? {
                UIAlertController.showMessage(error.description)
            } else if let me = me as KOUserMe? {
                UserDefault().saveString(key: UserDefault.Key.MB_USER_ID, value: me.id!)
                if me.hasSignedUp == .false {
                    self?.requestSignUpToKakao()
                } else {
                    self?.requestLoginToEvInfra(me: me)
                }
            }
        }
    }
    
    fileprivate func requestSignUpToKakao() {
        KOSessionTask.signupTask(withProperties: nil, completionHandler: { [weak self] (success, error) -> Void in
            if let error = error as NSError? {
                UIAlertController.showMessage(error.description)
            } else {
                self?.requestMe()
            }
        })
    }
    
    fileprivate func requestLoginToEvInfra(me: KOUserMe) {
        Server.login { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["result_code"].stringValue.elementsEqual("1000") {
                    self.successLogin(json: json)
                } else {
                    self.showSignUp(me: me)
                }
            }
        }
    }
    
    fileprivate func successLogin(json: JSON) {
        Snackbar().show(message: "로그인 성공")
        MemberManager().setData(data: json)
        
        // get favorite
        ChargerListManager.sharedInstance.getFavoriteCharger()

        self.navigationController?.pop()
    }
    
    fileprivate func showSignUp(me: KOUserMe) {
        if let me = me as KOUserMe? {
            let signUpVc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            signUpVc.me = me
            self.navigationController?.push(viewController: signUpVc)
        } else {
            Snackbar().show(message: "요류가 발생했습니다. 다시 시도해 주세요.")
            self.navigationController?.pop()
        }
    }
}

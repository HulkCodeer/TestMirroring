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
import AuthenticationServices // apple login

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButtonStackView: UIStackView!
    @IBOutlet weak var btnKakaoLogin: KOLoginButton!
    @IBOutlet weak var btnCorpLogin: UIButton!
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        prepareLoginButton()
        LoginHelper.shared.delegate = self
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "로그인"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareLoginButton() {
        // 카카오 로그인 버튼
        btnKakaoLogin.addTarget(self, action: #selector(handleKakaoButtonPress), for: .touchUpInside)
        
        btnCorpLogin.layer.borderColor = UIColor(named: "content-primary")?.cgColor
        btnCorpLogin.layer.borderWidth = 1
        btnCorpLogin.layer.cornerRadius = 8
        btnCorpLogin.addTarget(self, action: #selector(handleCorpButtonPress), for: .touchUpInside)
        
        // Apple ID 로그인 버튼
        if #available(iOS 13.0, *) {
            let btnAppleLogin = ASAuthorizationAppleIDButton()            
            btnAppleLogin.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
            self.loginButtonStackView.addArrangedSubview(btnAppleLogin)
        }
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    @objc
    fileprivate func handleKakaoButtonPress() {
        LoginHelper.shared.kakaoLogin()
    }
    
    @available(iOS 13.0, *)
    @objc
    fileprivate func handleAuthorizationAppleIDButtonPress() {
        LoginHelper.shared.appleLogin()
    }
    
    @objc
    fileprivate func handleCorpButtonPress() {
        corpLogin()
    }
}

extension LoginViewController: LoginHelperDelegate {
    var loginViewController: UIViewController {
        return self
    }
    
    func successLogin() {
        Snackbar().show(message: "로그인 성공")
                
        if Const.CLOSED_BETA_TEST {
            CBT.checkCBT(vc: self)
        }

        self.navigationController?.pop()
    }
    
    func needSignUp(user: Login) {
        let LoginStoryboard = UIStoryboard(name : "Login", bundle: nil)
        let acceptTermsVc = LoginStoryboard.instantiateViewController(withIdentifier: "AcceptTermsViewController") as! AcceptTermsViewController
        acceptTermsVc.user = user
        acceptTermsVc.delegate = self
        self.navigationController?.push(viewController: acceptTermsVc)
    }
    
    func corpLogin() {
        let LoginStoryboard = UIStoryboard(name : "Login", bundle: nil)
        let signUpVc = LoginStoryboard.instantiateViewController(withIdentifier: "CorporationLoginViewController") as! CorporationLoginViewController
        signUpVc.delegate = self
        self.navigationController?.push(viewController: signUpVc)
    }
}

extension LoginViewController: AcceptTermsViewControllerDelegate {
    func onSignUpDone() {
        self.navigationController?.pop()
    }
}

extension LoginViewController: CorporationLoginViewControllerDelegate {
    func successSignUp() {
        self.navigationController?.pop()
    }
}




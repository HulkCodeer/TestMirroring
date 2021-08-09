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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareLoginButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        LoginHelper.shared.delegate = self
        LoginHelper.shared.checkLogin()
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
    
    func prepareLoginButton() {
        // 카카오 로그인 버튼
        btnKakaoLogin.addTarget(self, action: #selector(handleKakaoButtonPress), for: .touchUpInside)
        
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
}

extension LoginViewController: LoginHelperDelegate {
    var loginViewController: UIViewController {
        return self
    }
    
    func successLogin() {
        Snackbar().show(message: "로그인 성공")
        
        // get favorite
        ChargerManager.sharedInstance.getFavoriteCharger()
        
        if Const.CLOSED_BETA_TEST {
            CBT.checkCBT(vc: self)
        }

        self.navigationController?.pop()
    }
    
    func needSignUp(user: Login) {
        let LoginStoryboard = UIStoryboard(name : "Login", bundle: nil)
        let signUpVc = LoginStoryboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        signUpVc.delegate = self
        signUpVc.user = user
        self.navigationController?.push(viewController: signUpVc)
    }
}

extension LoginViewController: SignUpViewControllerDelegate {
    func cancelSignUp() {
        self.navigationController?.pop()
    }
}

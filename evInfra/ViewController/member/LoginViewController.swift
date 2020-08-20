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

    @IBAction func kakaoLogin(_ sender: Any) {
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
        
        prepareActionBar()
        prepareLoginButton()
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
    
    func prepareLoginButton() {
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
    
    @available(iOS 13.0, *)
    @objc
    fileprivate func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
              
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
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
                if json["code"].intValue == 1000 {
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
        ChargerManager.sharedInstance.getFavoriteCharger()
        
        if Const.CLOSED_BETA_TEST {
            CBT.checkCBT(vc: self)
        }

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

// check if the user has an existing account by requesting both an Apple ID and an iCloud keychain password
@available(iOS 13.0, *)
extension LoginViewController {
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            print("Apple sign in - user: \(userIdentifier), fullName: \(String(describing: fullName ?? nil)), email: \(email ?? "")")
            
            // optional, might be nil
            let givenName = appleIDCredential.fullName?.givenName
            let familyName = appleIDCredential.fullName?.familyName
            let nickName = appleIDCredential.fullName?.nickname
            
            print("Apple sign in - givenName: \(givenName ?? ""), familyName: \(familyName ?? "")), nickName: \(nickName ?? "")")
            
            /*
                useful for server side, the app can send identityToken and authorizationCode
                to the server for verification purpose
            */
            var identityToken : String?
            if let token = appleIDCredential.identityToken {
                identityToken = String(bytes: token, encoding: .utf8)
            }
            print("Apple sign in - identityToken: \(String(describing: identityToken))")

            var authorizationCode : String?
            if let code = appleIDCredential.authorizationCode {
                authorizationCode = String(bytes: code, encoding: .utf8)
            }
            print("Apple sign in - authorizationCode: \(String(describing: authorizationCode))")
            
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            // TODO UserDefaults에 저장한 후 AppDelegate에서 불러와서 사용해야 하나?
//            self.saveUserInKeychain(userIdentifier)
            
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
//            self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
        
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print("Apple login - username: \(username), password: \(password)")
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
//                self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // handle error
        print("Apple login authorization error")
        guard let error = error as? ASAuthorizationError else {
            return
        }

        switch error.code {
        case .canceled: // user press "cancel" during the login prompt
            print("Canceled")
            
        case .unknown: // user didn't login their Apple ID on the device
            print("Unknown")
            
        case .invalidResponse: // invalid response received from the login
            print("Invalid Respone")
            
        case .notHandled: // authorization request not handled, maybe internet failure during login
            print("Not handled")
            
        case .failed: // authorization failed
            print("Failed")
            
        @unknown default:
            print("Default")
        }
    }
}

@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

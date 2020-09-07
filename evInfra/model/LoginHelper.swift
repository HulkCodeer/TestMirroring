//
//  LoginHelper.swift
//  evInfra
//
//  Created by Shin Park on 2020/09/01.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON
import AuthenticationServices // apple login

protocol LoginHelperDelegate: class {
    var loginViewController: UIViewController { get }
    
    func successLogin(json: JSON)
    func needSignUp(user: Login)
}

class LoginHelper: NSObject {
    weak var delegate: LoginHelperDelegate?
    
    static let shared = LoginHelper()
    
    // 로그인 확인
    func loginCheck() {
        switch MemberManager.getLoginType() {
        case .apple:
            evInfraLogin()
            
        case .kakao:
            if KOSession.shared().isOpen() {
                requestMe()
            }
        }
    }
    
    // 카카오 로그인
    func kakaoLogin() {
        if KOSession.shared().isOpen() {
            KOSession.shared().close()
        }
        
        KOSession.shared().open(completionHandler: { (error) -> Void in
            
            if !KOSession.shared().isOpen() {
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
    
    // 애플 로그인
    @available(iOS 13.0, *)
    func appleLogin() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // ev infra 로그인
    func evInfraLogin() {
        Server.login { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].intValue == 1000 {
                    if let delegate = self.delegate {
                        delegate.successLogin(json: json)
                    }
                }
            } else {
                Snackbar().show(message: "오류가 발생했습니다. 다시 시도해 주세요.")
            }
        }
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
                    self?.requestLoginToEvInfra(user: Login.kakao(me))
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    fileprivate func performExistingAccountSetupFlows() {
      // Prepare requests for both Apple ID and password providers.
      let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                      ASAuthorizationPasswordProvider().createRequest()]
            
      // Create an authorization controller with the given requests.
      let authorizationController = ASAuthorizationController(authorizationRequests: requests)
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
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
    
    fileprivate func requestLoginToEvInfra(user: Login) {
        Server.login { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].intValue == 1000 {
                    if let delegate = self.delegate {
                        delegate.successLogin(json: json)
                    }
                } else {
                    if let delegate = self.delegate {
                        delegate.needSignUp(user: user)
                    }
                }
            } else {
                Snackbar().show(message: "오류가 발생했습니다. 다시 시도해 주세요.")
            }
        }
    }
}

@available(iOS 13.0, *)
extension LoginHelper: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            UserDefault().saveString(key: UserDefault.Key.MB_USER_ID, value: appleIDCredential.user)
            self.requestLoginToEvInfra(user: Login.apple(appleIDCredential))
            
        default:
            Snackbar().show(message: "요류가 발생했습니다. 다시 시도해 주세요.")
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // handle error
        guard let error = error as? ASAuthorizationError else {
            return
        }

        switch error.code {
        case .canceled: // user press "cancel" during the login prompt
            print("didCompleteWithError - Canceled")
            
        case .unknown: // user didn't login their Apple ID on the device
            print("didCompleteWithError - Unknown")
            
        case .invalidResponse: // invalid response received from the login
            print("didCompleteWithError - Invalid Respone")
            
        case .notHandled: // authorization request not handled, maybe internet failure during login
            print("didCompleteWithError - Not handled")
            
        case .failed: // authorization failed
            print("didCompleteWithError - Failed")
            
        @unknown default:
            print("didCompleteWithError - Default")
        }
    }
}

@available(iOS 13.0, *)
extension LoginHelper: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return (delegate?.loginViewController.view.window!)!
    }
}

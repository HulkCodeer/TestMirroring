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
    
    func successLogin()
    func needSignUp(user: Login)
}

class LoginHelper: NSObject {

    weak var delegate: LoginHelperDelegate?
    
    static let shared = LoginHelper()
    
    // 앱 실행 시 로그인 확인
    func prepareLogin() {
        switch MemberManager.getLoginType() {
        case .apple:
            // Apple 로그인 상태 확인
            requestLoginToApple()
            
        case .kakao:
            // 로그인, 로그아웃 상태 변경 받기
            NotificationCenter.default.addObserver(self, selector: #selector(kakaoSessionDidChangeWithNotification), name: NSNotification.Name.KOSessionDidChange, object: nil)
            
            // 클라이언트 시크릿 설정
            KOSession.shared().clientSecret = Const.KAKAO_CLIENT_SECRET
        case .corp:
            break;
        }
    }
    
    // 로그인 확인
    func checkLogin() {
        switch MemberManager.getLoginType() {
        case .apple:
            requestLoginToEvInfra(user: nil)
            
        case .kakao:
            if KOSession.shared().isOpen() {
                requestMeToKakao()
            }
        case .corp:
            requestLoginToEvInfra(user: nil)
        }
    }
    
    // 로그아웃
    func logout(completion: @escaping (Bool)->()) {
        switch MemberManager.getLoginType() {
        case .apple:
            MemberManager().clearData()
            completion(true)
            
        case .kakao:
            KOSession.shared().logoutAndClose { (success, error) -> Void in
                if success {
                    MemberManager().clearData()
                    completion(true)
                } else {
                    completion(false)
                }
            }
        case .corp:
            MemberManager().clearData()
            completion(true)
        }
    }

    // MARK: - Kakao
    func kakaoLogin() {
        if KOSession.shared().isOpen() {
            KOSession.shared().close()
        }
        
        KOSession.shared().open(completionHandler: { (error) -> Void in
            
            if KOSession.shared().isOpen() {
                self.requestMeToKakao()
            } else {
                if let error = error as NSError? {
                    switch error.code {
                    case Int(KOErrorCancelled.rawValue):
                        break
                    default:
                        UIAlertController.showMessage(error.description)
                    }
                }
            }
        })
    }
    
    @objc func kakaoSessionDidChangeWithNotification() {
        if KOSession.shared().isOpen() {
            // 사용자 정보 요청
            KOSessionTask.userMeTask { (error, me) in
                if (error as NSError?) != nil {
                    MemberManager().clearData() // 비회원
                } else if let me = me as KOUserMe? {
                    if me.hasSignedUp == .true {
                        UserDefault().saveString(key: UserDefault.Key.MB_USER_ID, value: me.id!)
                        
                        self.requestLoginToEvInfra(user: nil)
                    }
                }
            }
        }
    }
    
    // 카카오에게 사용자 정보 요청
    fileprivate func requestMeToKakao() {
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
    
    fileprivate func requestSignUpToKakao() {
        KOSessionTask.signupTask(withProperties: nil, completionHandler: { [weak self] (success, error) -> Void in
            if let error = error as NSError? {
                UIAlertController.showMessage(error.description)
            } else {
                self?.requestMeToKakao()
            }
        })
    }
    
    // MARK: - Apple ID
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
    
    fileprivate func requestLoginToApple() {
        if #available(iOS 13.0, *) {
            let userIdentifier = UserDefault().readString(key: UserDefault.Key.MB_USER_ID)
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userIdentifier) { (credentialState, error) in
                switch credentialState {
                case .authorized:
                    self.requestLoginToEvInfra(user: nil)
                    break // The Apple ID credential is valid.
                case .revoked, .notFound, .transferred:
                    print("requestLoginToApple - revoked, notFound, transferred")
                    break
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - EV Infra 로그인 및 회원가입
    func requestLoginToEvInfra(user: Login?) {
        Server.login { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].intValue == 1000 {
                    if let delegate = self.delegate {
                        delegate.successLogin()
                    }
                    MemberManager().setData(data: json)
                } else {
                    if let delegate = self.delegate, let user = user {
                        delegate.needSignUp(user: user) // ev infra 회원가입
                    }
                    MemberManager().clearData()
                }
            } else {
                MemberManager().clearData()
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
            Snackbar().show(message: "오류가 발생했습니다. 다시 시도해 주세요.")
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

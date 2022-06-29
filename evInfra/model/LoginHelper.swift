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
import RxSwift

protocol LoginHelperDelegate: class {
    var loginViewController: UIViewController { get }
    
    func successLogin()
    func needSignUp(user: Login)
}

internal final class LoginHelper: NSObject {

    internal weak var delegate: LoginHelperDelegate?
    
    static let shared = LoginHelper()
    
    private let disposebag = DisposeBag()
    
    // 앱 실행 시 로그인 확인
    func prepareLogin() {
        switch MemberManager.shared.loginType {
        case .apple:
            // Apple 로그인 상태 확인
            requestLoginToApple()
            
        case .kakao:
            // 로그인, 로그아웃 상태 변경 받기
            NotificationCenter.default.addObserver(self, selector: #selector(kakaoSessionDidChangeWithNotification), name: NSNotification.Name.KOSessionDidChange, object: nil)
            
            // 클라이언트 시크릿 설정
            KOSession.shared().clientSecret = Const.KAKAO_CLIENT_SECRET
        case .evinfra:
            break
        default:
            break
        }
    }
    
    // 로그인 확인
    func checkLogin() {
        switch MemberManager.shared.loginType {
        case .apple:
            requestLoginToApple()
            
        case .kakao:
            if KOSession.shared().isOpen() {
                requestMeToKakao()
            } else {
                MemberManager.shared.clearData()
            }
            
        case .evinfra:
            requestLoginToEvInfra(user: nil)
            
        default:
            MemberManager.shared.clearData()
        }
    }
    
    // 로그아웃
    func logout(completion: @escaping (Bool)->()) {
        switch MemberManager.shared.loginType {
        case .apple:
            MemberManager.shared.clearData()
            completion(true)
            
        case .kakao:
            KOSession.shared().logoutAndClose { (success, error) -> Void in
                if success {
                    MemberManager.shared.clearData()
                    completion(true)
                } else {
                    completion(false)
                }
            }
        case .evinfra:
            MemberManager.shared.clearData()
            completion(true)
        default:
            MemberManager.shared.clearData()
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
                    MemberManager.shared.clearData() // 비회원
                } else if let me = me as KOUserMe? {
                    UserDefault().saveString(key: UserDefault.Key.MB_USER_ID, value: me.id!)
                    if me.hasSignedUp == .true {
                        self.ifNeedUpdateScope(me: me)
                    }
                }
            }
        }
    }
    
    // 카카오에게 사용자 정보 요청
    fileprivate func requestMeToKakao() {
        KOSessionTask.userMeTask { [weak self] (error, me) in
            if (error as NSError?) != nil {
                MemberManager.shared.clearData()
            } else if let me = me as KOUserMe? {
                UserDefault().saveString(key: UserDefault.Key.MB_USER_ID, value: me.id!)
                if me.hasSignedUp == .false {
                    self?.requestSignUpToKakao()
                } else {
                    self?.ifNeedUpdateScope(me: me)
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
    
    
    func ifNeedUpdateScope(me: KOUserMe) {
        if let account = me.account {
            var scopes = [String]()
            if account.needsScopeAccountEmail() {
                scopes.append("account_email");
            }
            if account.needsScopePhoneNumber() {
                scopes.append("phone_number");
            }
            if account.needsScopeAgeRange() {
                scopes.append("age_range");
            }
            if account.needsScopeGender() {
                scopes.append("gender");
            }
            if !scopes.isEmpty {
                let ok = UIAlertAction(title: "다음", style: .default, handler: {(ACTION) -> Void in
                    KOSession.shared().updateScopes(scopes, completionHandler: { (error) in
                        guard error == nil else {
                            self.requestLoginToEvInfra(user: Login.kakao(me))
                            return
                        }
                        
                        self.requestMeToKakao()
                    })
                })
                
                var actions = Array<UIAlertAction>()
                actions.append(ok)
                UIAlertController.showAlert(title: "개인정보 동의 안내", message: "더 나은 서비스 운영을 위한 추가적인 개인정보 수집 동의가 필요합니다. 각 수집 사유 및 사용 용도는 다음 화면에서 확인 가능합니다.", actions: actions)
            } else {
                self.requestLoginToEvInfra(user: Login.kakao(me))
            }
        }
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
            let userIdentifier = MemberManager.shared.userId
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userIdentifier) { (credentialState, error) in
                printLog(out: "CredentialState : \(credentialState)")
                switch credentialState {
                case .authorized:
                    self.requestLoginToEvInfra(user: nil)
                    
                case .revoked, .notFound, .transferred:
                    MemberManager.shared.clearData()
                                                        
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - EV Infra 로그인 및 회원가입
    func requestLoginToEvInfra(user: Login?) {
        Server.login(user: user) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                printLog(out: "Sever Login : \(json)")
                if json["code"].intValue == 1000 {
                    if let delegate = self.delegate {
                        delegate.successLogin()
                    }
                    MemberManager.shared.setData(data: json)
                    // 즐겨찾기 목록 가져오기
                    ChargerManager.sharedInstance.getFavoriteCharger()                    
                } else {
                    if let delegate = self.delegate, let user = user {
                        delegate.needSignUp(user: user) // ev infra 회원가입
                    }
                    MemberManager.shared.clearData()
                }
            } else {
                MemberManager.shared.clearData()
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
            printLog(out: "User ID : \(appleIDCredential.user)")
            printLog(out: "AuthorizationCode ID : \( String(describing: String(data: appleIDCredential.authorizationCode ?? Data(), encoding: .utf8)))")
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

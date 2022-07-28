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
import Material

protocol LoginHelperDelegate: class {
    var loginViewController: UIViewController { get }
    
    func successLogin()
    func needSignUp(user: Login)
}

internal final class LoginHelper: NSObject {
    static let shared = LoginHelper()
    
    internal weak var delegate: LoginHelperDelegate?
    
    private let disposebag = DisposeBag()
    private let amplitudeManager = AmplitudeManager.shared
    
    
    // 추후에 다시 넣어서 테스트 해봐야함
    // KOSession 실행시 사용자 추가 정보 동의 팝업을 열 수 있는지 체크 해야됨
//    // 앱 실행 시 카카오 로그인 세션 정보를 받기 위해 셋팅
//    func prepareLogin() {
//        switch MemberManager.shared.loginType {
//        case .kakao:
//            // 로그인, 로그아웃 상태 변경 받기
//            NotificationCenter.default.addObserver(self, selector: #selector(kakaoSessionDidChangeWithNotification), name: NSNotification.Name.KOSessionDidChange, object: nil)
//
//            // 클라이언트 시크릿 설정
//            KOSession.shared().clientSecret = Const.KAKAO_CLIENT_SECRET
//        default: break
//        }
//    }
    
    // 메인 화면에서 지도의 정보를 불러온 뒤 로그인 체크
    func checkLogin() {
        switch MemberManager.shared.loginType {
        case .apple:
            guard !MemberManager.shared.appleRefreshToken.isEmpty else {
                LoginHelper.shared.logout(completion: {_ in 
                    Snackbar().show(message: "서비스 내 정책변경으로 로그아웃 되었습니다. 원활한 서비스 이용을 위해 다시 로그인을 해주세요.")
                })
                return
            }
            
            self.requestLoginToApple()
                                                                            
        case .kakao:
            if KOSession.shared().isOpen() {
                requestMeToKakao()
            } else {
                MemberManager.shared.clearData()
            }
            
        case .evinfra:
            requestFromKakaoAndCompanyLoginToEvInfra(user: nil)
            
        default:
            MemberManager.shared.clearData()
        }
    }
    
    // 로그아웃
    func logout(completion: @escaping (Bool)->()) {
        self.amplitudeManager.setUser(with: nil)
        
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
                }
            }
        }
    }
    
    // 카카오에게 사용자 정보 요청
    fileprivate func requestMeToKakao() {
        KOSessionTask.userMeTask { [weak self] (error, me) in
            if (error as NSError?) != nil {
                Snackbar().show(message: "회원 탈퇴로 인해 로그아웃 되었습니다.")
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
                            self.requestFromKakaoAndCompanyLoginToEvInfra(user: Login.kakao(me))
                            return
                        }
                        
                        self.requestMeToKakao()
                    })
                })
                
                var actions = Array<UIAlertAction>()
                actions.append(ok)
                UIAlertController.showAlert(title: "개인정보 동의 안내", message: "더 나은 서비스 운영을 위한 추가적인 개인정보 수집 동의가 필요합니다. 각 수집 사유 및 사용 용도는 다음 화면에서 확인 가능합니다.", actions: actions)
            } else {
                self.requestFromKakaoAndCompanyLoginToEvInfra(user: Login.kakao(me))
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
                    self.requestFromAppleLoginToEvInfra(user: nil)
                    
                case .revoked, .notFound, .transferred:
                    Snackbar().show(message: "로그아웃 되었습니다.")
                    MemberManager.shared.clearData()
                                                        
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - EV Infra 로그인 및 회원가입
    func requestFromAppleLoginToEvInfra(user: Login?) {
        Server.login(user: user) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                printLog(out: "Sever Login : \(json)")
                if json["code"].intValue == 1000 {
                                                            
                    if let _user = user,
                            let _appleAuthorizationCode = _user.appleAuthorizationCode,
                          !_appleAuthorizationCode.isEmpty,
                          UserDefault().readString(key: UserDefault.Key.APPLE_REFRESH_TOKEN).isEmpty {
                    RestApi().postRefreshToken(appleAuthorizationCode: String(data: _appleAuthorizationCode, encoding: .utf8) ?? "" )
                        .observe(on: SerialDispatchQueueScheduler(qos: .background))
                        .convertData()
                        .compactMap { result -> String? in
                            switch result {
                            case .success(let data):
                                
                                var jsonData: JSON = JSON(JSON.null)
                                var jsonString: JSON = JSON(parseJSON: "")
                                do {
                                    jsonData = try JSON(data: data, options: .allowFragments)
                                    jsonString = JSON(parseJSON: jsonData.rawString() ?? "")
                                } catch let error {
                                    printLog(out: "Json Parse Error \(error.localizedDescription)")
                                }
                                                
                                printLog(out: "JsonData : \(jsonData)")

                                let refreshToken = jsonString["refresh_token"].stringValue
                                guard !refreshToken.isEmpty else {
                                    return nil
                                }
                                
                                return refreshToken
                                
                            case .failure(let errorMessage):
                                printLog(out: "Error Message : \(errorMessage)")
                                Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
                                return nil
                            }
                        }
                        .subscribe(onNext: { refreshToken in
                            guard refreshToken.isEmpty else {
                                if let delegate = self.delegate {
                                    delegate.successLogin()
                                }
                                
                                MemberManager.shared.setData(data: json)
                                self.amplitudeManager.setUser(with: UserDefault().readString(key: UserDefault.Key.MB_ID))
                                self.amplitudeManager.setUserProperty(user: _user)
                                
                                let property: [String: Any] = ["type": String(Login.LoginType.apple.description)]
                                self.amplitudeManager.logEvent(type: .login(.clickLoginButton), property: property)
                                self.amplitudeManager.logEvent(type: .login(.complteLogin), property: property)

                                // 즐겨찾기 목록 가져오기
                                ChargerManager.sharedInstance.getFavoriteCharger()
                                UserDefault().saveString(key: UserDefault.Key.APPLE_REFRESH_TOKEN, value: refreshToken)
                                return
                            }
                            LoginHelper.shared.logout(completion: { success in
                                if success {
                                    Snackbar().show(message: "로그아웃 되었습니다.")
                                }
                            })
                        })
                        .disposed(by: self.disposebag)
                    } else {
                        RestApi().postValidateRefreshToken()
                            .observe(on: SerialDispatchQueueScheduler(qos: .background))
                            .convertData()
                            .compactMap { result -> String? in
                                switch result {
                                case .success(let data):
                                    
                                    var jsonData: JSON = JSON(JSON.null)
                                    var jsonString: JSON = JSON(parseJSON: "")
                                    do {
                                        jsonData = try JSON(data: data, options: .allowFragments)
                                        jsonString = JSON(parseJSON: jsonData.rawString() ?? "")
                                    } catch let error {
                                        printLog(out: "Json Parse Error \(error.localizedDescription)")
                                    }
                                                    
                                    printLog(out: "JsonData : \(jsonData)")

                                    let accessToken = jsonString["access_token"].stringValue
                                    guard !accessToken.isEmpty else {
                                        return nil
                                    }
                                    
                                    return accessToken
                                    
                                case .failure(let errorMessage):
                                    printLog(out: "Error Message : \(errorMessage)")
                                    Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
                                    return nil
                                }
                            }
                            .subscribe(onNext: { accessToken in
                                guard accessToken.isEmpty else {
                                    if let delegate = self.delegate {
                                        delegate.successLogin()
                                    }
                                    MemberManager.shared.setData(data: json)
                                    self.amplitudeManager.setUser(with: UserDefault().readString(key: UserDefault.Key.MB_ID))
                                    self.amplitudeManager.setUserProperty(user: nil)
                                    
                                    let property: [String: Any] = ["type" : String(Login.LoginType.apple.description)]
                                    self.amplitudeManager.logEvent(type: .login(.clickLoginButton), property: property)
                                    self.amplitudeManager.logEvent(type: .login(.complteLogin), property: property)

                                    // 즐겨찾기 목록 가져오기
                                    ChargerManager.sharedInstance.getFavoriteCharger()
                                    return
                                }
                                LoginHelper.shared.logout(completion: { _ in
                                    Snackbar().show(message: "장기간 미접속으로 인해 로그아웃 되었습니다.")
                                })
                            })
                            .disposed(by: self.disposebag)
                    }
                    
                } else {
                    if let delegate = self.delegate, let user = user {
                        let property: [String: Any] = ["type": String(user.loginType.description)]
                        AmplitudeManager.shared.logEvent(type: .signup(.clickSignUpButton), property: property)
                        delegate.needSignUp(user: user) // ev infra 회원가입
                    }
                    MemberManager.shared.clearData()
                }
            } else {
                MemberManager.shared.clearData()
                self.amplitudeManager.setUser(with: nil)
                Snackbar().show(message: "오류가 발생했습니다. 다시 시도해 주세요.")
            }
        }
    }
    
    
    func requestFromKakaoAndCompanyLoginToEvInfra(user: Login?) {
        Server.login(user: user) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                printLog(out: "Sever Login : \(json)")
                if json["code"].intValue == 1000 {
                    
                    if let delegate = self.delegate {
                        delegate.successLogin()
                    }
                    
                    MemberManager.shared.setData(data: json)
                    self.amplitudeManager.setUser(with: UserDefault().readString(key: UserDefault.Key.MB_ID))
                    self.amplitudeManager.setUserProperty(user: user)
                    
                    var property = [String: Any]()
                    if let user = user {
                        property["type"] = user.loginType.description
                    } else {
                        property["type"] = UserDefault().readString(key: UserDefault.Key.MB_LOGIN_TYPE)
                    }
                    
                    self.amplitudeManager.logEvent(type: .login(.clickLoginButton), property: property)
                    self.amplitudeManager.logEvent(type: .login(.complteLogin), property: property)

                    // 즐겨찾기 목록 가져오기
                    ChargerManager.sharedInstance.getFavoriteCharger()
         
                } else {
                    if let delegate = self.delegate, let user = user {
                        let property: [String: Any] = ["type": String(user.loginType.description)]
                        AmplitudeManager.shared.logEvent(type: .signup(.clickSignUpButton), property: property)
                        delegate.needSignUp(user: user) // ev infra 회원가입
                    }
                    MemberManager.shared.clearData()
                }
            } else {
                MemberManager.shared.clearData()
                self.amplitudeManager.setUser(with: nil)
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
            self.requestFromAppleLoginToEvInfra(user: Login.apple(appleIDCredential))
            
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

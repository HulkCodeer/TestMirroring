//
//  AmplitudeManager.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/07/20.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Amplitude

internal final class AmplitudeManager {
    // MARK: - Variable
    
    internal static var shared = AmplitudeManager()
    #if DEBUG
    private let apiKey: String = "57bdb148be2db2b5ef49ae6b576fbd15"
    #else
    private let apiKey: String = ""
    #endif
    
    private let identify = AMPIdentify()
    
    // MARK: - Initializers
    
    init() {
        Amplitude.instance().initializeApiKey(apiKey)
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().setUserId(nil)
    }
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    // MARK: - Event Function
    
    internal func setUser(with id: String?) {
        Amplitude.instance().setUserId(id)
        // 로그인 했을 경우 -> user_id = mb_id
        // 로그인 안했을 경우 -> user_id = null
    }
    
    // MARK: - UserProperty
    internal func setUserProperty(user: Login?) {
        identify.set("membership card", value: MemberManager.shared.hasMembership as NSObject)
        identify.set("signup", value: (MemberManager.shared.mbId > 0 ? true : false) as NSObject)
        identify.set("signup date", value: NSString(string: UserDefault().readString(key: UserDefault.Key.REG_DATE)))
        identify.set("berry owned", value: NSString(string: UserDefault().readString(key: UserDefault.Key.POINT)))
        identify.set("favorite station count", value: NSString(string: ""))

        if let user = user,
            let otherInfo = user.otherInfo {
            identify.set("gender", value: NSString(string: otherInfo.gender))
            identify.set("age range", value: NSString(string: otherInfo.age_range))
        }
        // 나이, 성별 없을경우 기타
        
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().identify(self.identify)
        }
    }
    
    // MARK: - Clear UserProperty
    internal func clearUserProperty() {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().clearUserProperties()
        }
    }
    
    // MARK: - View Enter Event Log
    internal func prepareViewEnterEvent(with viewController: UIViewController) {
        let viewConName = String(describing: type(of: viewController))
        let description = ViewControllerDescription.allCases
            .first { $0.rawValue.equals(viewConName) }
            .map { $0.description } ?? "\(viewConName)"
        
        logEvent(type: .enter(.viewEnter), property: ["page" : description])
    }
    
    // MARK: - UserProperty: 즐겨찾기 충전소 개수 세팅
    internal func setUserProperty(with favoriteList: [ChargerStationInfo]) {
        let countOfFavoriteList = favoriteList.filter { return $0.mFavorite }.count
        identify.set("favorite station count", value: NSString(string: String(countOfFavoriteList)))

        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().identify(self.identify)
        }
    }
    
    // MARK: - 로깅 이벤트
    internal func logEvent(type: EventType, property: [String: Any]) {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(type.eventName, withEventProperties: property)
        }
    }
}

// MARK: - Extension
extension AmplitudeManager {
    internal enum EventType {
        case enter(EnterEvent)
        case login(LoginEvent)
        case signup(SignUpEvent)
        
        var eventName: String {
            switch self {
            case .enter(let event):
                switch event {
                case .viewEnter: return "view_enter"
                }
            case .login(let event):
                switch event {
                case .clickLoginButton: return "click_login_button"
                case .complteLogin: return "complete_login"
                }
            case .signup(let event):
                switch event {
                case .clickSignUpButton: return "click_signup_button"
                case .completeSignUp: return "complete_signup"
                }
            }
        }
    }
    
    internal enum EnterEvent {
        case viewEnter
    }

    internal enum SignUpEvent {
        case clickSignUpButton
        case completeSignUp
    }
    
    internal enum LoginEvent {
        case clickLoginButton
        case complteLogin
    }
}

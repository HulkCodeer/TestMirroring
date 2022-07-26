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
    
    // MARK: - Event Function
    
    func setUser(with id: String?) {
        Amplitude.instance().setUserId(id)
        // 로그인 했을 경우 -> user_id = mb_id
        // 로그인 안했을 경우 -> user_id = null
    }
    
    // MARK: - UserProperty
    func setUserProperty(user: Login?) {        
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
        
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().identify(self.identify)
        }
    }
    
    // MARK: - Clear UserProperty
    func clearUserProperty() {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().clearUserProperties()
        }
    }
    
    // MARK: - View Enter Event Log
    func setViewEnterEvent(with viewController: UIViewController) {
        let viewConName = String(describing: type(of: viewController))
        
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(EventName.viewEnter.rawValue, withEventProperties: ["page" : viewConName])
        }
    }
    
    // MARK: - UserProperty: 즐겨찾기 충전소 개수 세팅
    func setUserProperty(with favoriteList: [ChargerStationInfo]) {
        let countOfFavoriteList = favoriteList.filter { return $0.mFavorite }.count
        identify.set("favorite station count", value: NSString(string: String(countOfFavoriteList)))

        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().identify(self.identify)
        }
    }
}

// MARK: - Extension
extension AmplitudeManager {
    private enum EventName: String {
        case viewEnter
        
        var rawValue: String {
            switch self {
            case .viewEnter:
                return "\(Action.view)_\(ViewType.enter)"
            }
        }
        
        private enum Action: String {
            case view
            case click
            case complete
        }
        
        private enum ViewType: String {
            case enter
        }
    }
}

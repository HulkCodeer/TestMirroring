//
//  MemberManager.swift
//  evInfra
//
//  Created by Shin Park on 2018. 8. 10..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON
import MiniPlengi

struct Admin: Decodable {
    let mb_id: String
    let nick_name: String
}

enum MemberLevel: Int {
    case admin = 1
    case keeper = 2
    case normal = 3
}

enum RentClientType: Int {
    case skr = 23
    case lotte = 24
}

internal final class MemberManager {
    internal static let shared = MemberManager()
    
    private init() {}
    
    internal var mbId: Int { // 회원가입 아이디
        return UserDefault().readInt(key: UserDefault.Key.MB_ID)
    }
    
    internal var memberId: String { // 기기 아이디
        return UserDefault().readString(key: UserDefault.Key.MEMBER_ID)
    }
    
    internal var userId: String {
        return UserDefault().readString(key: UserDefault.Key.MB_USER_ID)
    }
    
    internal var deviceId: String {
        return UserDefault().readString(key: UserDefault.Key.MB_DEVICE_ID)
    }
    
    internal var appleRefreshToken: String {
        return UserDefault().readString(key: UserDefault.Key.APPLE_REFRESH_TOKEN)
    }
    
    internal var loginType: Login.LoginType {
        return Login.LoginType(rawValue: UserDefault().readString(key: UserDefault.Key.MB_LOGIN_TYPE)) ?? .none
    }
    
    internal var lastLoginType: Login.LoginType {
        return Login.LoginType(rawValue: UserDefault().readString(key: UserDefault.Key.MB_LAST_LOGIN_TYPE)) ?? .none
    }
    
    internal var profileImage: String {
        set {
            UserDefault().saveString(key: UserDefault.Key.MB_PROFILE_NAME, value: newValue)
        }
        get {
            return UserDefault().readString(key: UserDefault.Key.MB_PROFILE_NAME)
        }
    }
    
    internal var memberNickName: String {
        set {
            UserDefault().saveString(key: UserDefault.Key.MB_NICKNAME, value: newValue)
        }
        get {
            return UserDefault().readString(key: UserDefault.Key.MB_NICKNAME)
        }
    }
    
    internal var ageRange: String {
        set {
            UserDefault().saveString(key: UserDefault.Key.MB_AGE_RANGE, value: newValue)
        }
        get {
            return UserDefault().readString(key: UserDefault.Key.MB_AGE_RANGE)
        }
    }
    
    internal var gender: String {
        set {
            UserDefault().saveString(key: UserDefault.Key.MB_GENDER, value: newValue)
        }
        get {
            return UserDefault().readString(key: UserDefault.Key.MB_GENDER)
        }
    }
    
    internal var carId: Int {
        return UserDefault().readInt(key: UserDefault.Key.MB_CAR_ID)
    }
    
    internal var email: String {
        return UserDefault().readString(key: UserDefault.Key.MB_EMAIL)
    }
    
    internal var phone: String {
        return UserDefault().readString(key: UserDefault.Key.MB_PHONE)
    }
    
    internal var regDate: String {
        set {
            UserDefault().saveString(key: UserDefault.Key.MB_REG_DATE, value: newValue)
        }
        get {
            return UserDefault().readString(key: UserDefault.Key.MB_REG_DATE)
        }
    }
    
    internal var berryPoint: String {
        set {
            UserDefault().saveString(key: UserDefault.Key.MB_POINT, value: newValue)
        }
        get {
            return UserDefault().readString(key: UserDefault.Key.MB_POINT)
        }
    }
    
    internal var isAllowNoti: Bool {
        set {
            UserDefault().saveBool(key: UserDefault.Key.SETTINGS_ALLOW_NOTIFICATION, value: newValue)
        }
        get {
            return UserDefault().readBool(key: UserDefault.Key.SETTINGS_ALLOW_NOTIFICATION)
        }
    }
    
    internal var isAllowJejuNoti: Bool {
        set {
            UserDefault().saveBool(key: UserDefault.Key.SETTINGS_ALLOW_JEJU_NOTIFICATION, value: newValue)
        }
        get {
            return UserDefault().readBool(key: UserDefault.Key.SETTINGS_ALLOW_JEJU_NOTIFICATION)
        }
    }
    
    internal var isAllowMarketingNoti: Bool {
        set {
            UserDefault().saveBool(key: UserDefault.Key.SETTINGS_ALLOW_MARKETING_NOTIFICATION, value: newValue)
        }
        get {
            return UserDefault().readBool(key: UserDefault.Key.SETTINGS_ALLOW_MARKETING_NOTIFICATION)
        }
    }
                    
    func isPartnershipClient(clientId : Int) -> Bool {
        let list = UserDefault().readIntArray(key: UserDefault.Key.MB_PARTNERSHIP_CLIENT)
        return list.contains(clientId)
    }
    
    func setSKRentConfig(){
        let arr = UserDefault().readIntArray(key: UserDefault.Key.MB_PARTNERSHIP_CLIENT)
        if !arr.contains(RentClientType.skr.rawValue){
            UserDefault().addItemToIntArray(key: UserDefault.Key.MB_PARTNERSHIP_CLIENT, value: RentClientType.skr.rawValue)
        }
        UserDefault().saveBool(key: UserDefault.Key.INTRO_SKR, value: true)
    }
    
    func savePartnershipClientId(data :[JSON]){
        UserDefault().saveIntArray(key: UserDefault.Key.MB_PARTNERSHIP_CLIENT, value: data)
        if data.contains(JSON(RentClientType.skr.rawValue)){
            UserDefault().saveBool(key: UserDefault.Key.INTRO_SKR, value: true)
        } else {
            UserDefault().saveBool(key: UserDefault.Key.INTRO_SKR, value: false)
        }
    }
    
    internal var hasMembership: Bool {
        set {
            UserDefault().saveBool(key: UserDefault.Key.MB_HAS_MEMBERSHIP, value: newValue)
        }
        get {
            return UserDefault().readBool(key: UserDefault.Key.MB_HAS_MEMBERSHIP)
        }
    }
    
    internal var hasPayment: Bool {
        set {
            UserDefault().saveBool(key: UserDefault.Key.MB_PAYMENT, value: newValue)
        }
        get {
            return UserDefault().readBool(key: UserDefault.Key.MB_PAYMENT)
        }
    }
        
    internal var isFirstInstall: Bool {
        set {
            UserDefault().saveBool(key: UserDefault.Key.IS_FIRST_INSTALL, value: newValue)
        }
        get {
            return UserDefault().readBool(key: UserDefault.Key.IS_FIRST_INSTALL)
        }
    }
    
    // 로그인 상태 체크
    internal var isLogin: Bool {
        return UserDefault().readInt(key: UserDefault.Key.MB_ID) > 0
    }
    
    // 지킴이 체크
    internal var isKeeper: Bool {
        return UserDefault().readInt(key: UserDefault.Key.MB_LEVEL) == MemberLevel.keeper.rawValue
    }
    
    // QR 체크
    internal var isShowQrTooltip: Bool {
        set {
            UserDefault().saveBool(key: UserDefault.Key.IS_SHOW_QR_TOOLTIP, value: newValue)
        }
        get {
            return UserDefault().readBool(key: UserDefault.Key.IS_SHOW_QR_TOOLTIP)
        }
    }
    
    func setData(data: JSON) {
        if data["mb_id"].stringValue.elementsEqual("") {
            print("mb id is null");
        } else {
            // member data 저장
            let userDefault = UserDefault()
            userDefault.saveInt(key: UserDefault.Key.MB_ID, value: data["mb_id"].intValue)
            userDefault.saveInt(key: UserDefault.Key.MB_LEVEL, value: data["mb_level"].intValue)
            userDefault.saveString(key: UserDefault.Key.MB_USER_ID, value: data["user_id"].stringValue)
            userDefault.saveString(key: UserDefault.Key.MB_LOGIN_TYPE, value: data["login_type"].stringValue)
            userDefault.saveString(key: UserDefault.Key.MB_NICKNAME, value: data["mb_nm"].stringValue)
            userDefault.saveString(key: UserDefault.Key.MB_PROFILE_NAME, value: data["profile"].stringValue)
            userDefault.saveString(key: UserDefault.Key.MB_REGION, value: data["region"].stringValue)
            userDefault.saveInt(key: UserDefault.Key.MB_CAR_ID, value: data["car_id"].intValue)
            userDefault.saveInt(key: UserDefault.Key.MB_CAR_TYPE, value: data["car_type"].intValue)
            savePartnershipClientId(data : data["rent_client"].arrayValue)
            userDefault.saveBool(key: UserDefault.Key.MB_PAYMENT, value: data["payment"].boolValue)
            userDefault.saveString(key: UserDefault.Key.MB_DEVICE_ID, value: data["battery_device_id"].stringValue)
            userDefault.saveBool(key: UserDefault.Key.MB_HAS_MEMBERSHIP, value: data["has_membership"].boolValue)
            userDefault.saveString(key: UserDefault.Key.MB_LAST_LOGIN_TYPE, value: data["login_type"].stringValue)
            userDefault.saveString(key: UserDefault.Key.MB_GENDER, value: data["gender"].stringValue)
            userDefault.saveString(key: UserDefault.Key.MB_AGE_RANGE, value: data["age_range"].stringValue)
            userDefault.saveString(key: UserDefault.Key.MB_EMAIL, value: data["email"].stringValue)
            userDefault.saveString(key: UserDefault.Key.MB_PHONE, value: data["phone"].stringValue)
            userDefault.saveString(key: UserDefault.Key.MB_REG_DATE, value: data["reg_date"].stringValue)
            userDefault.saveString(key: UserDefault.Key.MB_POINT, value: data["point"].stringValue)
            
            if Plengi.initialize(clientID: "zeroone",
                           clientSecret: "zeroone)Q@Eh(4",
                                 echoCode: "\(data["mb_id"].intValue)") == .SUCCESS {
                _ = Plengi.start()
            }                        
        }
    }
    
    func clearData() {
        let userDefault = UserDefault()
        userDefault.saveInt(key: UserDefault.Key.MB_ID, value: 0)
        userDefault.saveInt(key: UserDefault.Key.MB_LEVEL, value: MemberLevel.normal.rawValue)
        userDefault.saveString(key: UserDefault.Key.MB_USER_ID, value: "")
        userDefault.saveString(key: UserDefault.Key.MB_PROFILE_NAME, value: "")
        userDefault.saveString(key: UserDefault.Key.MB_REGION, value: "")
        userDefault.saveInt(key: UserDefault.Key.MB_CAR_ID, value: 0)
        userDefault.saveInt(key: UserDefault.Key.MB_CAR_TYPE, value: Const.CHARGER_TYPE_ETC)
        userDefault.saveIntArray(key: UserDefault.Key.MB_PARTNERSHIP_CLIENT, value: [JSON]())
        userDefault.saveBool(key: UserDefault.Key.INTRO_SKR, value: false)
        userDefault.saveBool(key: UserDefault.Key.MB_PAYMENT, value: false)
        userDefault.saveString(key: UserDefault.Key.MB_DEVICE_ID, value:  "")
        userDefault.saveBool(key: UserDefault.Key.MB_HAS_MEMBERSHIP, value:  false)
        userDefault.saveString(key: UserDefault.Key.APPLE_REFRESH_TOKEN, value:  "")
        userDefault.saveString(key: UserDefault.Key.MB_LOGIN_TYPE, value:  "")
        userDefault.saveString(key: UserDefault.Key.MB_GENDER, value: "")
        userDefault.saveString(key: UserDefault.Key.MB_AGE_RANGE, value: "")
        userDefault.saveString(key: UserDefault.Key.MB_EMAIL, value: "")
        userDefault.saveString(key: UserDefault.Key.MB_PHONE, value: "")
        
        AmplitudeManager.shared.setUser(with: nil)
    }
    
    func showLoginAlert(completion: ((Bool) -> ())? = nil) {
        
        let popupModel = PopupModel(title: "로그인이 필요해요",
                                    message:"해당 서비스는 로그인 후 이용할 수 있어요.\n아래 버튼을 눌러 로그인을 해주세요.",
                                    confirmBtnTitle: "로그인 하기",
                                    cancelBtnTitle: "닫기",
                                    confirmBtnAction: {
                                        let loginVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(ofType: LoginViewController.self)
                                        GlobalDefine.shared.mainNavi?.push(viewController: loginVC)
                                                    
                                        completion?(true)
                                    },
                                    cancelBtnAction: {
                                        completion?(false)
        }, dimmedBtnAction: {})
        let popup = ConfirmPopupViewController(model: popupModel)
        GlobalDefine.shared.mainNavi?.present(popup, animated: true, completion: nil)
    }
    
    internal func tryToLoginCheck(success: ((Bool) -> Void)? = nil) {
        switch self.loginType {
        case .kakao:
            KOSessionTask.userMeTask { (error, me) in
                if (error as NSError?) != nil {
                    Snackbar().show(message: "회원 탈퇴로 인해 로그아웃 되었습니다.")
                    MemberManager.shared.clearData()
                } else {
                    success?(UserDefault().readInt(key: UserDefault.Key.MB_ID) > 0)
                }
            }
                    
        default: success?(UserDefault().readInt(key: UserDefault.Key.MB_ID) > 0)
        }
        
    }
}

//
//  MemberManager.swift
//  evInfra
//
//  Created by Shin Park on 2018. 8. 10..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON


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
    
    internal var mbId: Int {
        return UserDefault().readInt(key: UserDefault.Key.MB_ID)
    }
    
    internal var memberId: String {
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
        return UserDefault().readString(key: UserDefault.Key.MB_PROFILE_NAME)
    }
    
    internal var memberNickName: String {
        return UserDefault().readString(key: UserDefault.Key.MB_NICKNAME).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
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
        return UserDefault().readBool(key: UserDefault.Key.MB_HAS_MEMBERSHIP)
    }
    
    internal var hasPayment: Bool {
        return UserDefault().readBool(key: UserDefault.Key.MB_PAYMENT)
    }
    
    // 로그인 상태 체크
    internal var isLogin: Bool {
        return UserDefault().readInt(key: UserDefault.Key.MB_ID) > 0
    }
    
    // 지킴이 체크
    internal var isKeeper: Bool {
        return UserDefault().readInt(key: UserDefault.Key.MB_LEVEL) == MemberLevel.keeper.rawValue
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
    }
    
    func showLoginAlert(completion: ((Bool) -> ())? = nil) {
        
        let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in
            guard let _mainNavi = GlobalDefine.shared.mainNavi else { return }
            let loginVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(ofType: LoginViewController.self)
            _mainNavi.push(viewController: loginVC)
                        
            completion?(true)
        })
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler:{ (ACTION) -> Void in
            completion?(false)
        })
        
        UIAlertController.showAlert(title: "로그인 필요", message: "로그인 후 사용가능합니다.\n로그인 하시려면 확인버튼을 누르세요.", actions: [ok, cancel])
        
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

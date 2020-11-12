//
//  MemberManager.swift
//  evInfra
//
//  Created by Shin Park on 2018. 8. 10..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

class MemberManager {
    
    public static let MB_LEVEL_ADMIN = 1;
    public static let MB_LEVEL_GUARD = 2;
    public static let MB_LEVEL_NORMAL = 3;
    
    public static let RENT_CLIENT_SKR = 23;
    public static let RENT_CLIENT_LOTTE = 24;
    
    static func getMbId() -> Int {
        return UserDefault().readInt(key: UserDefault.Key.MB_ID)
    }
    
    static func getMemberId() -> String {
        return UserDefault().readString(key: UserDefault.Key.MEMBER_ID)
    }
    
    static func getUserId() -> String {
        return UserDefault().readString(key: UserDefault.Key.MB_USER_ID)
    }
    
    static func getLoginType() -> Login.LoginType {
        return Login.LoginType(rawValue: UserDefault().readString(key: UserDefault.Key.MB_LOGIN_TYPE)) ?? .kakao
    }
    
    static func isPartnershipClient(clientId : Int) -> Bool {
        let list = UserDefault().readIntArray(key: UserDefault.Key.MB_PARTNERSHIP_CLIENT)
        return list.contains(clientId)
    }
    
    static func setSKRentConfig(){
        var arr = UserDefault().readIntArray(key: UserDefault.Key.MB_PARTNERSHIP_CLIENT)
        if !arr.contains(MemberManager.RENT_CLIENT_SKR){
            UserDefault().addItemToIntArray(key: UserDefault.Key.MB_PARTNERSHIP_CLIENT, value: RENT_CLIENT_SKR)
        }
        UserDefault().saveBool(key: UserDefault.Key.INTRO_SKR, value: true)
    }
    
    func savePartnershipClientId(data :[JSON]){
        UserDefault().saveIntArray(key: UserDefault.Key.MB_PARTNERSHIP_CLIENT, value: data)
        if data.contains(JSON(MemberManager.RENT_CLIENT_SKR)){
            UserDefault().saveBool(key: UserDefault.Key.INTRO_SKR, value: true)
        } else {
            UserDefault().saveBool(key: UserDefault.Key.INTRO_SKR, value: false)
        }
    }
    
    static func hasMembership() -> Bool {
        let list = UserDefault().readIntArray(key: UserDefault.Key.MB_PARTNERSHIP_CLIENT)
        return !list.isEmpty
    }
    
    static func hasPayment() -> Bool {
        return UserDefault().readBool(key: UserDefault.Key.MB_PAYMENT)
    }
    
    // 로그인 상태 체크
    func isLogin() -> Bool {
        if UserDefault().readInt(key: UserDefault.Key.MB_ID) > 0 {
            return true
        } else {
            return false;
        }
    }
    
    // 지킴이 체크
    func isGuard() -> Bool {
        let mbLevel = UserDefault().readInt(key: UserDefault.Key.MB_LEVEL)
        return mbLevel == MemberManager.MB_LEVEL_GUARD
    }
    
    func setData(data: JSON) {
        if data["mb_id"].stringValue.elementsEqual("") {
            print("mb id is null");
        } else {
            // member data 저장
            let userDefault = UserDefault()
            userDefault.saveInt(key: UserDefault.Key.MB_ID, value: data["mb_id"].intValue)
            userDefault.saveInt(key: UserDefault.Key.MB_LEVEL, value: data["mb_level"].intValue)
            userDefault.saveString(key: UserDefault.Key.MB_LOGIN_TYPE, value: data["login_type"].stringValue)
            userDefault.saveString(key: UserDefault.Key.MB_NICKNAME, value: data["mb_nm"].stringValue)
            userDefault.saveString(key: UserDefault.Key.MB_PROFILE_NAME, value: data["profile"].stringValue)
            userDefault.saveString(key: UserDefault.Key.MB_REGION, value: data["region"].stringValue)
            userDefault.saveInt(key: UserDefault.Key.MB_CAR_ID, value: data["car_id"].intValue)
            userDefault.saveInt(key: UserDefault.Key.MB_CAR_TYPE, value: data["car_type"].intValue)
            savePartnershipClientId(data : data["rent_client"].arrayValue)
            userDefault.saveBool(key: UserDefault.Key.MB_PAYMENT, value: data["payment"].boolValue)
        }
    }
    
    func clearData() {
        let userDefault = UserDefault()
        userDefault.saveInt(key: UserDefault.Key.MB_ID, value: 0)
        userDefault.saveInt(key: UserDefault.Key.MB_LEVEL, value: MemberManager.MB_LEVEL_NORMAL)
        userDefault.saveString(key: UserDefault.Key.MB_LOGIN_TYPE, value: "")
        userDefault.saveString(key: UserDefault.Key.MB_PROFILE_NAME, value: "")
        userDefault.saveString(key: UserDefault.Key.MB_REGION, value: "")
        userDefault.saveInt(key: UserDefault.Key.MB_CAR_ID, value: 0)
        userDefault.saveInt(key: UserDefault.Key.MB_CAR_TYPE, value: Const.CHARGER_TYPE_ETC)
        userDefault.saveIntArray(key: UserDefault.Key.MB_PARTNERSHIP_CLIENT, value: [JSON]())
        userDefault.saveBool(key: UserDefault.Key.INTRO_SKR, value: false)
        userDefault.saveBool(key: UserDefault.Key.MB_PAYMENT, value: false)
    }
    
    func showLoginAlert(vc: UIViewController, completion: ((Bool) -> ())? = nil) {
        let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in
            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            vc.navigationController?.push(viewController: loginVC)
            
            if completion != nil {
                completion!(true)
            }
        })
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler:{ (ACTION) -> Void in
            if completion != nil {
                completion!(false)
            }
        })

        var actions = Array<UIAlertAction>()
        actions.append(ok)
        actions.append(cancel)
        UIAlertController.showAlert(title: "로그인 필요", message: "로그인 후 사용가능합니다.\n로그인 하시려면 확인버튼을 누르세요.", actions: actions)
    }
}

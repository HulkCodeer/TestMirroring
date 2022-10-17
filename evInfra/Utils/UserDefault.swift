//
//  UserDefault.swift
//  evInfra
//
//  Created by 이신광 on 2018. 5. 11..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON
class UserDefault {
    struct Key {
        
        static let KEY_APP_VERSION  = "appVersion" // 앱 버젼
        static let COMPANY_ICON_UPDATE_DATE = "company_icon_update_date"
        static let COMPANY_ICON_IMAGE_PATH_VERSION = "company_icon_image_path_version"
        
        // 회원 정보
        static let MEMBER_ID        = "member_id" // 사용자 정보
        static let MB_ID            = "mb_id"       // 회원 id
        static let MB_LEVEL         = "mb_level"
        static let MB_USER_ID       = "mb_user_id"  // user id
        static let MB_LOGIN_TYPE    = "mb_login_type" // kakao, apple
        static let MB_LAST_LOGIN_TYPE = "mb_last_login_type" // kakao, apple
        static let MB_NICKNAME      = "mb_nickname"
        static let MB_REGION        = "mb_region"
        static let MB_PROFILE_NAME  = "mb_profile_image"
        static let MB_CAR_ID        = "mb_car_id"
        static let MB_CAR_TYPE      = "mb_car_type"
        static let MB_PARTNERSHIP_CLIENT   = "mb_partnership_client"
        static let MB_PAYMENT       = "mb_payment"
        static let MB_DEVICE_ID       = "mb_device_id"
        static let MB_HAS_MEMBERSHIP = "has_membership"
        static let APPLE_REFRESH_TOKEN = "apple_refresh_token"
        static let MB_AGE_RANGE = "mb_age_range"
        static let MB_GENDER = "mb_gender"
        static let MB_EMAIL = "mb_email"
        static let MB_PHONE = "mb_phone"
        static let MB_REG_DATE = "reg_date"
        static let MB_POINT = "point"
        static let MB_HAS_REPRESENTED = "mb_has_represented"
        static let IS_SHOW_QR_TOOLTIP = "is_show_qr_tooltip"
        static let IS_SHOW_EVPAY_TOOLTIP = "is_show_evpay_tooltip"
                
        // 필터 - 개인 설정
        static let FILTER_DC_DEMO       = "filter_dc_demo"
        static let FILTER_DC_COMBO      = "filter_dc_combo"
        static let FILTER_AC            = "filter_ac"
        static let FILTER_SUPER_CHARGER = "filter_super_charger"
        static let FILTER_SLOW          = "filter_slow"
        static let FILTER_DESTINATION   = "filter_destination"
        
        static let FILTER_FREE          = "filter_free"
        static let FILTER_PAID          = "filter_paid"
        static let FILTER_PUBLIC        = "filter_public"
        static let FILTER_NONPUBLIC     = "filter_non_public"
        static let FILTER_MIN_SPEED     = "filter_min_speed"
        static let FILTER_MAX_SPEED     = "filter_max_speed"
        static let FILTER_INDOOR        = "filter_indoor"
        static let FILTER_OUTDOOR       = "filter_outdoor"
        static let FILTER_CANOPY        = "filter_canopy"
        static let FILTER_GENERAL_WAY   = "filter_general_way"
        static let FILTER_HIGHWAY_UP    = "filter_highway_up"
        static let FILTER_HIGHWAT_DOWN  = "filter_highway_down"
        static let FILTER_MYCAR         = "filter_mycar"
        static let FILTER_MEMBERSHIP_CARD = "filter_membership_card"
        static let FILTER_FAVORITE      = "filter_favorite"
        
        static let FILTER_ROAD          = "filter_road"
        static let FILTER_ST_KIND       = "filter_station_kind"
        
        static let FILTER_WAY           = "filter_way"
        static let FILTER_PAY           = "filter_pay"
        
        static let LAST_NOTICE_ID       = "read_notice"
        static let LAST_FREE_ID         = "read_free"
        static let LAST_CHARGER_ID      = "read_station"
        
        static let MAP_ZOOM_LEVEL   = "map_zoom_level"
        
        static let INTRO_SKR    = "intro_skr"
        static let JEJU_PUSH    = "jeju_push"
        static let GUIDE_VERSION = "guide_vesion"
        
        static let HAS_FAILED_PAYMENT = "has_failed_payment"
        
        static let FILTER_CHARGING_PROVIDER_LIST_SAVE = "filter_charging_provider_list_save"
        
        // 전체설정
        static let SETTINGS_ALLOW_NOTIFICATION = "allow_notification"
        static let SETTINGS_ALLOW_JEJU_NOTIFICATION = "allow_jeju_notification"
        static let SETTINGS_ALLOW_MARKETING_NOTIFICATION = "allow_marketing_notification"
        static let SETTINGS_CLUSTER = "allow_clustering"
        
        static let APP_INTRO_IMAGE = "app_intro_image"
        static let APP_INTRO_END_DATE = "app_intro_end_date"
        
        // 마케팅 팝업을 이미 보여줬는지 체크
        static let DID_SHOW_MARKETING_POPUP = "app_first_boot" // false : first booting
        static let AD_KEEP_DATE_FOR_A_WEEK = "ad_keep_date_for_a_week" // 광고 - 일주일동안 보지 않기 선택한 날짜
        static let RECENT_KEYWORD = "keywords" // 게시글 검색 최근검색어
        static let IS_HIDDEN_DELEVERY_COMPLETE_TOOLTIP = "isDeleveryComplete" // 배송완료 툴팁 저장
                
        static let IS_FIRST_INSTALL = "is_first_install" // 앱 최초 설치인지 확인용
        static let IS_FIRST_LOCATION_POPUP = "is_first_location_popup" // 항상 허용 권한 위치 팝업 띄웠는지 유무        
    }

    func saveString(key:String, value: String) -> Void {
        let defaults = UserDefaults.standard
        defaults.setValue(value, forKey:key)
        defaults.synchronize()
    }
    
    func readString(key:String) -> String {
        if let value = UserDefaults.standard.string(forKey: key) {
            return value
        } else {
            return ""
        }
    }
    
    func saveInt(key:String, value:Int) -> Void {
        let defaults = UserDefaults.standard
        defaults.setValue(value, forKey:key)
        defaults.synchronize()
    }
    
    func readInt(key:String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    func saveBool(key: String, value: Bool) -> Void {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    func readBool(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    func readBoolWithNil(key: String) -> AnyObject? {
        if let value = UserDefaults.standard.object(forKey: key) {
            return value as AnyObject
        } else {
            return nil
        }
    }
    
    func saveIntArray(key: String, value: [JSON]) -> Void {
        let defaults = UserDefaults.standard
        var clientList : [Int] = []
        for client in value {
            clientList.append(client.intValue)
        }
        defaults.set(clientList, forKey: key)
        defaults.synchronize()
    }
    
    func addItemToIntArray(key: String, value : Int) -> Void {
        let defaults = UserDefaults.standard
        var clientList : [Int] = self.readIntArray(key: key)
        clientList.append(value)
        defaults.set(clientList, forKey: key)
        defaults.synchronize()
    }
    
    func readIntArray(key: String) -> [Int] {
        return UserDefaults.standard.array(forKey: key) as? [Int] ?? [Int]()
    }
    
    func registerBool(key: String, val: Bool) -> Void {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [key: val])
    }
    
    func registerInt(key: String, val: Int) -> Void {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [key: val])
    }
    
    func removeObjectForKey(key: String) -> Void{
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
    }
    
    func saveData(key: String, val: Data) -> Void {
        let defaults = UserDefaults.standard
        defaults.set(val, forKey: key)
    }
    
    func readData(key: String) -> Data? {
        if let value = UserDefaults.standard.data(forKey: key) {
            return value
        } else {
            return nil
        }
    }
    
    func setUserDefault(_ key: String?, value: Any?) {
        let _key = key ?? ""
        let userDefaults = UserDefaults.standard
        userDefaults.set(value, forKey: _key)
        userDefaults.synchronize()
    }
    
    func getUserDefault(_ key: String?) -> AnyObject? {
        let _key = key ?? ""
        if let value = UserDefaults.standard.object(forKey: _key) {
            return value as AnyObject
        } else {
            return nil
        }
    }
}

//
//  UserDefault.swift
//  evInfra
//
//  Created by 이신광 on 2018. 5. 11..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation

class UserDefault {
    struct Key {
        // 안드로이드에 있으나 iOS에 없는 key
//        public static final String KEY_APP_VERSION  = "appVersion";
//        public static final String KEY_DB_VERSION   = "db_version";
//
//        public static final String KEY_SETTINGS_ENABLE_CLUSTERING = "enable_clustering";
//        public static final String KEY_SETTINGS_CLUSTERING_ZOOM = "clustering_zoom";

        // 사용자 정보
        static let MEMBER_ID        = "member_id"
        
        static let COMPANY_ICON_UPDATE_DATE = "company_icon_update_date"
        
        // 회원 정보
        static let MB_ID            = "mb_id"       // 회원 id
        static let MB_LEVEL         = "mb_level"
        static let MB_USER_ID       = "mb_user_id"  // 카카오 user id
        static let MB_NICKNAME      = "mb_nickname"
        static let MB_REGION        = "mb_region"
        static let MB_PROFILE_NAME  = "mb_profile_image"
        static let MB_CAR_ID        = "mb_car_id"
        static let MB_CAR_TYPE      = "mb_car_type"
        
        // 필터 - 개인 설정
        static let FILTER_DC_DEMO       = "filter_dc_demo"
        static let FILTER_DC_COMBO      = "filter_dc_combo"
        static let FILTER_AC            = "filter_ac"
        static let FILTER_SUPER_CHARGER = "filter_super_charger"
        static let FILTER_SLOW          = "filter_slow"
        
        static let FILTER_ROAD          = "filter_road"
        static let FILTER_ST_KIND       = "filter_station_kind"
        
        static let FILTER_WAY           = "filter_way"
        static let FILTER_PAY           = "filter_pay"
        
        static let LAST_NOTICE_ID       = "read_notice"
        static let LAST_FREE_ID         = "read_free"
        static let LAST_CHARGER_ID      = "read_station"
        static let LAST_EVENT_ID        = "read_event"
        
        static let MAP_ZOOM_LEVEL   = "map_zoom_level"
        
        // 전체설정
        static let SETTINGS_ALLOW_NOTIFICATION = "allow_notification"
        static let SETTINGS_CLUSTER = "allow_cluster"
        static let SETTINGS_CLUSTER_ZOOMLEVEL = "user_zoom_lev"
        
        // 충전 결제
        static let CHARGING_ID = "charging_id"
        
        // 광고 - 일주일동안 보지 않기 선택한 날짜
        static let AD_KEEP_DATE_FOR_A_WEEK = "ad_keep_date_for_a_week"
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
}

//
//  Const.swift
//  evInfra
//
//  Created by bulacode on 2018. 3. 6..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation

internal enum Const {
            
    // Closed Beta Test
    public static let CLOSED_BETA_TEST = false

    #if DEBUG
    /*
     * develop
     */
    public static let EV_PAY_SERVER = "http://dev.soft-berry.co.kr"
    public static let EV_COMMUNITY_SERVER = "http://dev.soft-berry.co.kr/community/v2/EiCommunity"
    public static let EI_FILE_SERVER = "https://data.ev-infra.com/ev-infra/dev"
    public static let SK_BATTERY_SERVER = "http://mbaas.koreacentral.cloudapp.azure.com/ev-infra/web"
    // public static let SK_BATTERY_SERVER = "https://mbaas.sk-on.com/ev-infra/web"
//    public static let EV_PAY_SERVER = "http://khpark.soft-berry.co.kr"
//    public static let EV_PAY_SERVER = "http://spark.soft-berry.co.kr"
//    public static let EV_PAY_SERVER = "http://michael.soft-berry.co.kr"
//    public static let EV_PAY_SERVER = "http://shchoi.soft-berry.co.kr"
//    public static let EI_FILE_SERVER = "https://data.ev-infra.com/ev-infra/dev"
//    public static let SK_BATTERY_SERVER = "http://mbaas.koreacentral.cloudapp.azure.com/ev-infra/main"
    #else
    /*
     * product
     */
    public static let EV_PAY_SERVER = "https://api.soft-berry.co.kr"
    public static let EV_COMMUNITY_SERVER = "https://comm.ev-infra.com/community/v2/EiCommunity"
    public static let EI_FILE_SERVER = "https://data.ev-infra.com/ev-infra"
    public static let SK_BATTERY_SERVER = "https://mbaas.sk-on.com/ev-infra/web"
    #endif

    // File Server
    public static let urlProfileImage = EI_FILE_SERVER + "/profile/"
    public static let urlBoardImage = EI_FILE_SERVER + "/board/"
    public static let urlShareImage = EI_FILE_SERVER + "/share_default.jpg"
    
    // image 서버
    public static let EI_IMG_SERVER = "https://img.soft-berry.co.kr"

    // static image: 위성사진, 운영기관 로고, 전기차
    public static let IMG_URL_COMP_MARKER = EI_IMG_SERVER + "/marker/logo_v2/"
    public static let IMG_URL_EV_MODEL    = EI_IMG_SERVER + "/models/"
    public static let IMG_URL_INTRO       = EI_IMG_SERVER + "/intro/"
    
    // BUCKET KIND OF IMAGE
    public static let CONTENTS_THUMBNAIL = 0
    public static let CONTENTS_BOARD_IMG = 1

    // KEY
    public static let TMAP_APP_KEY = "7fcc4bac-2c24-41ed-b479-25e6b6c04a7f"
    public static let KAKAO_CLIENT_SECRET = "e8PA7oqSn2vPCGQhy9ri92FGJ79e7kAZ"
    public static let NAVER_MAP_KEY = "g2f2wjr9hl"

    // 충전소 타입: must sync db
    public static let CHARGER_TYPE_DCDEMO            = 1    // DC차데모
    public static let CHARGER_TYPE_SLOW              = 2    // 완속
    public static let CHARGER_TYPE_DCDEMO_AC         = 3    // DC차데모+AC상
    public static let CHARGER_TYPE_DCCOMBO           = 4    // DC콤보
    public static let CHARGER_TYPE_DCDEMO_DCCOMBO    = 5    // DC차데모 + DC콤보
    public static let CHARGER_TYPE_DCDEMO_DCCOMBO_AC = 6    // DC차데모 + AC상 + DC콤보
    public static let CHARGER_TYPE_AC                = 7    // AC상
    public static let CHARGER_TYPE_DCCOMBO_AC        = 8    // DC콤보+AC3상
    public static let CHARGER_TYPE_ETC               = 9    // 기타
    public static let CHARGER_TYPE_HYDROGEN          = 10    // 수소연료자동차
    public static let CHARGER_TYPE_SUPER_CHARGER     = 11   // 수퍼차저
    public static let CHARGER_TYPE_DESTINATION       = 12   // 데스티네이션
    
    // 충전소 타입: 충전소 내의 전체 충전기 타입을 확인하기 위해 새로 정의함
    public static let CTYPE_DCDEMO          = 1  // 0000 0001 - DC차데모
    public static let CTYPE_AC              = 2  // 0000 0010 - AC3상
    public static let CTYPE_DCCOMBO         = 4  // 0000 0100 - DC콤보
    public static let CTYPE_SLOW            = 8  // 0000 1000 - 완속
    public static let CTYPE_HYDROGEN        = 16 // 0001 0000 - 수소
    public static let CTYPE_SUPER_CHARGER   = 32 // 0010 0000 - 수퍼차저
    public static let CTYPE_DESTINATION     = 64 // 0100 0000 - 데스티네이션
    
    // 충전소 상태: must sync db
    public static let CHARGER_STATE_UNCONNECTED      = 1    // 통신미연결
    public static let CHARGER_STATE_WAITING          = 2    // 대기중
    public static let CHARGER_STATE_CHARGING         = 3    // 충전중
    public static let CHARGER_STATE_INACTIVE         = 4    // 운영중지
    public static let CHARGER_STATE_CHECKING         = 5    // 점검중
    public static let CHARGER_STATE_BOOKING          = 6    // 예약중
    public static let CHARGER_STATE_PILOT            = 7    // 시범운영중
    public static let CHARGER_STATE_UNKNOWN          = 9    // 기타(상태미확인)
    
    struct BoardConstants {
        static let titlePlaceHolder = "제목을 입력해주세요."
        static let contentsPlaceHolder = "내용을 입력해주세요."
        static let chargerPlaceHolder = "충전소 검색"
    }
}

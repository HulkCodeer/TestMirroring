//
//  Const.swift
//  evInfra
//
//  Created by bulacode on 2018. 3. 6..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation

public class Const {

    /*
     * product
     */
//    public static let EV_SERVER_IP = "https://app.soft-berry.co.kr" // company server
//    public static let EV_PAY_SERVER = "https://api.soft-berry.co.kr"
    
    /*
     * dev
     */
    public static let EV_SERVER_IP = "http://211.53.109.212:2025"  // test server
    public static let EV_PAY_SERVER = "http://dev.soft-berry.co.kr"
//    public static let EV_PAY_SERVER = "http://spark.soft-berry.co.kr"
//    public static let EV_PAY_SERVER = "http://smart.soft-berry.com"

    // S3 File Server
    public static let S3_EV_INFRA = "https://s3.ap-northeast-2.amazonaws.com/ev-infra"
    public static let urlCompanyImage = S3_EV_INFRA + "/company_icon/"
    public static let urlProfileImage = S3_EV_INFRA + "/thumbnail/"
    public static let urlModelImage = S3_EV_INFRA + "/models/"
    public static let urlBoardImage = S3_EV_INFRA + "/board/"
    public static let urlShareImage = S3_EV_INFRA + "/share/shareimage.jpg"
    public static let urlSatellite = S3_EV_INFRA + "/images/"

    // KEY
    public static let TMAP_APP_KEY = "7fcc4bac-2c24-41ed-b479-25e6b6c04a7f"
    public static let KAKAO_CLIENT_SECRET = "e8PA7oqSn2vPCGQhy9ri92FGJ79e7kAZ"

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

    // 제보하기 호출자
    public static let REPORT_CHARGER_FROM_MAIN = 0
    public static let REPORT_CHARGER_FROM_DETAIL = 1
    public static let REPORT_CHARGER_FROM_LIST = 2
    
    // 제보하기 유형
    public static let REPORT_CHARGER_TYPE_ETC = 0               // 충전소 제보 타입
    public static let REPORT_CHARGER_TYPE_USER_ADD = 1          // 누락 충전소 제보
    public static let REPORT_CHARGER_TYPE_USER_ADD_MOD = 2      // 제보한 충전소 정보 수정
    public static let REPORT_CHARGER_TYPE_USER_ADD_DELETE = 3   // 제보한 충전소 삭제
    public static let REPORT_CHARGER_TYPE_USER_MOD = 4          // 기존 충전소 정보 수정
    public static let REPORT_CHARGER_TYPE_USER_MOD_DELETE = 5   // 기존 충전소 정보 수정 요청 취소
    
    // 제보하기 처리 상태 (디비 테이블의 상태 코드와 매칭되야함)
    public static let REPORT_CHARGER_STATUS_FINISH = 1   // 완료
    public static let REPORT_CHARGER_STATUS_CONFIRM = 2  // 확인
    public static let REPORT_CHARGER_STATUS_REJECT = 3   // 반려
    
    //  BUCKET KIND
    // KIND OF IMAGE
    public static let CONTENTS_THUMBNAIL = 0;
    public static let CONTENTS_BOARD_IMG = 1;
    public static let CONTENTS_SATELLITE = 2;
    public static let CONTENTS_CAR_MODEL = 3;
    public static let CONTENTS_COMP_ICON = 4;
}

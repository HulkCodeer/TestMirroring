//
//  ReportData.swift
//  evInfra
//
//  Created by 이신광 on 2018. 9. 14..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation

class ReportData {
    
    // 제보하기 호출자
    public static let REPORT_CHARGER_FROM_DETAIL = 1
    public static let REPORT_CHARGER_FROM_LIST   = 2
    
    // 제보하기 유형
//    public static let REPORT_CHARGER_TYPE_ETC = 0               // 충전소 제보 타입
//    public static let REPORT_CHARGER_TYPE_USER_ADD = 1          // 누락 충전소 제보
//    public static let REPORT_CHARGER_TYPE_USER_ADD_MOD = 2      // 제보한 충전소 정보 수정
//    public static let REPORT_CHARGER_TYPE_USER_ADD_DELETE = 3   // 제보한 충전소 삭제
    public static let REPORT_CHARGER_TYPE_USER_MOD = 4          // 기존 충전소 정보 수정
    public static let REPORT_CHARGER_TYPE_USER_MOD_DELETE = 5   // 기존 충전소 정보 수정 요청 취소
    
    // 제보하기 처리 상태 (디비 테이블의 상태 코드와 매칭되야함)
    public static let REPORT_CHARGER_STATUS_FINISH = 1   // 완료
    public static let REPORT_CHARGER_STATUS_CONFIRM = 2  // 확인
    public static let REPORT_CHARGER_STATUS_REJECT = 3   // 반려
    
    struct ReportChargeInfo {
        var from: Int?
        var report_id = 0
        var type_id: Int?
        var status_id: Int?
        var lat: Double?
        var lon: Double?
        var adr: String?
        var adr_dtl: String?
        var snm: String?
        var utime: String?
        var tel: String?
        var pay: String?
        var company_id: String?
        var charger_id: String?
        
        var clist = Array<Int>()
    }
}

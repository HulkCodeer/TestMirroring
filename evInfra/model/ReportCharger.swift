//
//  ReportData.swift
//  evInfra
//
//  Created by 이신광 on 2018. 9. 14..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

class ReportCharger {
    
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
    
    var report_id = 0
    var type_id: Int?
    var status_id: Int?
    var type: String?
    var status: String?
    var charger_id: String?
    var snm: String?
    var lat: Double?
    var lon: Double?
    var adr: String?
    var adr_dtl: String?
    var reg_date: String?
    var admin_cmt: String?
    
    init() {
    }
    
    init(json: JSON) {
        report_id = json["report_id"].intValue
        status_id = json["status_id"].intValue
        charger_id = json["charger_id"].stringValue
        snm = json["snm"].stringValue
        status = json["status"].stringValue
        type = json["type"].stringValue
        reg_date = json["reg_date"].stringValue
        admin_cmt = json["admin_cmt"].stringValue
    }
}

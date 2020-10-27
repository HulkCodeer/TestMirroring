//
//  ReportData.swift
//  evInfra
//
//  Created by 이신광 on 2018. 9. 14..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation

class ReportData {
    
    struct ReportChargeInfo {
        var from: Int?
        var report_id: Int? = 0
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

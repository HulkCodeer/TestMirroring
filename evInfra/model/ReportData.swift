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
        var pkey: Int? = 0
        var type: Int?
        var status_id: Int?
        var lat: Double?
        var lon: Double?
        var adr: String?
        var snm: String?
        var utime: String?
        var tel: String?
        var pay: String?
        var companyID: String?
        var chargerID: String?
        
        var clist = Array<Int>()
    }
}

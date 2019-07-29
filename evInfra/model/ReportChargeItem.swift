//
//  ReportChargeItem.swift
//  evInfra
//
//  Created by 이신광 on 2018. 9. 18..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation

class ReportChargeItem {
    var pkey: Int?
    var charger_id: String?
    var station_name: String?
    var type_id: Int?
    var status_id: Int?
    var type: String?
    var status: String?
    var reg_date:String?
    var latitude: Double?
    var longitude: Double?
    var address: String?
    var adminComment: String?
    
    init(item:ReportChargeInfoList.RCInfo) {
        if let key = item.pkey {
            self.pkey = key
        } else {
            self.pkey = 0
        }
        
        if let cid = item.charger_id {
            self.charger_id = cid
        } else {
            self.charger_id = ""
        }
        
        if let snm = item.station_name {
            self.station_name = snm
        } else {
            self.station_name = ""
        }
        
        if let tid = item.type_id {
            self.type_id = tid
        } else {
            self.type_id = 0
        }
        
        if let sid = item.status_id {
            self.status_id = sid
        } else {
            self.status_id = 0
        }
        
        if let tp = item.type {
            self.type = tp
        } else {
            self.type = ""
        }
        
        if let st = item.status {
            self.status = st
        } else {
            self.status = ""
        }
        
        if let rdate = item.reg_date {
            self.reg_date = rdate
        } else {
            self.reg_date = ""
        }
        
        if let lat = item.latitude {
            self.latitude = Double(lat)
        } else {
            self.latitude = 0.0
        }
        
        if let lon = item.longitude {
            self.longitude = Double(lon)
        } else {
            self.longitude = 0.0
        }
        
        if let adr = item.address {
            self.address = adr
        } else {
            self.address = ""
        }
        
        if let msg = item.adminComment {
            self.adminComment = msg
        } else {
            self.adminComment = ""
        }
    }
    
    init() {
        self.pkey = 0
        self.charger_id = ""
        self.station_name = ""
        self.type_id = 0
        self.status_id = 0
        self.type = ""
        self.status = ""
        self.reg_date = ""
        self.latitude = 0.0
        self.longitude = 0.0
        self.address = ""
        self.adminComment = ""
    }
}

//
//  ReportChargeInfoList.swift
//  evInfra
//
//  Created by 이신광 on 2018. 9. 17..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation

struct ReportChargeInfoList: Codable {
    var lists: [RCInfo]?
    
    struct RCInfo  : Codable {
        var pkey: Int?
        var charger_id: String?
        var station_name: String?
        var type_id: Int?
        var status_id: Int?
        var type: String?
        var status: String?
        var reg_date:String?
        var latitude: String?
        var longitude: String?
        var address: String?
        var adminComment: String?
        
        enum CodingKeys: String, CodingKey {
            case pkey = "pkey"
            case charger_id = "charger_id"
            case station_name = "snm"
            case type_id = "type_id"
            case status_id = "status_id"
            case type = "type"
            case status = "status"
            case reg_date = "r_date"
            case latitude = "lat"
            case longitude = "lon"
            case address = "adr"
            case adminComment = "admin_cmt"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            pkey = try values.decodeIfPresent(Int.self, forKey: .pkey)
            charger_id = try values.decodeIfPresent(String.self, forKey: .charger_id)
            station_name = try values.decodeIfPresent(String.self, forKey: .station_name)
            type_id = try values.decodeIfPresent(Int.self, forKey: .type_id)
            status_id = try values.decodeIfPresent(Int.self, forKey: .status_id)
            type = try values.decodeIfPresent(String.self, forKey: .type)
            status = try values.decodeIfPresent(String.self, forKey: .status)
            reg_date = try values.decodeIfPresent(String.self, forKey: .reg_date)
            latitude = try values.decodeIfPresent(String.self, forKey: .latitude)
            longitude = try values.decodeIfPresent(String.self, forKey: .longitude)
            address = try values.decodeIfPresent(String.self, forKey: .address)
            adminComment = try values.decodeIfPresent(String.self, forKey: .adminComment)
        }
    }
}

//
//  ChargingHistoryList.swift
//  evInfra
//
//  Created by Shin Park on 04/07/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

struct ChargingHistoryList: Decodable {
//    var resultCode: String?
//    var totalCount: String?
//    var totalChargingTime: String?
//    var totalChargingKwh: String?
//    var totalPay: String?
//    var chargingList: [ChargingStatus]?

    var code: Int?
    var msg: String?
    var total_cnt: String?
    var total_time: String?
    var total_kw: String?
    var total_pay: String?
    var list: [ChargingStatus]?
    
//    enum CodingKeys: String, CodingKey {
//        case code = "code"
//        case msg = "msg"
//        case total_cnt = "total_cnt"
//        case total_time = "total_time"
//        case total_kw = "total_kw"
//        case total_pay = "total_pay"
//        case list = "list"
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//    }
}

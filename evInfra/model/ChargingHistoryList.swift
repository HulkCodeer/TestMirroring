//
//  ChargingHistoryList.swift
//  evInfra
//
//  Created by Shin Park on 04/07/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

struct ChargingHistoryList: Decodable {
    var code: Int?
    var msg: String?
    var total_cnt: String?
    var total_time: String?
    var total_kw: String?
    var total_pay: String?
    var list: [ChargingStatus]?
}

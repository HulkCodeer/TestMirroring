//
//  ChargingID.swift
//  evInfra
//
//  Created by youjin kim on 2022/11/01.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

struct ChargingID: Decodable {
    let code: Int
    let chargingID: String
    let payCode: String
    
    // cpID
    // connectorID
    // point
    
    private enum CodingKeys: String, CodingKey {
        case code
        case chargingID = "charging_id"
        case payCode = "pay_code"
    }
}

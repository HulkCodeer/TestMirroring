//
//  PointHistory.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

struct PointHistory: Decodable {
    let code: Int?
    let message: String?
    let totalPoint: String
    let list: [EvPoint]?
    let expirePoint: String
    
    init(
        code: Int?,
        message: String?,
        totalPoint: String?,
        list: [EvPoint]?,
        expirePoint: String?
    ) {
        self.code = code
        self.message = message
        self.totalPoint = totalPoint ?? "0"
        self.list = list
        self.expirePoint = totalPoint ?? "0"
    }
    
    private enum CodingKeys: String, CodingKey {
        case code, list
        case message = "msg"
        case totalPoint = "total_point"
        case expirePoint = "expire_point"
    }
}

//
//  Notice.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/29.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

struct Notice: Decodable {
    let code: Int
    let title: String
    let content: String
    let dateTime: String

    private enum CodingKeys: String, CodingKey {
        case code, title, content
        case dateTime = "datetime"
    }
}

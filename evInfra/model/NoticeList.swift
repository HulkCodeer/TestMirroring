//
//  NoticeList.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/31.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

struct NoticeList: Decodable {
    let code: Int
    let list: [NoticeItem]
    
}

struct NoticeItem: Decodable {
    let id: String
    let title: String
    let dateTime: String
    
    private enum CodingKeys: String, CodingKey {
        case id, title
        case dateTime = "datetime"
    }
}

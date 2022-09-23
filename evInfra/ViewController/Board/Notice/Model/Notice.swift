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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let date = (try? container.decode(String.self, forKey: .dateTime)) ?? String()
        
        self.code = try container.decode(Int.self, forKey: .code)
        self.title = (try? container.decode(String.self, forKey: .title)) ?? "[공지]"
        self.content = (try? container.decode(String.self, forKey: .content)) ?? String()
        self.dateTime = date.toDate()?.toString(dateFormat: .yyyyMMddD) ?? String()
    }
}
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

    private enum CodingKeys: String, CodingKey {
        case code
        case list
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.code = try container.decode(Int.self, forKey: .code)
        self.list = (try? container.decode([NoticeItem].self, forKey: .list)) ?? [NoticeItem]()
    }
    
    
    struct NoticeItem: Decodable {
        let id: Int
        let title: String
        let dateTime: String
        
        private enum CodingKeys: String, CodingKey {
            case id, title
            case dateTime = "datetime"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let id = try container.decode(String.self, forKey: .id)
            let date = (try? container.decode(String.self, forKey: .dateTime)) ?? String()
            
            self.id = Int(id) ?? -1
            self.title = (try? container.decode(String.self, forKey: .title)) ?? String()
            self.dateTime = date.toDate()?.toString(dateFormat: .yyyyMMddD) ?? String()
        }
    }
    
}

//
//  Notice.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/29.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

struct Notice: Codable {
    let code: Int
    let title: String
    let date: String?
    let content: String
    
}

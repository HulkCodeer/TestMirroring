//
//  EIAdInfo.swift
//  evInfra
//
//  Created by Shin Park on 2021/11/19.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Ad: Decodable {
    var ad_id: String?
    var ad_url: String?
    var ad_description: String?
    var ad_weight: String?
    var client_id: String?
    var client_name: String?
    var ad_logo: String?
    var ad_image: String?
    
    init() {}
    init(_ json: JSON) {
        self.ad_id = json["ad_id"].stringValue
        self.ad_url = json["ad_url"].stringValue
        self.ad_description = json["ad_description"].stringValue
        self.ad_weight = json["ad_weight"].stringValue
        self.client_id = json["client_id"].stringValue
        self.client_name = json["client_name"].stringValue
        self.ad_logo = json["ad_logo"].stringValue
        self.ad_image = json["ad_image"].stringValue
    }
}

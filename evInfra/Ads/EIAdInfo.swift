//
//  EIAdInfo.swift
//  evInfra
//
//  Created by Shin Park on 2021/11/19.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation

class EIAdInfo {
    var adId: Int?
    var adWeight: Int?
    
    var adUrl: String?
    var adDescrption: String?
    var adLogo: String?
    var adImage: String?
    
    var clientId: Int?
    var clientName: String?
}

struct Ad: Decodable {
    var ad_id: String?
    var ad_url: String?
    var ad_description: String?
    var ad_weight: String?
    var client_id: String?
    var client_name: String?
    var ad_logo: String?
    var ad_image: String?
}

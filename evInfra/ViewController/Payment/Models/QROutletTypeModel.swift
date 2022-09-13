//
//  QRChargerTypeModel.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/08/30.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import SwiftyJSON

internal struct QROutletTypeModel {
    var id: Int
    var title: String
    
    init(_ json: JSON) {
        self.id = json["id"].intValue
        self.title = json["title"].stringValue
    }
}

//
//  AdsModel.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/08/03.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

internal struct AdsListDataModel {
    var code: String
    var msg: String
    var data: [AdsInfo]
    
    init(_ json: JSON) {
        self.code = json["code"].stringValue
        self.msg = json["msg"].stringValue
        self.data = json["data"].arrayValue.map {
            AdsInfo($0)
        }
    }
}

internal struct AdsInfo {
    var evtId: String = ""
    var img: String = ""
    var logo: String = ""
    var extUrl: String = ""
    var evtDesc: String = ""
    var evtTitle: String = ""
    var evtWeight: Int = 0
    var clientName: String = ""
    var evtType: String = ""
    var dpStart: String = ""
    var dpEnd: String = ""
    var dpState: Int = 0
    
    init() {}
    
    init(_ json: JSON) {
        self.evtId = json["evtId"].stringValue
        self.img = json["img"].stringValue
        self.logo = json["logo"].stringValue
        self.extUrl = json["url"].stringValue
        self.evtDesc = json["evtDesc"].stringValue
        self.evtTitle = json["evtTitle"].stringValue
        self.evtWeight = json["evtWeight"].intValue
        self.clientName = json["clientName"].stringValue
        self.evtType = json["evtType"].stringValue
        self.dpStart = json["dpStart"].stringValue
        self.dpEnd = json["dpEnd"].stringValue
        self.dpState = json["dpState"].intValue
    }
}


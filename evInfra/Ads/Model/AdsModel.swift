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
    var url: String = ""
    var detail: [Any] = [Any]()
    var extra: Any? = nil
    var evtTitle: String = ""
    var evtWeight: String = ""
    var clientName: String = ""
    var evtType: String = ""
    var dpStart: String = ""
    var dpEnd: String = ""
    
    init() {}
    
    init(_ json: JSON) {
        self.evtId = json["evtId"].stringValue
        self.img = json["img"].stringValue
        self.logo = json["logo"].stringValue
        self.url = json["url"].stringValue
        self.detail = json["detail"].arrayValue
        self.extra = json["extra"].object
        self.evtTitle = json["evtTitle"].stringValue
        self.evtWeight = json["evtWeight"].stringValue
        self.clientName = json["clientName"].stringValue
        self.evtType = json["evtType"].stringValue
        self.dpStart = json["dpStart"].stringValue
        self.dpEnd = json["dpEnd"].stringValue
    }
}


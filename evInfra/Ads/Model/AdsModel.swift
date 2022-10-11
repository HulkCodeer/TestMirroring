//
//  AdsModel.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/08/03.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

internal struct AdsInfo {
    var evtId: String
    var img: String
    var thumbNail: String
    var logo: String
    var extUrl: String
    var evtDesc: String
    var evtTitle: String
    var evtWeight: Int = 0
    var clientName: String
    var evtType: String
    var convertEvtType: Promotion.Types = .ad
    var dpStart: String
    var dpEnd: String
    var dpState: Promotion.State = .end
    var promotionPage: Promotion.Page = .start
    var promotionLayer: Promotion.Layer = .none
    var oldId: Int = 0
    
    init(_ json: JSON) {
        self.evtId = json["evtId"].stringValue
        self.img = json["img"].stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        self.logo = json["logo"].stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        self.extUrl = json["extUrl"].stringValue
        self.evtDesc = json["evtDesc"].stringValue
        self.evtTitle = json["evtTitle"].stringValue
        self.evtWeight = json["evtWeight"].intValue
        self.clientName = json["clientName"].stringValue
        self.evtType = json["evtType"].stringValue
        self.convertEvtType = Promotion.Types(rawValue: self.evtType) ?? .ad
        self.dpStart = json["dpStart"].stringValue
        self.dpEnd = json["dpEnd"].stringValue
        self.dpState = Promotion.State.convert(with: json["dpState"].intValue)
        self.oldId = json["oldId"].intValue
        self.thumbNail = json["thumbNail"].stringValue
    }
}


//
//  MembershipCardInfoModel.swift
//  evInfra
//
//  Created by 박현진 on 2022/10/24.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import SwiftyJSON

internal struct MembershipCardInfo {
    let code: Int
    let cardNo: String
    let status: String
    let date: String
    let info: Info

    init(_ json: JSON) {
        self.code = json["code"].intValue
        self.cardNo = json["card_no"].stringValue
        self.status = json["status"].stringValue
        self.date = json["date"].stringValue
        self.info = Info(json["info"])
    }
    
    internal struct Info {
        let name: String
        let phone: String
        let zip: String
        let addr: String
        let addrDtl: String
        
        init(_ json: JSON) {
            self.name = json["name"].stringValue
            self.phone = json["phone"].stringValue
            self.zip = json["zip"].stringValue
            self.addr = json["addr"].stringValue
            self.addrDtl = json["addr_dtl"].stringValue
        }
    }
}

//
//  MemberPartnershipInfo.swift
//  evInfra
//
//  Created by SH on 2020/10/08.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
class MemberPartnershipInfo {
    var mbId: Int?
    var clientId: Int?
    var cardNo: String?
    var status: String?
    var date: String?
    var carNo: String?
    var mobileCardNum: String?
    var mpCardNum: String?
    var level: String?
    var startDate: String?
    var endDate: String?
    
    init(json: JSON){
        self.mbId = json["mb_id"].intValue
        self.clientId = json["client_id"].intValue
        self.cardNo = json["card_no"].stringValue
        self.status = json["status"].stringValue
        self.date = json["date"].stringValue
        self.carNo = json["car_no"].stringValue
        self.mobileCardNum = json["mobile_card_num"].stringValue
        self.mpCardNum = json["mp_card_num"].stringValue
        self.startDate = json["start_date"].stringValue
        self.endDate = json["end_date"].stringValue
    }
}

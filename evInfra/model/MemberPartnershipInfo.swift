//
//  MemberPartnershipInfo.swift
//  evInfra
//
//  Created by SH on 2020/10/08.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import SwiftyJSON

internal final class MemberPartnershipInfo {
    enum CardStatusType: String {
        case readyShip = "0" // 발송 준비중
        case issuanceCompleted = "1" // 발급 완료
        case cardLost = "2"// 카드 분실
        case siipping = "4" // 발송중
        case error // 상태오류
        
        init(_ rawValue: String) {
            switch rawValue {
            case "0": self = .readyShip
            case "1": self = .issuanceCompleted
            case "2": self = .cardLost
            case "4": self = .siipping
            default: self = .error
            }
        }
        
        func showDisplayType() -> String {
            switch self {
            case .readyShip: return "발송 준비중"
            case .issuanceCompleted: return "발급 완료"
            case .cardLost: return "카드 분실"
            case .siipping: return "발송중"
            case .error: return "상태 오류"
            }
        }
    }
    
    var mbId: Int?
    var clientId: Int?
    var cardNo: String?
    var status: String
    var cardStatusType: CardStatusType
    var displayStatusDescription: String
    var date: Date
    var displayDate: String
    var carNo: String?
    var mobileCardNum: String?
    var mpCardNum: String?
    var level: String?
    var startDate: String?
    var endDate: String?
    
    init(_ json: JSON){
        self.mbId = json["mb_id"].intValue
        self.clientId = json["client_id"].intValue
        self.cardNo = json["card_no"].stringValue
        self.status = json["status"].stringValue
        self.cardStatusType = CardStatusType(json["status"].stringValue)
        self.date = json["date"].dateValue
        self.displayDate = self.date.toYearMonthDay()        
        self.displayStatusDescription = self.cardStatusType == .issuanceCompleted ? self.displayDate : self.cardStatusType.showDisplayType()
        self.carNo = json["car_no"].stringValue
        self.mobileCardNum = json["mobile_card_num"].stringValue
        self.mpCardNum = json["mp_card_num"].stringValue
        self.startDate = json["start_date"].stringValue
        self.endDate = json["end_date"].stringValue
    }
}

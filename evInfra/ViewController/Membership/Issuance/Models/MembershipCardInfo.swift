//
//  MembershipCardInfoModel.swift
//  evInfra
//
//  Created by 박현진 on 2022/10/24.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import SwiftyJSON

internal enum ShipmentStatusType: Int, CaseIterable {
    case sendReady = 0
    case sending = 4
    case sendComplete = 1
    
    internal var toString: String {
        switch self {
        case .sendReady: return "발송 준비중"
        case .sending: return "발송중"
        case .sendComplete: return "우편함 확인"
        }
    }
    
    internal var toMessage: String {
        switch self {
        case .sendReady:
            return "신청 내용을 확인중입니다.\n영업일 기준 2~3일내로 발송 예정입니다."
        case .sending:
            return "EV Pay 카드가 회원님께 가고 있어요! ✉️\n영업일 기준 약 7일 뒤 도착할거에요.\n우편 발송되어 도착 날짜가 정확하지 않을 수 있으니\n양해 부탁드려요."
        case .sendComplete: return ""
        }
    }
}

internal struct MembershipCardInfo: Equatable {
    enum PassType {
        case nextStep
        case complete
        case current
        case none
    }
    
    struct ConvertStatus {
        internal var shipmentStatusType: ShipmentStatusType
        internal var passType: PassType
        
        init(shipmentStatusType: ShipmentStatusType, passType: PassType) {
            self.shipmentStatusType = shipmentStatusType
            self.passType = passType
        }
    }
    
    let code: Int
    let cardNo: String
    let status: String
    let date: String
    let info: Info
    var convertStatusArr: [ConvertStatus] = []

    init(_ json: JSON) {
        self.code = json["code"].intValue
        self.cardNo = json["card_no"].stringValue
        self.status = json["status"].stringValue
        self.date = json["date"].stringValue
        self.info = Info(json["info"])
        
        var passType: PassType = .complete
        let statusValue: Int = json["status"].intValue
        for type in ShipmentStatusType.allCases {
                                    
            if passType == .current {
                passType = .nextStep
            }
            
            if type == ShipmentStatusType(rawValue: statusValue)  {
                passType = .current
            }
                                    
            self.convertStatusArr.append(ConvertStatus(shipmentStatusType: type, passType: passType))
        }                
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
    
    static func == (lhs: MembershipCardInfo, rhs: MembershipCardInfo) -> Bool {
        lhs.cardNo == rhs.cardNo
    }
}

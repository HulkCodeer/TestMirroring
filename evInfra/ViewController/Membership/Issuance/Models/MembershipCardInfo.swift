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
    case sending = 1
    case sendComplete = 2
    
    internal var toString: String {
        switch self {
        case .sendReady: return "발송 준비중"
        case .sending: return "발송중"
        case .sendComplete: return "우편함 확인"
        }
    }    
}

internal struct MembershipCardInfo {
    enum PassType {
        case pass
        case complete
        case current
    }
    
    struct ConvertStatus {
        internal var shipmentStatusType: ShipmentStatusType
        internal var passType: PassType
        
        init(status: Int, passType: PassType) {
            self.shipmentStatusType = ShipmentStatusType(rawValue: status) ?? .sendReady
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
        
        var passType: PassType = .pass
        var statusValue: Int = json["status"].intValue
        for type in ShipmentStatusType.allCases {            
            if passType == .current {
                passType = .complete
            }
            
            if type == ShipmentStatusType(rawValue: statusValue)  {
                passType = .current
            }
                                    
            self.convertStatusArr.append(ConvertStatus(status: json["status"].intValue, passType: passType))
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
}

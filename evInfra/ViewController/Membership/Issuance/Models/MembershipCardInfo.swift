//
//  MembershipCardInfoModel.swift
//  evInfra
//
//  Created by 박현진 on 2022/10/24.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import SwiftyJSON

internal enum ShipmentStatusType: Int, CaseIterable {
    case sendReady = 1
    case sending = 2
    case mailboxConfirm = 3
    case sendComplete = 4
    
    internal var toString: String {
        switch self {
        case .sendReady: return "신청 접수"
        case .sending: return "발송 시작"
        case .mailboxConfirm: return "우편함 확인"
        case .sendComplete: return ""
        }
    }
    
    internal var toMessage: String {
        switch self {
        case .sendReady:
            return "신청 내용을 확인중입니다.\n영업일 기준 2~3일내로 발송 예정입니다."
        case .sending:
            return "EV Pay 카드가 회원님께 가고 있어요! ✉️\n영업일 기준 약 7일 뒤 도착할거에요.\n우편 발송되어 도착 날짜가 정확하지 않을 수 있으니\n양해 부탁드려요."
        case .mailboxConfirm: return ""
        case .sendComplete: return ""
        }
    }
}

internal struct MembershipCardInfo: Equatable {
    let code: Int
    let cardNo: String
    let status: String
    let regDate: String
    let displayRegDate: String
    let destination: Destination
    let delivery: Delivery
    
    init(_ json: JSON) {
        self.code = json["code"].intValue
        self.cardNo = json["card_no"].stringValue
        self.status = json["status"].stringValue
        self.regDate = json["reg_date"].stringValue
        self.displayRegDate = Date().toDate(data: self.regDate)?.toString(dateFormat: .yyyyMMddHHmmD) ?? ""
        self.destination = Destination(json["destination"])
        self.delivery = Delivery(json["delivery"])
        self.displayCardNo = self.cardNo?.replaceAll(of : "(\\d{4})(?=\\d)", with : "$1-")
        guard let _cardNo = self.cardNo, _cardNo.startsWith("2095") else {
            self.isReissuance = false
            return
        }
        self.isReissuance = !(self.cardStatusType == .sipping || self.cardStatusType == .readyShip)
    }
    
    internal struct Destination {
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

internal struct Delivery {
    let status: String
    let startDate: String
    let displayDate: String
    
    private var convertStatusArr: [ConvertStatus] = []
    
    init(_ json: JSON) {
        self.status = json["status"].stringValue
        self.startDate = json["start_date"].stringValue
        self.displayDate = Date().toDate(data: self.startDate)?.toString(dateFormat: .yyyyMMddHHmmD) ?? ""
        
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
}

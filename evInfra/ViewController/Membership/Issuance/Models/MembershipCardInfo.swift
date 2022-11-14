//
//  MembershipCardInfoModel.swift
//  evInfra
//
//  Created by 박현진 on 2022/10/24.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import SwiftyJSON

internal enum ShipmentStatusType: Int, CaseIterable {
    case sendReady = 1 // 회원카드 신청, 발송 준비중
    case sending = 2 // 회원카드 발송, 어드민에서 발송 시작을 누른 시점
    case mailboxConfirm = 3 // 우편함 확인
    case sendComplete = 4 // 카드 받기 완료
    
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
            return "EV Pay 카드가 회원님께 가고 있어요! ✉️\n영업일 기준 약 10일 뒤 도착할거에요.\n우편 발송되어 도착 날짜가 정확하지 않을 수 있으니\n양해 부탁드려요."
        case .mailboxConfirm: return ""
        case .sendComplete: return ""
        }
    }
}

internal struct MembershipCardInfo: Equatable {
    let cardNo: String
    let displayCardNo: String
    let destination: Destination
    let condition: Condition
    var isReissuance: Bool = false
    
    init(_ json: JSON) {
        self.cardNo = json["card_no"].stringValue
        self.destination = Destination(json["destination"])
        self.condition = Condition(json["condition"])
        self.displayCardNo = self.cardNo.replaceAll(of : "(\\d{4})(?=\\d)", with : "$1-")
        guard self.cardNo.startsWith("2095") else {
            self.isReissuance = false
            return
        }
        self.isReissuance = !(self.condition.convertStatusType == .sendReady ||
                              self.condition.convertStatusType == .sending)
    }
    
    internal struct Condition: Equatable {
        let status: Int
        let convertStatusType: ShipmentStatusType
        let regDate: String
        let startDate: String
        let displayRegDate: String
        let displayStartDate: String
        var convertStatusArr: [ConvertStatus] = []
        
        init(_ json: JSON) {
            self.status = json["status"].intValue
            self.convertStatusType = ShipmentStatusType(rawValue: self.status) ?? .sendReady
            self.regDate = json["reg_date"].stringValue
            self.startDate = json["start_date"].stringValue
            self.displayRegDate = Date().toDate(data: self.regDate)?.toString(dateFormat: .yyyyMMddHHmmD) ?? ""
            self.displayStartDate = Date().toDate(data: self.startDate)?.toString(dateFormat: .yyyyMMddHHmmD) ?? ""
            
            var passType: PassType = .complete
            for type in ShipmentStatusType.allCases {
                guard type != .sendComplete else { return }
                
                if passType == .current {
                    passType = .nextStep
                }
                if type == ShipmentStatusType(rawValue: self.status)  {
                    passType = .current
                }
                self.convertStatusArr.append(ConvertStatus(shipmentStatusType: type, passType: passType))
            }
        }
        
        static func == (lhs: Condition, rhs: Condition) -> Bool {
            lhs.status == rhs.status &&
            lhs.regDate == rhs.regDate &&
            lhs.startDate == rhs.startDate
        }
    }
    
    internal struct Destination: Equatable {
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
        
        static func == (lhs: Destination, rhs: Destination) -> Bool {
            lhs.name == rhs.name &&
            lhs.phone == rhs.phone &&
            lhs.zip == rhs.zip &&
            lhs.addr == rhs.addr &&
            lhs.addrDtl == rhs.addrDtl
        }
    }
            
    static func == (lhs: MembershipCardInfo, rhs: MembershipCardInfo) -> Bool {
        lhs.cardNo == rhs.cardNo &&
        lhs.isReissuance == rhs.isReissuance &&
        lhs.condition == rhs.condition &&
        lhs.destination == rhs.destination &&
        lhs.displayCardNo == rhs.displayCardNo
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

//
//  ChargingStatus.swift
//  evInfra
//
//  Created by Shin Park on 04/07/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

class ChargingStatus: Decodable, Equatable {
    static func == (lhs: ChargingStatus, rhs: ChargingStatus) -> Bool {
        return lhs.chargingId == rhs.chargingId
    }
    
    var resultCode: Int?
    var msg: String?

    var status: Int?
    var stationName: String?
    var companyId: String?
    var chargingId: String?
    var cpId: String?

    var startDate: String? // 충전 시작 일시
    var connectDate: String? // 충전기 연결 일시
    var endDate: String? // 충전 종료 일시
    var updateTime: String? // 충전정보 업데이트 일시

    var chargingTime: String? // 충전 시간
    var chargingKw: String? // 충전량
    var chargingRate: String? // 충전률

    var usedPoint: String?
    var fee: String?
    var payAmount: String?

    var payAuthDate: String? // 승인날짜
    var payAuthCode: String? // 승인번호
    var payResultCode: String?
    var payResultMsg: String?

    var savePoint: String? // 적립포인트
    var totalPoint: String? // 잔여포인트

    var cardNumber: String?
    var cardCo: String?
    
    var discountAmt: String?
    var discountMsg: String?

    enum CodingKeys: String, CodingKey {
        case code = "code"
        case msg = "msg"

        case status = "status"
        case snm = "snm"
        case company_id = "company_id"
        case charging_id = "charging_id"
        case cp_id = "cp_id"

        case s_date = "s_date"
        case c_date = "c_date"
        case e_date = "e_date"
        case u_date = "u_date"

        case c_time = "c_time"
        case c_kw = "c_kw"
        case rate = "rate"

        case u_point = "u_point"
        case fee = "fee"
        case pay_amt = "pay_amt"

        case pay_date = "pay_date"
        case pay_code = "pay_code"
        case pay_rcode = "pay_rcode"
        case pay_msg = "pay_msg"

        case save_point = "save_point"
        case total_point = "total_point"

        case card_nm = "card_nm"
        case card_co = "card_co"
        
        case discount_amt = "discount_amt"
        case discount_msg = "discount_msg"
    }

    required init() {
        
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        resultCode = try values.decodeIfPresent(Int.self, forKey: .code)
        msg = try values.decodeIfPresent(String.self, forKey: .msg)

        status = try values.decodeIfPresent(Int.self, forKey: .status)
        stationName = try values.decodeIfPresent(String.self, forKey: .snm)
        companyId = try values.decodeIfPresent(String.self, forKey: .company_id)
        chargingId = try values.decodeIfPresent(String.self, forKey: .charging_id)
        cpId = try values.decodeIfPresent(String.self, forKey: .cp_id)

        startDate = try values.decodeIfPresent(String.self, forKey: .s_date)
        connectDate = try values.decodeIfPresent(String.self, forKey: .c_date)
        endDate = try values.decodeIfPresent(String.self, forKey: .e_date)
        updateTime = try values.decodeIfPresent(String.self, forKey: .u_date)

        chargingTime = try values.decodeIfPresent(String.self, forKey: .c_time)
        chargingKw = try values.decodeIfPresent(String.self, forKey: .c_kw)
        chargingRate = try values.decodeIfPresent(String.self, forKey: .rate)

        usedPoint = try values.decodeIfPresent(String.self, forKey: .u_point)
        fee = try values.decodeIfPresent(String.self, forKey: .fee)

        payAmount = try values.decodeIfPresent(String.self, forKey: .pay_amt)
        payAuthDate = try values.decodeIfPresent(String.self, forKey: .pay_date)
        payAuthCode = try values.decodeIfPresent(String.self, forKey: .pay_code)
        payResultCode = try values.decodeIfPresent(String.self, forKey: .pay_rcode)
        payResultMsg = try values.decodeIfPresent(String.self, forKey: .pay_msg)

        savePoint = try values.decodeIfPresent(String.self, forKey: .save_point)
        totalPoint = try values.decodeIfPresent(String.self, forKey: .total_point)

        cardNumber = try values.decodeIfPresent(String.self, forKey: .card_nm)
        cardCo = try values.decodeIfPresent(String.self, forKey: .card_co)
        
        discountAmt = try values.decodeIfPresent(String.self, forKey: .discount_amt)
        discountMsg = try values.decodeIfPresent(String.self, forKey: .discount_msg)
    }
}

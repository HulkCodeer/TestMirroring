//
//  ReissuanceModel.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/17.
//  Copyright © 2022 soft-berry. All rights reserved.
//

internal struct ReissuanceModel {
    var cardNo: String = ""
    var mbId: Int = MemberManager.getMbId()
    var mbPw: String = ""
    var mbName: String = ""
    var phoneNo: String = ""
    var zipCode: String = ""
    var addr: String = ""
    var addrDetail: String = ""
    
    var toParam: [String: Any] {
        [
            "card_no": self.cardNo,
            "mb_id": self.mbId,
            "mb_pw": self.mbPw,
            "mb_name": self.mbName,
            "phone_no": self.phoneNo,
            "zip_code": self.zipCode,
            "addr": self.addr,
            "addr_detail": self.addrDetail
        ]
    }
}

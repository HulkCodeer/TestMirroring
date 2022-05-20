//
//  ReissuanceModel.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/17.
//  Copyright © 2022 soft-berry. All rights reserved.
//

internal struct ReissuanceModel {
    var cardNo: String = ""
    var mbId: Int = MemberManager.shared.mbId
    var mbPw: String = ""
    var mbName: String = ""
    var phoneNo: String = ""
    var zipCode: String = ""
    var address: String = ""
    var addressDetail: String = ""
    
    var toParam: [String: Any] {
        [
            "card_no": self.cardNo,
            "mb_id": self.mbId,
            "mb_pw": self.mbPw,
            "mb_name": self.mbName,
            "phone_no": self.phoneNo,
            "zip_code": self.zipCode,
            "addr": self.address,
            "addr_detail": self.addressDetail
        ]
    }
}

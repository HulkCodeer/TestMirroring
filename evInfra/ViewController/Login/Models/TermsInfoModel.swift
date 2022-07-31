//
//  TermsInfoModel.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/29.
//  Copyright © 2022 soft-berry. All rights reserved.
//

struct TermsInfo {
    var termsId: String
    var agree: Bool
    
    var toParam: [String: Any] {
        [
            "term_id": self.termsId,
            "agree": self.agree
        ]
    }
}

//
//  TermsInfoModel.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/29.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import SwiftyJSON

struct TermsInfo {
    var termsId: String
    var agree: Bool
    
    init(_ json: JSON){
        self.termsId = json["term_id"].stringValue
        self.agree = json["agree"].boolValue
    }
    
    init(termsId: String, agree: Bool) {
        self.termsId = termsId
        self.agree = agree
    }
    
    var toParam: [String: Any] {
        [
            "term_id": self.termsId,
            "agree": self.agree
        ]
    }
}

//
//  QuitAccountReason.swift
//  evInfra
//
//  Created by 박현진 on 2022/06/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import SwiftyJSON

struct QuitAccountReasonModel {
    let reasonId: String
    let reasonMessage: String

    init(_ json: JSON) {
        self.reasonId = json["reason_id"].stringValue
        self.reasonMessage = json["reason_message"].stringValue
    }
}

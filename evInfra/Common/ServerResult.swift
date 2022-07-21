//
//  ServerResult.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/24.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import SwiftyJSON

protocol ServerResultProtocol {
    var code: Int { get set }
    var msg: String { get set }
}

struct ServerResult {
    let code:Int
    let msg: String
    
    init(_ json: JSON) {
        self.code = json["code"].intValue
        self.msg = json["msg"].stringValue
    }
}

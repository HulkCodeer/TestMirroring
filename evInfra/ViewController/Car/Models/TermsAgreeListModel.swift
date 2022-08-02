//
//  TermsAgreeListModel.swift
//  evInfra
//
//  Created by 박현진 on 2022/08/02.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import SwiftyJSON

struct TermsAgreeListModel: ServerResultProtocol {
    var msg: String = ""
    var code: Int
    var list: [TermsInfo]
    
    init(_ json: JSON){
        self.code = json["code"].intValue
        self.list = json["list"].arrayValue.map { TermsInfo($0) }
    }
}

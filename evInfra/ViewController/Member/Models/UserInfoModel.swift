//
//  UserInfo.swift
//  evInfra
//
//  Created by 박현진 on 2022/07/21.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

internal struct UserInfoModel: ServerResultProtocol {
    var code: Int
    var msg: String
    var mbZipCode: String = ""
    var mbAddr: String = ""
    var mbAddrDetail: String = ""
    var mbCarNo: String = ""
    var mbNickname: String = ""
    
    init(_ json: JSON){
        self.code = json["code"].intValue
        self.msg = json["msg"].stringValue
        self.mbZipCode = json["mb_zip_code"].stringValue
        self.mbAddr = json["mb_addr"].stringValue
        self.mbAddrDetail = json["mb_addr_detail"].stringValue
        self.mbCarNo = json["mb_car_no"].stringValue
        self.mbNickname = json["mb_nickname"].stringValue
    }    
}

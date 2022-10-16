//
//  NewCompanyInfo.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/10/14.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RealmSwift
import SwiftyJSON

internal final class CompanyInfoDB: Object {
    @Persisted(primaryKey: true) var companyId: String
    @Persisted var cardSetting: Bool?
    @Persisted var name : String?
    @Persisted var tel : String?
    @Persisted var iconName : String?
    @Persisted var iconDate : String?
    @Persisted var homepage : String?
    @Persisted var market : String?
    @Persisted var isVisible : Bool = true
    @Persisted var sort : Int?
    @Persisted var del : Bool?
    @Persisted var recommend : Bool?
    
    convenience init(_ json: JSON) {
        self.init()
        
        self.companyId = json["id"].stringValue
        self.cardSetting = json["card_setting"].boolValue
        self.name = json["name"].stringValue
        self.tel = json["tel"].stringValue
        self.iconName = json["ic_name"].stringValue
        self.iconDate = json["iconDate"].stringValue
        self.homepage = json["hp"].stringValue
        self.market = json["mk"].stringValue
        self.sort = json["sort"].intValue
        self.del = json["del"].boolValue
        self.recommend = json["recommend"].boolValue
    }
}




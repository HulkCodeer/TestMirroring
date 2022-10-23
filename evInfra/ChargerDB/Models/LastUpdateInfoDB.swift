//
//  InfoLastUpdateDB.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/10/23.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RealmSwift
import SwiftyJSON

internal final class LastUpdateInfoDB: Object {
    
    @Persisted(primaryKey: true) var mId : String?
    
    @Persisted var mInfoLastUpdateDate : String?
    @Persisted var mInfoType : String?
    
    
    convenience init(_ json: JSON) {
        self.init()
        
        self.mId = json["mId"].doubleValue
        self.mInfoLastUpdateDate = json["mInfoLastUpdateDate"].stringValue
        self.mInfoType = json["mInfoType"].stringValue
    }
}

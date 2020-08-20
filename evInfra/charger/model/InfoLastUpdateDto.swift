//
//  InfoLastUpdateDto.swift
//  evInfra
//
//  Created by Michael Lee on 2020/06/09.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
import GRDB
class InfoLastUpdateDto : Record{
    required init(row: Row) {
        mId = row["mId"]
        mInfoLastUpdateDate = row["mInfoLastUpdateDate"]
        mInfoType = row["mInfoType"]
        super.init(row: row)
    }
    
    override init(){
        super.init()
    }
    
    override class var databaseTableName: String {
        return "InfoLastUpdate"
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container["mId"] = mId
        container["mInfoLastUpdateDate"] = mInfoLastUpdateDate
        container["mInfoType"] = mInfoType
    }

    public var mId : Int?

    public var mInfoLastUpdateDate : String?

    public var mInfoType : String?

}

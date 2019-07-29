//
//  Connector.swift
//  evInfra
//
//  Created by bulacode on 02/07/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

class Connector {
    var mId: String?
    var mTypeId: String?
    var mTypeName: String?
    var mStatus: String?

    init(id: String, typeId: String, typeName: String, status: String){
        self.mId = id
        self.mTypeId = typeId
        self.mTypeName = typeName
        self.mStatus = status
    }
}

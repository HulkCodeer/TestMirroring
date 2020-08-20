//
//  StationStatusDto.swift
//  evInfra
//
//  Created by Michael Lee on 2020/06/09.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
import GRDB
class StationStatusDto : Record{
    required init(row: Row) {
        mChargerId = row["mChargerId"]
        mCst = row["mCst"]
        mTypeID = row["mTypeID"]
        mPower = row["mPower"]
        super.init(row: row)
    }
    
    override class var databaseTableName: String {
        return "StationStatus"
    }

    //@SerializedName("id")
    public var mChargerId : String?

    //@SerializedName("st")
    public var mCst : String?

    //@SerializedName("tp")
    public var mTypeID : String?

    //@SerializedName("p")
    public var mPower : String?

}

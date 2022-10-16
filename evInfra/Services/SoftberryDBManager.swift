//
//  SoftberryDBManager.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/10/15.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RealmSwift

protocol RealmDB: AnyObject {
    func writeCompanyInfoList(list: [CompanyInfoDB])
}

internal final class SoftberryDBManager: RealmDB {
    init() {}
    
    private var realmManger: Realm {
        get throws {
            return try Realm()
        }
    }
    
    func writeCompanyInfoList(list: [CompanyInfoDB]) {
        do {
            try self.realmManger.write { 
                for companyInfo in list {
                    try self.realmManger.add(companyInfo, update: .modified)
                }
            }
        } catch {
            printLog(out: "SoftberryDBManager Error : \(error)")
        }
    }
}

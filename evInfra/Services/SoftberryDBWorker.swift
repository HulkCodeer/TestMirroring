//
//  SoftberryDBWorker.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/10/15.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RealmSwift

protocol RealmDB: AnyObject {
    func writeCompanyInfoList(list: [CompanyInfoDB])
    func readCompanyInfoList() -> [CompanyInfoDB]
}

internal final class SoftberryDBWorker: RealmDB {
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
    
    func readCompanyInfoListBySortAsc() -> [CompanyInfoDB] {
        do {
            let list = [CompanyInfoDB]()
            for companyInfo in try realmManger.objects(CompanyInfoDB.self).filter("del = '0'").sorted(by: "sort") {
                list.append(companyInfo)
            }
            return list
        } catch {
            printLog(out: "SoftberryDBManager Error : \(error)")
        }
    }
}

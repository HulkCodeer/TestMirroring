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
    func readCompanyInfoListBySortAsc() -> [CompanyInfoDB]
    
    func writeLastUpdateInfo(lastDate: String)
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
            var list = [CompanyInfoDB]()
            for companyInfo in try realmManger.objects(CompanyInfoDB.self).filter("del == 0").sorted(byKeyPath: "sort") {
                list.append(companyInfo)
            }
            return list
        } catch {
            printLog(out: "SoftberryDBManager Error : \(error)")
            return []
        }
    }
    
    func writeLastUpdateInfo(lastDate: String) {
        guard !lastDate.isEmpty else { return }
        do {
            try self.realmManger.write {
                var lastUpdateInfoDB = LastUpdateInfoDB()
                lastUpdateInfoDB.mInfoType = "C"
                lastUpdateInfoDB.mInfoLastUpdateDate = lastDate
                try self.realmManger.add(lastUpdateInfoDB)
            }
        } catch {
            printLog(out: "SoftberryDBManager Error : \(error)")
        }
    }
}

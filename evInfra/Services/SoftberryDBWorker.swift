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
    func readCompanyUpdateLastDate() -> String
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
            var idx = 0
            if let lastInfoData = try self.realmManger.objects(LastUpdateInfoDB.self).last {
                idx = lastInfoData.mId + 1
            }
            
            try self.realmManger.write {
                let lastUpdateInfoDB = LastUpdateInfoDB()
                lastUpdateInfoDB.mId = idx
                lastUpdateInfoDB.mInfoType = "C"
                lastUpdateInfoDB.mInfoLastUpdateDate = lastDate
                try self.realmManger.add(lastUpdateInfoDB)
            }
        } catch {
            printLog(out: "SoftberryDBManager Error : \(error)")
        }
    }
    
    func readCompanyUpdateLastDate() -> String {
        do {
            var updateDate = ""
            if let lastUpdateInfoDB = try self.realmManger.objects(LastUpdateInfoDB.self).filter("mInfoType == 'C'").last {
                updateDate = lastUpdateInfoDB.mInfoLastUpdateDate
            }
            return updateDate
        } catch {
            printLog(out: "SoftberryDBManager Error : \(error)")
            return ""
        }
    }
}

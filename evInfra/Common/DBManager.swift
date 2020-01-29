//
//  DBManager.swift
//  evInfra
//
//  Created by bulacode on 2018. 7. 5..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import FMDB
import SwiftyJSON

class DBManager {
    
    static let sharedInstance = DBManager()
    
    let dbName : String = "ev_infra.db"
    var dbPath : String = ""
    
    private init() {
    }
    
    func openDB() {
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            dbPath = documentsURL.appendingPathComponent(dbName).path
            if !FileManager.default.fileExists(atPath: dbPath) {
                copyDB()
            } else {
                updateDB()
            }
        }
    }
    
    func copyDB() {
        do {
            if let assetDbPath = Bundle.main.path(forResource: "ev_infra", ofType: "db") {
                try FileManager.default.copyItem(atPath: assetDbPath, toPath: self.dbPath)
            } else {
                print("ev_infra db is not in the app bundle")
            }
        } catch {
            print("Unable to copy db: \(error)")
        }
    }
    
    // asset db version과 현재 db version을 비교 후 update
    func updateDB() {
        if let assetDbPath = Bundle.main.path(forResource: "ev_infra", ofType: "db") {
            let query = "SELECT version_id FROM db_version"
            self.executeQuery(path: assetDbPath, query: query) { result in
                while result.next() {
                    let assetVersion = result.int(forColumn: "version_id")
                    if assetVersion != getDbVersion() {
                        print("update db - asset version: \(assetVersion), cur version: \(getDbVersion())")
                        do {
                            FMDatabase(path: dbPath).close()
                            
                            // update date를 초기화시켜 서버에서 새로 db내용 받아오게 함
                            UserDefault().saveString(key: UserDefault.Key.COMPANY_ICON_UPDATE_DATE, value: "")
                            try FileManager.default.removeItem(atPath: self.dbPath)
                            copyDB()
                        } catch {
                            print("fail remove item")
                        }
                        break
                    }
                }
            }
        }
    }
    
    func insertOrReplace(json: JSON) {
        var query  = " INSERT OR REPLACE INTO company_info ("
            query += "    company_id, name, tel, icon_name, icon_date,"
            query += "    homepage, ios_appstore, is_visible, sort, del"
            query += " ) VALUES ("
            query += "    '\(json["id"].stringValue)',"
            query += "    '\(json["name"].stringValue)',"
            query += "    '\(json["tel"].stringValue)',"
            query += "    '\(json["ic_name"].stringValue)',"
            query += "    '\(json["ic_date"].stringValue)',"
            query += "    '\(json["hp"].stringValue)',"
            query += "    '\(json["as"].stringValue)',"
            query += "    1,"
            query += "    '\(json["sort"].stringValue)',"
            query += "    '\(json["del"].intValue)'"
            query += " );"
        
        self.executeUpdate(query: query)
    }

    func updateCompanyVisibility(companyId: String, isVisible: Bool) {
        var query  = " UPDATE company_info SET"
            query += " is_visible = \(isVisible ? 1: 0)"
            query += " WHERE company_id = '\(companyId)';"

        self.executeUpdate(query: query)
    }
    
    func getCompanyInfoList() -> Array<CompanyInfo> {
        var arrayCompany = Array<CompanyInfo>()
        let query = "SELECT * FROM company_info WHERE del = 0 ORDER BY sort ASC;"
        
        self.executeQuery(path: dbPath, query: query) { result in
            while result.next() {
                let company = CompanyInfo.init()
                company.id = result.string(forColumn: "company_id")
                company.name = result.string(forColumn: "name")
                company.iconName = result.string(forColumn: "icon_name")
                company.homepage = result.string(forColumn: "homepage")
                company.appstore = result.string(forColumn: "ios_appstore")
                company.isVisible = (result.int(forColumn: "is_visible") == 1)

                arrayCompany.append(company)
            }
        }

        return arrayCompany
    }
    
    // drop down filter에서 사용.
    // index 0: 기관선택
    func getCompanyNameList() -> Array<String> {
        var arrayCompanyName = Array<String>()
        arrayCompanyName.append("전체선택")
        
        let query = "SELECT name FROM company_info WHERE del = 0 ORDER BY sort ASC;"
        self.executeQuery(path: dbPath, query: query) { result in
            while result.next() {
                arrayCompanyName.append(result.string(forColumn: "name")!)
            }
        }

        return arrayCompanyName
    }
    
    func getCompanyVisibilityList() -> Array<Bool> {
        var arrayCompanyVisibility = Array<Bool>()
        arrayCompanyVisibility.append(true)
        
        let query = "SELECT is_visible FROM company_info WHERE del = 0 ORDER BY sort ASC;"
        self.executeQuery(path: dbPath, query: query) { result in
            while result.next() {
                if result.int(forColumn: "is_visible") == 1 {
                    arrayCompanyVisibility.append(true)
                } else {
                    arrayCompanyVisibility.append(false)
                    arrayCompanyVisibility[0] = false
                }
            }
        }

        return arrayCompanyVisibility
    }
    
    func getCompanyInfo(companyId: String) -> CompanyInfo? {
        let company = CompanyInfo.init()
        let query : String = "SELECT * FROM company_info  WHERE company_id = '\(companyId)';"
        self.executeQuery(path: dbPath, query: query) { result in
            while result.next() {
                company.id = result.string(forColumn: "company_id")
                company.name = result.string(forColumn: "name")
                company.iconName = result.string(forColumn: "icon_name")
                company.homepage = result.string(forColumn: "homepage")
                company.appstore = result.string(forColumn: "ios_appstore")
                company.isVisible = (result.int(forColumn: "is_visible") == 1)
            }
        }
        return company
    }
   
    func getCompanyName(companyId: String) -> String? {
        var name: String?
        let query = "SELECT name FROM company_info  WHERE company_id = '\(companyId)';"
        self.executeQuery(path: dbPath, query: query) { result in
            while result.next() {
                name = result.string(forColumn: "name")
            }
        }
        return name
    }
    
    func getCompanyId(name: String) -> String? {
        var company_id: String?
        let query : String = "SELECT company_id FROM company_info  WHERE name = '\(name)';"
        self.executeQuery(path: dbPath, query: query) { result in
            while result.next() {
                company_id = result.string(forColumn: "company_id")
            }
        }
        return company_id
    }
    
    private func getDbVersion() -> Int32 {
        var version: Int32 = 1
        let query = "SELECT version_id FROM db_version"
        self.executeQuery(path: dbPath, query: query) { result in
            while result.next() {
                version = result.int(forColumn: "version_id")
            }
        }
        return version
    }
    
    private func createTable(tableName: String, coulmnDefine: String) {
        let query = "CREATE TABLE IF NOT EXISTS \(tableName) (\(coulmnDefine))"
        let database : FMDatabase? = FMDatabase(path: dbPath)
        if let db = database {
            if db.open() {
                db.executeStatements(query)
            }
            db.close()
        } else {
            NSLog("EVInfra Database ACCESS FAIL")
        }
    }
    
    private func executeQuery(path: String, query: String, completion: (FMResultSet)->()) {
        let database : FMDatabase? = FMDatabase(path: path)
        if let db = database {
            if db.open() {
                let fmResult = db.executeQuery(query, withArgumentsIn: [])
                if let result = fmResult {
                    completion(result)
                } else {
                    NSLog("db query fialed. \(db.lastErrorMessage())")
                }
            }
            db.close()
        }
    }
    
    private func executeUpdate(query: String) {
        let database : FMDatabase? = FMDatabase(path: dbPath)
        if let db = database {
            if db.open() {
                let fmResult = db.executeUpdate(query, withArgumentsIn: [])
                if !fmResult {
                    NSLog("EVInfra Database insert Company Image query fialed. Error \(db.lastErrorMessage())")
                }
            }
            db.close()
        } else {
            NSLog("EV Infra Database ACCESS FAIL")
        }
    }
    
    private func addColumnToTable(nColumn: String, nTable: String, nType: String, nDefaultVal: String?) {
        var query: String = ""
        let database : FMDatabase? = FMDatabase(path: dbPath)
        if let db = database {
            if db.open() {
                if !db.columnExists(nColumn, inTableWithName: nTable) {
                    if let defaultVal = nDefaultVal {
                        query = "ALTER TABLE \(nTable) ADD \(nColumn) \(nType) DEFAULT \(defaultVal) NOT NULL;"
                    } else {
                        query = "ALTER TABLE \(nTable) ADD \(nColumn) \(nType);"
                    }
                    
                    let fmResult = db.executeQuery(query, withArgumentsIn: [])
                    if fmResult == nil {
                        NSLog("EVInfra ALTER TABLE \(nTable) query fialed. Error \(db.lastErrorMessage())")
                    }
                }
            }
            db.close()
        }
    }
}

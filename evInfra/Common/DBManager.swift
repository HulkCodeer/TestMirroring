//
//  DBManager.swift
//  evInfra
//
//  Created by bulacode on 2018. 7. 5..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import FMDB

class DBManager {
    static let sharedInstance = DBManager()
    var dbPath : String = ""
    let dbName : String = "ev_infra.db"
    // CompanyInfo Query Strings
    
    private init() {
        
    }
    
    func openDB() {
        dbPath = copyDBIfNeed()
        addColumnToTable(nColumn: "isVisible", nTable: "company_info", nType: "INTEGER", nDefaultVal: "1")
    }
    
    //db 파일 복사
    func copyDBIfNeed()-> String {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let dbUrl = documentsURL.appendingPathComponent(dbName)
            do {
                if !fileManager.fileExists(atPath: dbUrl.path) {
                    print("db does not exist in document folder")
                    
                    if let assetDbPath = Bundle.main.path(forResource: "ev_infra", ofType: "db") {
                        try fileManager.copyItem(atPath: assetDbPath, toPath: dbUrl.path)
                    } else {
                        print("ev_infra db is not in the app bundle")
                    }
                } else {
                    print("db file found path \(dbUrl.path)")
                }
            } catch {
                print("Unable to copy db : \(error)")
            }
            return dbUrl.path
        } else {
            return ""
        }
    }
    
    func createTable(tableName: String, coulmnDefine: String) {
        let query: String = "CREATE TABLE IF NOT EXISTS \(tableName) (\(coulmnDefine))"
        let database : FMDatabase? = FMDatabase(path: dbPath)
        if let db = database {
            if db.open() {
                let fmResult = db.executeStatements(query)
                if fmResult {
//                    print("Success DB Create Query : \(query)")
                } else {
//                    NSLog("Failed Create Table Query \(tableName) : \(db.lastErrorMessage())")
                }
            }
            db.close()
        } else {
            NSLog("EVInfra Database ACCESS FAIL")
        }
    }
    
    func insertCompanyInfo(company_id: String, name: String, icon_name: String, hompage: String, ios_appstore: String) {
        let query : String = "INSERT INTO company_info (company_id, name, icon_name, homepage, ios_appstore, isVisible) VALUES ('\(company_id)', '\(name)', '\(icon_name)', '\(hompage)', '\(ios_appstore)', 1);"
        let database : FMDatabase? = FMDatabase(path: dbPath)
        if let db = database {
            if db.open() {
                let fmResult = db.executeUpdate(query, withArgumentsIn: [])
                if fmResult {
//                    print("Success DB INSERT Query : \(query)")
                } else {
//                    NSLog("EVInfra Database insert Company Image query fialed. Errror \(db.lastErrorMessage())")
                }
            }
            db.close()
        } else {
            NSLog("EVInfra Database ACCESS FAIL")
        }
    }
    
    func updateCompanyImage(companyId: String, imageName: String) {
        let query : String = "UPDATE company_info SET icon_name = '\(imageName)' WHERE company_id = '\(companyId)';"
        let database : FMDatabase? = FMDatabase(path: dbPath)
        if let db = database {
            if db.open() {
                let fmResult = db.executeUpdate(query, withArgumentsIn: [])
                if fmResult {
//                    print("Success DB UPDATE Query : \(query)")
                } else {
//                    NSLog("EVInfra Database update Company Image query fialed. Errror \(db.lastErrorMessage())")
                }
            }
            db.close()
        } else {
            NSLog("EVInfra Database ACCESS FAIL")
        }
    }

    func updateCompanyHomepage(companyId: String, homepage: String) {
        let query : String = "UPDATE company_info SET homepage = '\(homepage)' WHERE company_id = '\(companyId)';"
        let database : FMDatabase? = FMDatabase(path: dbPath)
        if let db = database {
            if db.open() {
                let fmResult = db.executeUpdate(query, withArgumentsIn: [])
                if fmResult {
//                    print("Success DB UPDATE Query : \(query)")
                } else {
//                    NSLog("EVInfra Database update Company Image query fialed. Errror \(db.lastErrorMessage())")
                }
            }
            db.close()
        } else {
            NSLog("EVInfra Database ACCESS FAIL")
        }
    }
    
    func updateCompanyAppstore(companyId: String, appStore: String) {
        let query : String = "UPDATE company_info SET ios_appstore = '\(appStore)' WHERE company_id = '\(companyId)';"
        let database : FMDatabase? = FMDatabase(path: dbPath)
        if let db = database {
            if db.open() {
                let fmResult = db.executeUpdate(query, withArgumentsIn: [])
                if fmResult {
//                    print("Success DB UPDATE Query : \(query)")
                } else {
//                    NSLog("EVInfra Database update Company Image query fialed. Errror \(db.lastErrorMessage())")
                }
            }
            db.close()
        } else {
            NSLog("EVInfra Database ACCESS FAIL")
        }
    }
    
    func updateCompanyVisibility(companyId: String, isVisible: Bool) {
        var query: String = ""
        if isVisible {
            query = "UPDATE company_info SET isVisible = 1 WHERE company_id = '\(companyId)';"
        } else {
            query = "UPDATE company_info SET isVisible = 0 WHERE company_id = '\(companyId)';"
        }
        let database : FMDatabase? = FMDatabase(path: dbPath)
        if let db = database {
            if db.open() {
                let fmResult = db.executeUpdate(query, withArgumentsIn: [])
                if fmResult {
//                    print("Success DB UPDATE Query : \(query)")
                } else {
                    NSLog("EVInfra Database update Company visibility query fialed. Errror \(db.lastErrorMessage())")
                }
            }
            db.close()
        } else {
            NSLog("EVInfra Database ACCESS FAIL")
        }
    }
    
    func getCompanyInfoList() -> Array<CompanyInfo> {
        var arrayCompany = Array<CompanyInfo>()
        let query : String = "SELECT * FROM company_info;"
        let database : FMDatabase? = FMDatabase(path: dbPath)
        if let db = database {
            if db.open() {
                let fmResult: FMResultSet? = db.executeQuery(query, withArgumentsIn: [])
                if let result = fmResult {
                    while result.next() {
                        let company: CompanyInfo = CompanyInfo.init(id: result.string(forColumn: "company_id"), cname: result.string(forColumn: "name"), icon: result.string(forColumn: "icon_name"), page: result.string(forColumn: "homepage"), store: result.string(forColumn: "ios_appstore"), isVisible: result.int(forColumn: "isVisible"))
                        arrayCompany.append(company)
                    }
                } else {
                    NSLog("EVInfra Database update Company Image query fialed. Errror \(db.lastErrorMessage())")
                }
            }
            db.close()
        }
        
        return arrayCompany
    }
    
    // drop down filter에서 사용.
    // index 0: 기관선택
    func getCompanyNameList() -> Array<String> {
        var arrayCompanyName = Array<String>()
        arrayCompanyName.append("전체선택")
        
        let query : String = "SELECT name FROM company_info;"
        let database : FMDatabase? = FMDatabase(path: dbPath)
        if let db = database {
            if db.open() {
                let fmResult: FMResultSet? = db.executeQuery(query, withArgumentsIn: [])
                if let result = fmResult {
                    while result.next() {
                        arrayCompanyName.append(result.string(forColumn: "name")!)
                    }
                } else {
                    NSLog("EVInfra Database get Company NameList query fialed. Errror \(db.lastErrorMessage())")
                }
            }
            db.close()
        }
        return arrayCompanyName
    }
    
    func getCompanyVisibilityList() -> Array<Bool> {
        var arrayCompanyVisibility = Array<Bool>()
        arrayCompanyVisibility.append(true)
        
        let query : String = "SELECT isVisible FROM company_info;"
        let database : FMDatabase? = FMDatabase(path: dbPath)
        if let db = database {
            if db.open() {
                let fmResult: FMResultSet? = db.executeQuery(query, withArgumentsIn: [])
                if let result = fmResult {
                    while result.next() {
                        if result.int(forColumn: "isVisible") == 1 {
                            arrayCompanyVisibility.append(true)
                        } else {
                            arrayCompanyVisibility.append(false)
                            arrayCompanyVisibility[0] = false
                        }
                    }
                } else {
                    NSLog("EVInfra Database get Company visibility query fialed. Errror \(db.lastErrorMessage())")
                }
            }
            db.close()
        }
        return arrayCompanyVisibility
    }
    
    func getCompanyInfo(companyId: String) -> CompanyInfo? {
        var company: CompanyInfo?
        let query : String = "SELECT * FROM company_info  WHERE company_id = '\(companyId)';"
        let database : FMDatabase? = FMDatabase(path: dbPath)
        if let db = database {
            if db.open() {
                let fmResult: FMResultSet? = db.executeQuery(query, withArgumentsIn: [])
                if let result = fmResult {
                    while result.next() {
                        company = CompanyInfo.init(id: result.string(forColumn: "company_id"), cname: result.string(forColumn: "name"), icon: result.string(forColumn: "icon_name"), page: result.string(forColumn: "homepage"), store: result.string(forColumn: "ios_appstore"), isVisible: result.int(forColumn: "isVisible"))
//                        print("company icon : \(result.string(forColumn: "icon_name"))")
                    }
                } else {
                    NSLog("EVInfra Database update Company Image query fialed. Errror \(db.lastErrorMessage())")
                }
            }
            db.close()
        }
        
        return company
    }
   
    func getCompanyName(companyId: String) -> String? {
        var name: String?
        let query : String = "SELECT name FROM company_info  WHERE company_id = '\(companyId)';"
        let database : FMDatabase? = FMDatabase(path: dbPath)
        if let db = database {
            if db.open() {
                let fmResult: FMResultSet? = db.executeQuery(query, withArgumentsIn: [])
                if let result = fmResult {
                    while result.next() {
                        name = result.string(forColumn: "name")
                    }
                } else {
                    NSLog("EVInfra Database update Company Image query fialed. Errror \(db.lastErrorMessage())")
                }
            }
            db.close()
        }
        
        return name
    }
    
    func getCompanyId(name: String) -> String? {
        var company_id: String?
        let query : String = "SELECT company_id FROM company_info  WHERE name = '\(name)';"
        let database : FMDatabase? = FMDatabase(path: dbPath)
        if let db = database {
            if db.open() {
                let fmResult: FMResultSet? = db.executeQuery(query, withArgumentsIn: [])
                if let result = fmResult {
                    while result.next() {
                        company_id = result.string(forColumn: "company_id")
                    }
                } else {
                    NSLog("EVInfra Database update Company Image query fialed. Errror \(db.lastErrorMessage())")
                }
            }
            db.close()
        }
        
        return company_id
    }

    
    func addColumnToTable(nColumn: String, nTable: String, nType: String, nDefaultVal: String?){
        var query: String = ""
        let database : FMDatabase? = FMDatabase(path: dbPath)
        if let db = database {
            if db.open() {
                if(!db.columnExists(nColumn, inTableWithName: nTable)) {
                    if let defaultVal = nDefaultVal{
                        query = "ALTER TABLE \(nTable) ADD \(nColumn) \(nType) DEFAULT \(defaultVal) NOT NULL;"
                    }else{
                        query = "ALTER TABLE \(nTable) ADD \(nColumn) \(nType);"
                    }
                    let fmResult: FMResultSet? = db.executeQuery(query, withArgumentsIn: [])
                    if let result = fmResult {
                        while result.next() {
                            
                        }
                    } else {
                        NSLog("EVInfra ALTER TABLE \(nTable) query fialed. Errror \(db.lastErrorMessage())")
                    }
                }
            }
            db.close()
        }
    }
}

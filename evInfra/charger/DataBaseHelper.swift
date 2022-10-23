//
//  DataBaseHelper.swift
//  evInfra
//
//  Created by Michael Lee on 2020/06/04.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
import GRDB

class DataBaseHelper {
    static let sharedInstance = DataBaseHelper()
    public static let DEV_DATABASE_NAME = "eidev"
    public static let REL_DATABASE_NAME = "eirel"
    public static var DATABASE_NAME = REL_DATABASE_NAME
    private static let DATABASE_VERSION = 4
    
    private var mDbQueue : DatabaseQueue?
    
    public init(){
    // Do any additional setup after loading the view, typically from a nib.
        do{
            if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let dbPath = documentsURL.appendingPathComponent(DataBaseHelper.DATABASE_NAME).path
                var configuration = Configuration()
                configuration.readonly = false
                //configuration.trace = nil //{ Log.d(tag: DataBaseHelper.TAG, msg: $0) }
                mDbQueue = try DatabaseQueue(path: dbPath, configuration: configuration)
            }
        }catch{
            printLog(out: "Error info: \(error.localizedDescription)")
        }
    }
    
    func getDbQue() -> DatabaseQueue? {
        return mDbQueue
    }
    
    static func existDB() -> Bool {
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dbPath = documentsURL.appendingPathComponent(DATABASE_NAME).path
            if (!FileManager.default.fileExists(atPath: dbPath)) {
                return false
            }
        }
        return true
    }

    static func isNeedImport() -> Bool {
        var isUpdate = false
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        // dev server
        if (DATABASE_NAME.equalsIgnoreCase(compare: DEV_DATABASE_NAME)){
            isUpdate = true
        }else{
            // rel server
            let updateDate = UserDefault().readString(key: UserDefault.Key.KEY_APP_VERSION)
            if let version = version{
                print("version: \(version)")
                if (version != updateDate){
                    isUpdate = true
                }
            }
        }
        return isUpdate
    }
    
    static func importDatabase() -> Bool {
        do {
            if let assetDbPath = Bundle.main.path(forResource: DataBaseHelper.DATABASE_NAME, ofType: "") {
                if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let dbPath = documentsURL.appendingPathComponent(DATABASE_NAME).path
                    // for replace
                    if (FileManager.default.fileExists(atPath: dbPath)){
                        try FileManager.default.removeItem(atPath: dbPath)
                    }
                    
                    try FileManager.default.copyItem(atPath: assetDbPath, toPath: dbPath)
                    
                    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                    UserDefault().saveString(key: UserDefault.Key.KEY_APP_VERSION, value: version!)
                    return true
                }
            } else {
                print("Unable no")
            }
        } catch {
            print("Unable ex: \(error)")
        }
        return false
    }
    
    static func exportDatabase() -> Bool {
        return false
    }

    // charger company
    func getCompanyInfoList() throws -> [CompanyInfoDto]? {
        let companyinfoDtoList = try mDbQueue!.inDatabase { db in
            try CompanyInfoDto.filter(Column("del") == 0).order(Column("sort").asc).fetchAll(db)
        }
        return companyinfoDtoList
    }
    
    func getCompanyInfo(company_id : String) throws -> CompanyInfoDto? {
        let companyInfoDto = try mDbQueue!.inDatabase { db in
            try CompanyInfoDto.filter(Column("company_id").like(company_id)).fetchOne(db)
        }
        return companyInfoDto
    }
    
    func getCompanyInfo(company_name : String) throws -> CompanyInfoDto? {
        let companyInfoDto = try mDbQueue!.inDatabase { db in
            try CompanyInfoDto.filter(Column("name").like(company_name)).fetchOne(db)
        }
        return companyInfoDto
    }

    func insertOrUpdateCompanyInfo(companyInfo : CompanyInfoDto) throws{
        try mDbQueue!.write { db in
            try companyInfo.save(db)
        }
    }

    func insertOrUpdateCompanyInfoList(list : [CompanyInfoDto]) throws{
        try mDbQueue!.write  { db in
            for companyInfoDto in list{
                let companyID = companyInfoDto.company_id
                let prevDto = try CompanyInfoDto.filter(Column("company_id").like(companyID!)).fetchOne(db)
                if ((prevDto) != nil){
                    companyInfoDto.is_visible = prevDto!.is_visible
                }
                try companyInfoDto.save(db)
            }
        }
    }

    func updateCompanyInfo(companyInfo : CompanyInfoDto) throws{
        try mDbQueue!.write { db in
            try companyInfo.update(db)
        }
    }

    // last station info update date
    func insertOrUpdateInfoLastUpdate(info_type : String,  lastUpdate : String) throws{
        if (StringUtils.isNullOrEmpty(lastUpdate)) {
            return
        }

        let dto = InfoLastUpdateDto()
        dto.mInfoLastUpdateDate = lastUpdate
        dto.mInfoType = info_type

        try mDbQueue!.write { db in
            try dto.save(db)
        }
    }

    func getCompanyInfoLastUpdate() throws ->InfoLastUpdateDto?{
        let lastUpdate = try mDbQueue!.inDatabase { db in
            try InfoLastUpdateDto.filter(Column("mInfoType").like(ChargerConst.INFO_TYPE_COMPANY)).order(Column("mId").desc).fetchOne(db)
        }
        return lastUpdate
    }

    func getStationInfoLastUpdate() throws -> InfoLastUpdateDto? {
        let lastUpdate = try mDbQueue!.inDatabase { db in
            try InfoLastUpdateDto.filter(Column("mInfoType").like(ChargerConst.INFO_TYPE_STATION)).order(Column("mId").desc).fetchOne(db)
        }
        return lastUpdate
    }

    // station info

    func insertOrUpdateStationInfo(stationInfo : StationInfoDto) throws{
        try mDbQueue!.write { db in
            try stationInfo.save(db)
        }
    }

    func insertOrUpdateStationInfoList(list : [StationInfoDto]) throws {
        try mDbQueue!.write  { db in
            for stationInfoDto in list{
                if (!StringUtils.isNullOrEmpty(stationInfoDto.mSnm)) {
                    let snm = stationInfoDto.mSnm?.replaceAll(of: "\\s+", with: "").lowercased()
                    stationInfoDto.mSnmSearchWord = HangulUtils.getChosung(snm!)
                }
                if (!StringUtils.isNullOrEmpty(stationInfoDto.mAddress)) {
                    let address = stationInfoDto.mAddress?.replaceAll(of: "\\s+", with: "").lowercased()
                    stationInfoDto.mAddressSearchWord = HangulUtils.getChosung(address!)
                }
                if (!StringUtils.isNullOrEmpty(stationInfoDto.mAddressDetail)) {
                    let addressDetail = stationInfoDto.mAddressDetail?.replaceAll(of: "\\s+", with: "").lowercased()
                    stationInfoDto.mAddressDetailSearchWord = HangulUtils.getChosung(addressDetail!)
                }
                try stationInfoDto.save(db)
            }
        }
    }

    func updateStationInfo(stationInfo : StationInfoDto) throws{
        try mDbQueue!.write { db in
            try stationInfo.update(db)
        }
    }

    func getStationInfoList() throws -> [StationInfoDto]?{
        let stationinfoDtoList = try mDbQueue!.inDatabase { db in
            try StationInfoDto.filter(Column("mDel") == 0).order(Column("mChargerId").asc).fetchAll(db)
        }
        return stationinfoDtoList
    }

    func getStationInfoById(id : String) throws -> StationInfoDto?{
        let stationInfoDto = try mDbQueue!.inDatabase { db in
            try StationInfoDto.filter(Column("mDel") == 0 && Column("mChargerId").like(id)).fetchOne(db)
        }
        return stationInfoDto
    }
}

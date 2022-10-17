//
//  ChargerManager.swift
//  evInfra
//
//  Created by Michael Lee on 2020/06/02.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxCocoa


protocol MarkerTouchDelegate: AnyObject {
    func touchHandler(with charger: ChargerStationInfo)
}

class ChargerManager {
    
    static let sharedInstance = ChargerManager()
    
    private var mDb: DataBaseHelper? = nil
    private var mIsReady: Bool = false
    private var mChargerStationInfoList = [ChargerStationInfo]()
    internal weak var delegate: MarkerTouchDelegate?
    
    public init() {
        if Const.EV_PAY_SERVER.contains("https") == false {
            DataBaseHelper.DATABASE_NAME = DataBaseHelper.DEV_DATABASE_NAME
        }
    
        if !DataBaseHelper.existDB() { // create DB
            if DataBaseHelper.importDatabase() {
                printLog(out: "im success")
            } else {
                printLog(out: "im fail")
            }
            mDb = DataBaseHelper.sharedInstance
        } else if DataBaseHelper.isNeedImport() { // exist & version update DB
            let db = DataBaseHelper()
            var backUpCompanyList = [CompanyInfoDto]()
            backUpCompanyList = try! db.getCompanyInfoList()!
            if DataBaseHelper.importDatabase() {
                printLog(out: "im success")
                mDb = DataBaseHelper.sharedInstance // recreate db instance
                for company in backUpCompanyList {
                    if let compId = company.company_id {
                        if let companyInfo = try! mDb!.getCompanyInfo(company_id: compId) {
                            companyInfo.is_visible = company.is_visible
                            try! mDb?.updateCompanyInfo(companyInfo: companyInfo)
                        }
                    }
                }
            } else {
                mDb = DataBaseHelper.sharedInstance
                printLog(out: "im fail")
            }
        } else { // not import DB
            mDb = DataBaseHelper.sharedInstance
        }
    }
    
    public func isReady() -> Bool {
        return mIsReady
    }

    // charger company
    public func getCompanyInfoListAll() -> [CompanyInfoDto]? {
        return try! mDb?.getCompanyInfoList()
    }
    
    public func getCompanyNameList() -> [String] {
        var companyNameList = [String]()
        companyNameList.append("전체선택")

        for company in getCompanyInfoListAll()! {
            if StringUtils.isNullOrEmpty(company.name!) == false {
                companyNameList.append(company.name!)
            }
        }

        return companyNameList
    }

    public func getCompanyHomePageUrl(companyID : String) -> String? {
        if let companyInfo = try! mDb!.getCompanyInfo(company_id: companyID) {
            return companyInfo.homepage
        }
        return nil
    }

    public func getCompanyMarketUrl(companyID : String) -> String? {
        if let companyInfo = try! mDb!.getCompanyInfo(company_id: companyID) {
            return companyInfo.market
        }
        return nil
    }

    public func getCompanyName(companyID : String) -> String? {
        if let companyInfo = try! mDb!.getCompanyInfo(company_id: companyID) {
            return companyInfo.name
        }
        return nil
    }
    
    public func getCompanyId(companyName : String) -> String? {
        if let companyInfo = try! mDb!.getCompanyInfo(company_name: companyName) {
            return companyInfo.company_id
        }
        return nil
    }
    
    public func getCompanyVisibilityList() -> [Bool] {
        var companyVisibleList = [Bool]()
        companyVisibleList.append(true)

        for company in getCompanyInfoListAll()! {
            if company.is_visible {
                companyVisibleList.append(true)
            } else {
                companyVisibleList.append(false)
                companyVisibleList[0] = false
            }
        }
        
        return companyVisibleList
    }

    internal func updateCompanyInfoListFromServer(json : JSON) {
        let code = json["code"]
        let list = json["list"]
        let last = json["last"]

        if (code == 1000 && list.array!.count > 0) {
            var companyList = [CompanyInfoDto]()
            
            for company in list.arrayValue {
                let companyInfo = CompanyInfoDto()
                companyInfo.setCompanyInfo(json: company)
                companyList.append(companyInfo)
            }
            
            try! mDb?.insertOrUpdateCompanyInfoList(list: companyList)
            try! mDb?.insertOrUpdateInfoLastUpdate(info_type: ChargerConst.INFO_TYPE_COMPANY, lastUpdate: last.stringValue)
        }
    }

    public func updateCompanyVisibility(isVisible : Bool, companyID : String) {
        if let companyInfo = try! mDb?.getCompanyInfo(company_id: companyID)! {
            if companyInfo.is_visible != isVisible {
                companyInfo.is_visible = isVisible
                try! mDb?.updateCompanyInfo(companyInfo: companyInfo)
            }
        }
    }

    // station info
    private func updateStationInfoListFromServer(json : JSON) {
        let code = json["code"]
        let list = json["list"]
        let last = json["last"]
        
        if (code == 1000 && list.array!.count > 0) {
            printLog(out: "start station info list insert or update")
            
            var stationList = [StationInfoDto]()
            for station in list.arrayValue{
                let stationInfo = StationInfoDto()
                stationInfo.setStationInfo(json: station)
                stationList.append(stationInfo)
            }
            
            try! self.mDb?.insertOrUpdateStationInfoList(list: stationList)
            try! self.mDb?.insertOrUpdateInfoLastUpdate(info_type: ChargerConst.INFO_TYPE_STATION,lastUpdate: last.stringValue)
            printLog(out: "end station info list insert or update")
        }
    }

    public func updateStationInfo(stationInfo : StationInfoDto) {
        try! mDb?.updateStationInfo(stationInfo: stationInfo)
    }

    public func getStationInfoListAll() -> [StationInfoDto]? {
        return try! mDb?.getStationInfoList()
    }

    public func getStationInfoById(id : String) -> StationInfoDto? {
        return try! mDb?.getStationInfoById(id: id)
    }

    private func createAllMarker() {
        for chargerStationInfo in self.mChargerStationInfoList {
            chargerStationInfo.createMapMarker()
            chargerStationInfo.mapMarker.touchHandler = { [weak self] overlay -> Bool in
                self?.delegate?.touchHandler(with: chargerStationInfo)
                return true
            }
        }
        printLog(out: "marker create")
    }

    // charger station info
    private func setChargerStationInfoList() {
        mChargerStationInfoList.removeAll()

        let stationInfoDtoList = getStationInfoListAll()
        for stationInfoDto in stationInfoDtoList! {
            mChargerStationInfoList.append(ChargerStationInfo(stationInfoDto))
        }
    }
    
    public func setStationList(with filter: ChargerFilter) {
        self.mChargerStationInfoList = self.mChargerStationInfoList.filter({
            $0.check(filter: filter)
        })
    }
    
    public func getChargerStationInfoList() -> [ChargerStationInfo] {
        return self.mChargerStationInfoList
    }
    
    public func getFilteredStationList(filter: ChargerFilter) -> [ChargerStationInfo] {
        return mChargerStationInfoList.filter {
            $0.check(filter: filter)
        }
    }
    
    func binarySearch(_ inputArr:Array<ChargerStationInfo>, _ searchItem: ChargerStationInfo) -> Int? {
        
        guard let chargerId = searchItem.mChargerId else {
            return nil
        }
        
        guard !inputArr.isEmpty else {
            return nil
        }

        let t2 = chargerId
        var lowerIndex = 0
        var upperIndex = inputArr.count - 1
        
        while (true) {
            let currentIndex = (lowerIndex + upperIndex)/2
            let t1 = inputArr[currentIndex].mChargerId!
            if (t1 == t2) {
                return currentIndex
            } else if (lowerIndex > upperIndex) {
                return nil
            } else {
                if (t1 > t2) {
                    upperIndex = currentIndex - 1
                } else {
                    lowerIndex = currentIndex + 1
                }
            }
        }
    }
    
    public func getChargerStationInfoById(charger_id : String) -> ChargerStationInfo? {
        let chargerStationInfo = ChargerStationInfo(charger_id)
        if let searchIndex = binarySearch(mChargerStationInfoList, chargerStationInfo) {
            if (searchIndex >= 0 && searchIndex < mChargerStationInfoList.count) {
                return mChargerStationInfoList[searchIndex]
            } else {                
                printLog(out: "charger list size: \(mChargerStationInfoList.count), charger_id: \(charger_id), index: \(searchIndex)")
            }
        }
        return nil
    }

    // from server or from db
    public func getChargerCompanyInfo() -> String {
        var updateDate = ""
        if (try! (mDb?.getCompanyInfoList()!.count)! > 0) {
            if let dto = try! mDb?.getCompanyInfoLastUpdate() {
                updateDate = (dto.mInfoLastUpdateDate)!
            }
        }
        return updateDate        
    }
 
    // naver map
    public func getStations(completion: @escaping () -> Void) {
        var updateDate = ""
        if let dto = try! mDb?.getStationInfoLastUpdate() {
            updateDate = (dto.mInfoLastUpdateDate)!
        }
        
        Server.getStationInfo(updateDate: updateDate) { [weak self] (isSuccess, value) in
            if isSuccess {
                guard let self = self else { return }
                guard let value = value else { return }

                DispatchQueue.global(qos: .userInitiated).async {
                    self.updateStationInfoListFromServer(json: JSON(value))
                    self.setChargerStationInfoList()
                    self.getStationStatus {
                        completion()
                    }
                }
            }
        }
    }
    
    private func getStationStatus(completion: @escaping () -> Void) {
        Server.getStationStatus { [weak self] (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let code = json["code"]
                let list = json["list"]

                if (code == 1000 && list.count > 0) {
                
                    for status in list.arrayValue {
                        let chargerId = status["id"].stringValue
                        let cst = status["st"].intValue
                        var power = status["p"].intValue
                        let type_id = status["tp"].intValue
                        let limit = status["lm"].stringValue
                        
                        if let chargerStationInfo = self?.getChargerStationInfoById(charger_id: chargerId) {
                            if type_id != Const.CTYPE_SLOW && type_id != Const.CTYPE_DESTINATION && power < 50 {
                                power = 50
                            }
                            chargerStationInfo.mTotalStatus = cst
                            chargerStationInfo.mTotalType = type_id
                            chargerStationInfo.mPower = power
                            chargerStationInfo.mLimit = limit
                        }
                    }

                    self?.createAllMarker()
                    self?.mIsReady = true
                    completion()
                }
            }
        }
    }

//    public func getFavoriteList(listener : ChargerManagerListener?) {
//        
//        Server.getFavoriteList { (isSuccess, value) in
//            if isSuccess {
//                let json = JSON(value)
//                let code = json["code"]
//                let list = json["list"]
//                
//                if (code == 1000 && list.count > 0) {
//                
//                    for favorite in list.arrayValue {
//                        let chargerId = favorite["id"].stringValue
//                        let noti = favorite["noti"].boolValue
//                        
//                        if let chargerStationInfo = self.getChargerStationInfoById(charger_id: chargerId) {
//                            chargerStationInfo.mFavorite = true
//                            chargerStationInfo.mFavoriteNoti = noti
//                        }
//                    }
//                    
//                    if let chargerManagerListener = listener {
//                        chargerManagerListener.onComplete()
//                    }
//                }
//            }
//        }
//    }
    
    func getFavoriteCharger() {
        if MemberManager.shared.mbId > 0 {
            Server.getFavoriteList { (isSuccess, value) in
                if isSuccess {
                    let json = JSON(value)
                    if json["code"].intValue == 1000 {
                        for (_, item):(String, JSON) in json["list"] {
                            let id = item["id"].stringValue
                            if let charger = self.getChargerStationInfoById(charger_id: id){
                                charger.mFavorite = true
                                charger.mFavoriteNoti = item["noti"].boolValue
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setFavoriteCharger(charger: ChargerStationInfo, completion: ((ChargerStationInfo) -> Void)?) {
        if MemberManager.shared.mbId > 0 {
            Server.setFavorite(chargerId: charger.mChargerId!, mode: !charger.mFavorite) { (isSuccess, value) in
                if isSuccess {
                    let json = JSON(value)
                    if json["code"].intValue == 1000 {
                        charger.mFavorite = json["mode"].boolValue
                        charger.mFavoriteNoti = true
                        
                        completion?(charger)
                    }
                }
            }
        }
    }
    
    // sk open api
    public func findAllPOI(keyword: String, completion: @escaping ([EIPOIItem]?) -> Void) {
        if StringUtils.isNullOrEmpty(keyword) {
            completion([])
        }
        
        let currentPosition = CLLocationManager().getCurrentCoordinate()
        let latitude = currentPosition.latitude
        let longitude = currentPosition.longitude
        
        Server.getPoiItemList(count: 100, radius: 0, centerLat: latitude, centerLon: longitude, keyword: keyword) { (isSuccess, result) in
            if  isSuccess {
                let json = JSON(result)
                let searchPoiInfo = json["searchPoiInfo"]
                _ = searchPoiInfo["totalCount"].intValue
                _ = searchPoiInfo["count"].intValue
                _ = searchPoiInfo["page"].intValue
                let pois = searchPoiInfo["pois"]
                let poi = pois["poi"]
                let poiList = [EIPOIItem].deserialize(from: poi.rawString())
                
                if let poiList = poiList {
                    let sortedPoiList = poiList.sorted { (first, second) -> Bool in
                        guard let first = first else { return false }
                        guard let second = second else { return false }

                        if let currentPosition = TMapPoint(lon: longitude, lat: latitude) {
                            let t1 = currentPosition.getDistanceWith(first.getPOIPoint())
                            let t2 = currentPosition.getDistanceWith(second.getPOIPoint())
                            return t1 < t2
                        }

                        return false
                    }
                    completion(sortedPoiList as? [EIPOIItem])
                } else {
                    completion([])
                }
            }
        }
    }
}

//
//  ChargerManager.swift
//  evInfra
//
//  Created by Michael Lee on 2020/06/02.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChargerManager {
    
    static let sharedInstance = ChargerManager()
    
    private var mDb: DataBaseHelper? = nil

    private var mIsReady: Bool = false

    private var mChargerStationInfoList = [ChargerStationInfo]()

    public init() {
        if Const.EV_PAY_SERVER.contains("https") == false {
            DataBaseHelper.DATABASE_NAME = DataBaseHelper.DEV_DATABASE_NAME
        }
    
        if DataBaseHelper.importDatabase() {
            Log.d(tag: Const.TAG, msg: "im success")
        } else {
            Log.d(tag: Const.TAG, msg: "im fail")
        }
        mDb = DataBaseHelper.sharedInstance
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

    private func updateCompanyInfoListFromServer(json : JSON) {
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
            companyInfo.is_visible = isVisible
            try! mDb?.updateCompanyInfo(companyInfo: companyInfo)
        }
    }

    // station info
    private func updateStationInfoListFromServer(json : JSON) {
        let code = json["code"]
        let list = json["list"]
        let last = json["last"]
        
        if (code == 1000 && list.array!.count > 0) {
            Log.d(tag: Const.TAG, msg: "start station info list insert or update")
            
            var stationList = [StationInfoDto]()
            
            for station in list.arrayValue{
                let stationInfo = StationInfoDto()
                stationInfo.setStationInfo(json: station)
                stationList.append(stationInfo)
            }
            
            try! mDb?.insertOrUpdateStationInfoList(list: stationList)
            try! mDb?.insertOrUpdateInfoLastUpdate(info_type: ChargerConst.INFO_TYPE_STATION,lastUpdate: last.stringValue)
            Log.d(tag: Const.TAG, msg: "end station info list insert or update")
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
            chargerStationInfo.createMarker()
        }
        Log.d(tag: Const.TAG, msg: "marker create")
    }

    // charger station info
    private func setChargerStationInfoList() {
        mChargerStationInfoList.removeAll()

        let stationInfoDtoList = getStationInfoListAll()
        for stationInfoDto in stationInfoDtoList! {
            mChargerStationInfoList.append(ChargerStationInfo(stationInfoDto))
        }
    }

    public func getChargerStationInfoList() -> [ChargerStationInfo] {
        return self.mChargerStationInfoList
    }
    
    func binarySearch(_ inputArr:Array<ChargerStationInfo>, _ searchItem: ChargerStationInfo) -> Int? {
        
        guard let chargerId = searchItem.mChargerId else {
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
                Log.e(tag: Const.TAG, msg: "charger list size: \(mChargerStationInfoList.count), charger_id: \(charger_id), index: \(searchIndex)")
            }
        }
        return nil
    }

    // from server or from db
    public func getChargerCompanyInfo(listener : ChargerManagerListener?) {
        var updateDate = ""
        if (try! (mDb?.getCompanyInfoList()!.count)! > 0) {
            if let dto = try! mDb?.getCompanyInfoLastUpdate() {
                updateDate = (dto.mInfoLastUpdateDate)!
            }
        }
        
        Server.getCompanyInfo(updateDate: updateDate) { (isSuccess, value) in
            if isSuccess {
                self.updateCompanyInfoListFromServer(json: JSON(value))
                if let chargerManagerListener = listener {
                    chargerManagerListener.onComplete()
                }
            } else {
                if let chargerManagerListener = listener {
                    chargerManagerListener.onError(errorMsg: "network error")
                }
            }
        }
    }

    public func getStationInfoFromServer(listener : ChargerManagerListener?) {
        var updateDate = ""
        if let dto = try! mDb?.getStationInfoLastUpdate() {
            updateDate = (dto.mInfoLastUpdateDate)!
        }

        Server.getStationInfo(updateDate: updateDate) { (isSuccess, value) in
            if isSuccess {
                /*
                 var stationInfoTask = StationInfoTask(response, listener)
                 stationInfoTask.execute()
                 */
                self.updateStationInfoListFromServer(json: JSON(value!))
                self.setChargerStationInfoList()
                self.getStationStatus(listener: listener)
            }
        }
    }

    private func getStationStatus(listener : ChargerManagerListener?) {

        Server.getStationStatus { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let code = json["code"]
                let list = json["list"]

                if (code == 1000 && list.count > 0) {
                
                    for status in list.arrayValue {
                        let chargerId = status["id"].stringValue
                        let cst = status["st"].intValue
                        let power = status["p"].intValue
                        let type_id = status["tp"].intValue
                        
                        if let chargerStationInfo = self.getChargerStationInfoById(charger_id: chargerId) {
                            chargerStationInfo.mTotalStatus = cst
                            chargerStationInfo.mTotalType = type_id
                            chargerStationInfo.mPower = power
                        }
                    }

                    self.createAllMarker()
                    self.mIsReady = true
                    if let chargerManagerListener = listener {
                        chargerManagerListener.onComplete()
                    }
                }
            }
        }
    }

    public func getFavoriteList(listener : ChargerManagerListener?) {
        
        Server.getFavoriteList { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let code = json["code"]
                let list = json["list"]
                
                if (code == 1000 && list.count > 0) {
                
                    for favorite in list.arrayValue {
                        let chargerId = favorite["id"].stringValue
                        let noti = favorite["noti"].boolValue
                        
                        if let chargerStationInfo = self.getChargerStationInfoById(charger_id: chargerId) {
                            chargerStationInfo.mFavorite = true
                            chargerStationInfo.mFavoriteNoti = noti
                        }
                    }
                    
                    if let chargerManagerListener = listener {
                        chargerManagerListener.onComplete()
                    }
                }
            }
        }
    }

/*
    public class StationInfoTask extends AsyncTask<Void, Boolean, Boolean> {
        ChargerManager.ChargerManagerListener listener
        String json

        StationInfoTask(String json, ChargerManagerListener listener) {
            this.json = json
            this.listener = listener
        }

        @Override
        protected Boolean doInBackground(Void... voids) {
            updateStationInfoListFromServer(this.json)
            setChargerStationInfoList()
            return true
        }

        @Override
        protected void onPostExecute(Boolean b) {
            super.onPostExecute(b)
            getStationStatus(this.listener)
        }
    }
 */
    
    func getFavoriteCharger() {
        if MemberManager.getMbId() > 0 {
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
        if MemberManager.getMbId() > 0 {
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
    public func findAllPOI(keyword : String, callback : FindAllPOIListenerCallback) {
        if let currentPosition = MainViewController.currentLocation{
            findAllPOI(centerLat: currentPosition.getLatitude(), centerLon: currentPosition.getLongitude(), keyword: keyword, callback: callback)
        }
    }

    public func findAllPOI(centerLat : Double, centerLon : Double, keyword : String, callback : FindAllPOIListenerCallback) {
        
        if StringUtils.isNullOrEmpty(keyword) {
            callback.onFindAllPOI(poiList: nil)
        }
        
        Server.getPoiItemList(count: 100, radius: 0, centerLat: centerLat, centerLon: centerLon, keyword: keyword) { (isSuccess, result) in
            if  isSuccess {
                let json = JSON(result)
                let searchPoiInfo = json["searchPoiInfo"]
                _ = searchPoiInfo["totalCount"].intValue
                _ = searchPoiInfo["count"].intValue
                _ = searchPoiInfo["page"].intValue
                let pois = searchPoiInfo["pois"]
                let poi = pois["poi"]
                var poiList = [EIPOIItem].deserialize(from: poi.rawString())
                
                if (poiList) != nil {
                    poiList!.sort(by: { (first, second) -> Bool in
                        if (first == nil) || (second == nil) {
                            return false
                        }
                        if let currentPosition = MainViewController.currentLocation {
                            let t1 = currentPosition.getDistanceWith(first!.getPOIPoint())
                            let t2 = currentPosition.getDistanceWith(second!.getPOIPoint())
                            return t1 < t2
                        }
                        return false
                    })
                    callback.onFindAllPOI(poiList: (poiList as! [EIPOIItem]))
                } else {
                    callback.onFindAllPOI(poiList: nil)
                }
            }
        }
    }
}

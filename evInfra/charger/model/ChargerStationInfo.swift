//
//  ChargerStationInfo.swift
//  evInfra
//
//  Created by Michael Lee on 2020/06/09.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChargerStationInfo {
    
    var mChargerId: String?
    
    var mStationInfoDto: StationInfoDto?

    var mTotalStatus: Int?
    
    var mTotalStatusName: String?
    
    var mTotalStatusImg: UIImage!

    var mTotalType: Int?

    var mPower: Int = 0
    
    var mPowerSt: String?
    
    var mLimit: String?

    var usage: Array<Int> = Array() // 충전소 시간별 이용횟수

    var marker: TMapMarkerItem!
    var cidInfo: CidInfo!
    
    var mFavorite = false
    var mFavoriteNoti = false // 즐겨찾기 알람 on/off
    
    var isAroundPath = true // 이동경로 주변
    var mGuard = false  // 지킴이 관리대상 충전소
    
    var mDistance: Double = 0
    
    var cidInfoList = [CidInfo]()
    
    var status: Int?
    
    init(_ charger_id : String) {
        self.mChargerId = charger_id
        initChargerStationInfo()
    }
    
    init(_ stationInfo : StationInfoDto) {
        self.mStationInfoDto = stationInfo
        self.mChargerId = stationInfo.mChargerId
        initChargerStationInfo()
    }
    
    func initChargerStationInfo() {
        cidInfo = CidInfo.init()
        //mTotalStatusName = cidInfo.cstToString(cst: self.mTotalStatus!)
    }
    
    func setStationInfo(jsonList : JSON) {
        let clist = jsonList["cl"]
        
        for (_, item):(String, JSON) in clist {
            let cidInfo = CidInfo.init(cid: item["cid"].stringValue, chargerType: item["tid"].intValue, cst: item["cst"].stringValue, recentDate: item["rdt"].stringValue, power: item["p"].intValue, limit: item["lm"].stringValue)
            self.cidInfoList.append(cidInfo)
        }
        self.sortCharger()
        
        if !self.cidInfoList.isEmpty {
            var stationSt = self.cidInfoList[0].status!
            for cid in self.cidInfoList {
                if (stationSt != cid.status) {
                    if(cid.status == Const.CHARGER_STATE_WAITING) {
                        stationSt = cid.status!
                        break
                    }
                }
            }
            self.status = stationSt
        }
    }
    
    func createMarker() {
        if self.mTotalStatus == nil {
            mTotalStatusName = cidInfo.cstToString(cst: Const.CHARGER_STATE_UNCONNECTED)
        } else {
            mTotalStatusName = cidInfo.cstToString(cst: self.mTotalStatus!)
        }
        marker = TMapMarkerItem.init()
        marker.setTMapPoint(self.getTMapPoint())
        marker.setIcon(getMarkerIcon(), anchorPoint: CGPoint(x: 0.5, y: 1.0))
    }
    
    func changeStatus(status: Int) {
        self.mTotalStatus = status
        mTotalStatusName = cidInfo.cstToString(cst: self.mTotalStatus!)
        marker.setIcon(getMarkerIcon(), anchorPoint: CGPoint(x: 0.5, y: 1.0))
    }
    
    func getTMapPoint() -> TMapPoint {
        return TMapPoint(lon: (mStationInfoDto?.mLongitude)!, lat: (mStationInfoDto?.mLatitude)!)
    }
    
    func getTMapPoint(lon : Double, lat : Double) -> TMapPoint {
        return TMapPoint(lon: lon, lat: lat)
    }
    
    func check(filter: ChargerFilter) -> Bool {
        guard let stationInfo = mStationInfoDto else {
            return false
        }

        // skind = 01:마트 02:관공서 03:공영주차장 04:마을회관 05:고속도로 06:테마파크(공원) 07:광장 08:휴게소(?)
        // 고속도로
//        if filter.wayId == ChargerFilter.WAY_HIGH && stationInfo.mSkind != "05" {
//            return false
//        }
//
//        // 일반도로
//        if filter.wayId == ChargerFilter.WAY_NORMAL && stationInfo.mSkind == "05" {
//            return false
//        }
//
//        if filter.wayId == ChargerFilter.WAY_HIGH_UP && stationInfo.mDirection != 1 {
//            return false
//        }
//
//        if filter.wayId == ChargerFilter.WAY_HIGH_DOWN && stationInfo.mDirection != 2  {
//            return false
//        }
        
        // 유료 충전소
//        if filter.payId == 1 && stationInfo.mPay == "N" {
//            return false
//        }
//
//        // 무료 충전소
//        if filter.payId == 2 && stationInfo.mPay == "Y" {
//            return false
//        }
//
//        // 100kW filter
//        if filter.payId == 3 {
//            guard let power = mPower else { return false }
//            if power < 100 {
//                return false
//            }
//        }
        if !filter.isPublic && self.mLimit == "N" { // 공용 해제 시 접근제한 N 충전소 false
            return false
        }
        if !filter.isNonPublic && self.mLimit == "Y" {
            return false
        }
        
        if !filter.isFree && stationInfo.mPay == "N" { // 무료 해제 시 무료 충전소 false
            return false
        }
        if !filter.isPaid && stationInfo.mPay == "Y" {
            return false
        }
        
        if !filter.isOutdoor && !(stationInfo.mRoof == "1" || stationInfo.mRoof == "2") { // 실내 해제 시 실외거나 케노피 아닐시 false
            return false
        }
        if !filter.isIndoor && !(stationInfo.mRoof == "0" || stationInfo.mRoof == "2") {
            return false
        }
        if !filter.isCanopy && !(stationInfo.mRoof == "0" || stationInfo.mRoof == "1") {
            return false
        }

        if !filter.isGeneralWay && stationInfo.mSkind != "05" { // 일반도로 해제 시 고속도로 제외 전부 false
            return false
        }
        if !filter.isHighwayUp && (stationInfo.mSkind == "05" && stationInfo.mDirection == 1){ // 상향 고속 해제 시 고속도로인데 상향이면 false
            return false
        }
        if !filter.isHighwayDown && (stationInfo.mSkind == "05" && stationInfo.mDirection == 2){
            return false
        }
        
        if self.mPower < filter.minSpeed || filter.maxSpeed < self.mPower { // 속도제한 사이
            return false
        }
        
        // 운영 기관
        if let company = filter.companies[(stationInfo.mCompanyId)!] {
            if !company {
                return false
            }
        } else {
            return false
        }
        
        // 수소충전소 막음
        if stationInfo.mCompanyId!.elementsEqual("J") {
            return false
        }
        
        // chargerType = 01:DC차데모 02:DC콤보 03:DC차데모+AC상 04:AC상 05:DC차데모 + DC콤보 06:DC차데모+AC상+DC콤보 10:완속
        
        if self.mTotalType == nil {
            //Log.d(tag: Const.TAG, msg: "mTotalType = nil : id = " + self.mChargerId!)
            return false
        }
        
        if filter.dcDemo {
            if (self.mTotalType! & Const.CTYPE_DCDEMO) == Const.CTYPE_DCDEMO {
                return true
            }
        }
        if filter.dcCombo {
            if (self.mTotalType! & Const.CTYPE_DCCOMBO) == Const.CTYPE_DCCOMBO {
                return true
            }
        }
        if filter.ac3 {
            if (self.mTotalType! & Const.CTYPE_AC) == Const.CTYPE_AC {
                return true
            }
        }
        if filter.superCharger {
            if (self.mTotalType! & Const.CTYPE_SUPER_CHARGER) == Const.CTYPE_SUPER_CHARGER {
                return true
            }
        }
        if filter.slow {
            if (self.mTotalType! & Const.CTYPE_SLOW) == Const.CTYPE_SLOW {
                return true
            } else if (self.mTotalType! & Const.CTYPE_DESTINATION) == Const.CTYPE_DESTINATION {
                return true
            }
        }
        
        return false
    }
    
    func getTotalChargerType() -> String {
        
        if (self.mTotalType == nil){
            //Log.d(tag: Const.TAG, msg: "mTotalType = nil : id = " + self.mChargerId!);
            return "기타 "
        }
        
        var typeName = ""
        if (self.mTotalType! & Const.CTYPE_DCDEMO) == Const.CTYPE_DCDEMO {
            typeName = "DC차데모 "
        }
        if (self.mTotalType! & Const.CTYPE_DCCOMBO) == Const.CTYPE_DCCOMBO {
            typeName = typeName + "DC콤보 "
        }
        if (self.mTotalType! & Const.CTYPE_AC) == Const.CTYPE_AC {
            typeName = typeName + "AC3상 "
        }
        if (self.mTotalType! & Const.CTYPE_SLOW) == Const.CTYPE_SLOW {
            typeName = typeName + "완속 "
        }
        if (self.mTotalType! & Const.CTYPE_HYDROGEN) == Const.CTYPE_HYDROGEN {
            typeName = typeName + "수소연료자동차 "
        }
        if (self.mTotalType! & Const.CTYPE_SUPER_CHARGER) == Const.CTYPE_SUPER_CHARGER {
            typeName = typeName + "수퍼차저 "
        }
        if (self.mTotalType! & Const.CTYPE_DESTINATION) == Const.CTYPE_DESTINATION {
            typeName = typeName + "데스티네이션 "
        }
        return typeName
    }
    
    func getSelectIcon() -> UIImage {
        var markerIcon: UIImage!
        let isPay = (mStationInfoDto?.mPay == "Y")
        let isCharging = (self.mTotalStatusName == "충전중")
        let companyArray = ChargerManager.sharedInstance.getCompanyInfoListAll()
        if let company = companyArray?.filter({$0.company_id!.elementsEqual((mStationInfoDto?.mCompanyId)!)}).first {
            if let iconName = company.icon_name {
                markerIcon = ImageMarker.marker(state: ImageMarker.markerHere, company: iconName, isCharging: isCharging, isPay: isPay)
            } else {
                markerIcon = ImageMarker.resizeMarker(path: ImageMarker.markerHere)
            }
        } else {
            markerIcon = ImageMarker.resizeMarker(path: ImageMarker.markerHere)
        }
        
        return markerIcon
    }
    
    func getCompanyIcon() -> UIImage? {
        let companyArray = ChargerManager.sharedInstance.getCompanyInfoListAll()
        var resultIcon:UIImage? = nil
        if let company = companyArray?.filter({$0.company_id!.elementsEqual((mStationInfoDto?.mCompanyId)!)}).first {
            if let iconName = company.icon_name {
                if let icon = ImageMarker.companyImg(company: iconName){
                    resultIcon = icon
                }
            }
        }
        return resultIcon ?? nil
    }
    
    func getMarkerIcon() -> UIImage {
        if (StringUtils.isNullOrEmpty(mStationInfoDto?.mCompanyId)) {
            return ImageMarker.NORMAL!
        }
        
        var markerIcon: UIImage!
        if (self.mTotalStatusName == "운영중지" || self.mTotalStatusName == "점검중" || mStationInfoDto?.mHoliday == "Y") {
            markerIcon = ImageMarker.markers["marker_state_no_op_\((mStationInfoDto?.mCompanyId)!)"]
        } else if (self.mTotalStatusName == "충전중") {
            markerIcon = ImageMarker.markers["marker_state_charging_\((mStationInfoDto?.mCompanyId)!)"]
        } else if (self.mTotalStatusName == "통신미연결" || self.mTotalStatusName == "상태미확인") {
            markerIcon = ImageMarker.markers["marker_state_no_connect_\((mStationInfoDto?.mCompanyId)!)"]
        } else {
            markerIcon = ImageMarker.markers["marker_state_normal_\((mStationInfoDto?.mCompanyId)!)"]
        }
        
        if markerIcon == nil {
            markerIcon = ImageMarker.NORMAL!
        }
        
        return markerIcon
    }
    
    func getChargerPower(power:Int, type:Int) -> String{
        var strPower = ""
        if power == 0 {
            if ((type & Const.CTYPE_DCDEMO) > 0 ||
                (type & Const.CTYPE_DCCOMBO) > 0 ||
                (type & Const.CTYPE_AC) > 0) {
                strPower = "50kW"
            } else if ((type & Const.CTYPE_SLOW) > 0 ||
                (type & Const.CTYPE_DESTINATION) > 0) {
                strPower = "완속"

            } else if ((type & Const.CTYPE_HYDROGEN) > 0) {
                strPower = "수소"
            } else if ((type & Const.CTYPE_SUPER_CHARGER) > 0) {
                strPower = "110kW 이상"
            } else {
                strPower = "-"
            }
        } else {
            strPower = "\(power)kW"
        }
        return strPower
    }
    
    func getChargeStateImg(type:String) -> UIImage{
        var stateImg:UIImage!
        
        switch type {
        case "충전중":
            stateImg = UIImage(named: "detail_mark_charging.png")
            break
        case "대기중":
            stateImg = UIImage(named: "detail_mark_wait.png")
            break
        case "운영중지":
            stateImg = UIImage(named: "detail_mark_stop.png")
            break
        default:
            stateImg = UIImage(named: "detail_mark_unconnect.png")
            break
        }
        return stateImg
    }
    func getCountFastPower() -> String {
        if !self.cidInfoList.isEmpty {
            var totalFastCount = 0
            var fastCount = 0
            var total = "0/0"
            for cid:CidInfo in self.cidInfoList {
                if cid.chargerType != Const.CHARGER_TYPE_SLOW && cid.chargerType != Const.CHARGER_TYPE_DESTINATION && cid.chargerType != Const.CHARGER_TYPE_ETC {
                    totalFastCount += 1
                    if cid.status == Const.CHARGER_STATE_WAITING{
                        fastCount += 1
                    }
                }
            }
            total = String(fastCount) + "/" + String(totalFastCount)
            return total
        }
        return ""
    }
    
    func getCountSlowPower() -> String {
        if !self.cidInfoList.isEmpty {
            var totalSlowCount = 0
            var slowCount = 0
            var total = "0/0"
            for cid:CidInfo in self.cidInfoList {
                if cid.chargerType == Const.CHARGER_TYPE_SLOW || cid.chargerType == Const.CHARGER_TYPE_DESTINATION || cid.chargerType == Const.CHARGER_TYPE_ETC {
                    totalSlowCount += 1
                    if cid.status == Const.CHARGER_STATE_WAITING {
                        slowCount += 1
                    }
                }
            }
            total = String(slowCount) + "/" + String(totalSlowCount)
            return total
        }
        return ""
    }
    
    func sortCharger() {
        if cidInfoList.count > 0 {
            cidInfoList = cidInfoList.sorted(by: {
                $0.power > $1.power
            })
        }
    }
}

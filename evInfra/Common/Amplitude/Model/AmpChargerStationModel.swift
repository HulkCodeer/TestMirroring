//
//  AmpChargerStationModel.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/08/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

internal struct AmpChargerStationModel {
    var stationNm: String = ""
    var operatorNm: String = ""
    var rapidCnt: Int = 0
    var slowCnt: Int = 0
    var availableRapidCnt: Int = 0
    var availableSlowCnt: Int
    var connectFailRapidCnt: Int
    var connectFailSlowCnt: Int
    var socketType: [String] = [String]()
    var locationType: String = ""
    var isOpen: String = ""
    var reviewCnt: String? = ""
    var isApartment: String? = ""
    var paidOrFree: String = ""
    var locationRoad: String = ""
    var distance: String = ""
    var peopleViewing: String = ""
    var chargingState: [String] = [String]()
    var chargingTime: [String] = [String]()
    var lastUsed: [String] = [String]()
    var powerSlow: Int = 0
    var power50: Int = 0
    var power100: Int = 0
    var power120: Int = 0
    var power200: Int = 0
    var power250: Int = 0
    var chargePriceSlow: String = ""
    var chargePriceFast: String = ""
    var workingHours: String = ""
    var heightLimit: String? = ""
    var isTwoArms: String? = ""
    
    init(_ chargerStation: ChargerStationInfo) {
        self.stationNm = chargerStation.mStationInfoDto?.mSnm ?? ""
        self.operatorNm = chargerStation.mStationInfoDto?.mOperator ?? ""
        self.rapidCnt = chargerStation.cidInfoList.filter({
            return $0.chargerType != Const.CHARGER_TYPE_SLOW && $0.chargerType != Const.CHARGER_TYPE_DESTINATION && $0.chargerType != Const.CHARGER_TYPE_ETC
        }).count
        self.slowCnt = chargerStation.cidInfoList.filter({
            return $0.chargerType == Const.CHARGER_TYPE_SLOW || $0.chargerType == Const.CHARGER_TYPE_DESTINATION || $0.chargerType == Const.CHARGER_TYPE_ETC
        }).count
        self.availableRapidCnt = chargerStation.cidInfoList.filter({
            return $0.chargerType != Const.CHARGER_TYPE_SLOW && $0.chargerType != Const.CHARGER_TYPE_DESTINATION && $0.chargerType != Const.CHARGER_TYPE_ETC && $0.status == Const.CHARGER_STATE_WAITING
        }).count
        self.availableSlowCnt = chargerStation.cidInfoList.filter({
            return ($0.chargerType == Const.CHARGER_TYPE_SLOW || $0.chargerType == Const.CHARGER_TYPE_DESTINATION || $0.chargerType == Const.CHARGER_TYPE_ETC) && $0.status == Const.CHARGER_STATE_WAITING
        }).count
        self.connectFailRapidCnt = chargerStation.cidInfoList.filter({
            return $0.chargerType != Const.CHARGER_TYPE_SLOW && $0.chargerType != Const.CHARGER_TYPE_DESTINATION && $0.chargerType != Const.CHARGER_TYPE_ETC && $0.status == Const.CHARGER_STATE_UNCONNECTED
        }).count
        self.connectFailSlowCnt = chargerStation.cidInfoList.filter({
            return ($0.chargerType == Const.CHARGER_TYPE_SLOW || $0.chargerType == Const.CHARGER_TYPE_DESTINATION || $0.chargerType == Const.CHARGER_TYPE_ETC) && $0.status == Const.CHARGER_STATE_UNCONNECTED
        }).count
        self.socketType = getTotalChargerType(chargerStation.mTotalType ?? Const.CTYPE_SLOW)
        self.locationType = getLocationType(chargerStation.mStationInfoDto?.mRoof ?? "N")
        self.isOpen = chargerStation.mLimit == "Y" ? "비개방" : "개방"
        self.reviewCnt = "0"
        self.isApartment = ""
        self.paidOrFree = isPaid(chargerStation)
        self.locationRoad = getLocationLoad(chargerStation.mStationInfoDto?.mSkind)
        self.distance = getDistance(lat: chargerStation.mStationInfoDto?.mLatitude ?? .zero, lng: chargerStation.mStationInfoDto?.mLongitude ?? .zero)
        self.chargingState = chargerStation.cidInfoList.map({
            return $0.cstToString(cst: $0.status)
        })
        self.workingHours = chargerStation.mStationInfoDto?.mUtime ?? ""
        getChargingTime(chargerStation.cidInfoList)
        getPower(chargerStation.cidInfoList)
        self.heightLimit = nil
        self.isTwoArms = nil
    }
    
    private func getTotalChargerType(_ mTotalType: Int) -> [String] {
        var types: [String] = [String]()
        if (mTotalType & Const.CTYPE_DCDEMO) == Const.CTYPE_DCDEMO {
            types.append("DC차데모")
        }
        if (mTotalType & Const.CTYPE_DCCOMBO) == Const.CTYPE_DCCOMBO {
            types.append("DC콤보")
        }
        if (mTotalType & Const.CTYPE_AC) == Const.CTYPE_AC {
            types.append("AC3상")
        }
        if (mTotalType & Const.CTYPE_SLOW) == Const.CTYPE_SLOW {
            types.append("완속")
        }
        if (mTotalType & Const.CTYPE_SUPER_CHARGER) == Const.CTYPE_SUPER_CHARGER {
            types.append("슈퍼차저")
        }
        if (mTotalType & Const.CTYPE_DESTINATION) == Const.CTYPE_DESTINATION {
            types.append("데스티네이션")
        }
        return types
    }
    
    private func getLocationType(_ roofType: String) -> String {
        switch roofType {
        case "0": return "실외"
        case "1": return "실내"
        case "2": return "캐노피"
        default: return "확인중"
        }
    }
    
    private func isPaid(_ chargerStationInfo: ChargerStationInfo?) -> String {
        guard let chargerStationInfo = chargerStationInfo else { return "" }

        let isPilot = chargerStationInfo.mStationInfoDto?.mIsPilot ?? false
        let pay = chargerStationInfo.mStationInfoDto?.mPay
        
        if !isPilot {
            return "시범운영"
        } else {
            return pay == "Y" ? "유료" : "무료"
        }
    }
    
    private func getLocationLoad(_ loadType: String?) -> String {
        guard let loadType = loadType else { return "" }
        switch loadType {
        case "01": return "이마트"
        case "02": return "관공서"
        case "03": return "공영주차장"
        case "04": return "마을회관"
        case "05": return "고속도로"
        case "06": return "테마파크(공원)"
        case "07": return "광장"
        case "08": return "국도휴게소"
        default: return ""
        }
    }
    
    private func getDistance(lat: Double, lng: Double) -> String {
        var distance: Double?
        let currentPosition = CLLocationManager().getCurrentCoordinate()
        let tmapPathData = TMapPathData()
        if let path = tmapPathData.find(from: TMapPoint(coordinate: currentPosition), to: TMapPoint(lon: lng, lat: lat)) {
            distance = path.getDistance()
        }
//        DispatchQueue.global(qos: .background).async {
//            let currentPosition = CLLocationManager().getCurrentCoordinate()
//            let tmapPathData = TMapPathData()
//            if let path = tmapPathData.find(from: TMapPoint(coordinate: currentPosition), to: TMapPoint(lon: lng, lat: lat)) {
//                distance = path.getDistance()
//            }
//        }
        let distanceToStr = round((distance ?? .zero) / 1000 * 10) / 10
        return "\(distanceToStr)"
    }
    
    private mutating func getPower(_ cidInfoList: [CidInfo]) {
        var power: [Int: Int] = [Int: Int]()
        cidInfoList.forEach {
            if let _power = power[$0.power] {
                power[$0.power] = _power + 1
            } else {
                power[$0.power] = 1
            }
        }
        self.powerSlow = (power[0] ?? 0) + (power[3] ?? 0) + (power[7] ?? 0)
        self.power50 = power[50] ?? 0
        self.power100 = power[100] ?? 0
        self.power120 = power[120] ?? 0
        self.power200 = power[200] ?? 0
        self.power250 = power[250] ?? 0
    }
    
    private mutating func getChargingTime(_ cidInfoList: [CidInfo]) {
        cidInfoList.forEach {
            if $0.status == Const.CHARGER_STATE_CHARGING {
                self.chargingTime.append($0.getChargingDuration())
            } else if $0.status == Const.CHARGER_STATE_WAITING {
                self.lastUsed.append(DateUtils.getDateStringForDetail(date: $0.recentDate ?? ""))
            }
        }
    }
    
    var toProperty: [String: Any?] {
        [
            "stationName": self.stationNm,
            "operatorName": self.operatorNm,
            "rapidCount": self.rapidCnt,
            "slowCount": self.slowCnt,
            "availableRapidCount": self.availableRapidCnt,
            "availableSlowCount": self.availableSlowCnt,
            "connectfailRapidCount": self.connectFailRapidCnt,
            "connectfailSlowCount": self.connectFailSlowCnt,
            "socketType": self.socketType,
            "locationType": self.locationType,
            "openness": self.isOpen,
            "apartment": self.isApartment,
            "paidOrFree": self.paidOrFree,
            "locationRoad": self.locationRoad,
            "distance": self.distance,
            "peopleViewing": self.peopleViewing,
            "chargingState": self.chargingState,
            "chargingTime": self.chargingTime,
            "lastUsed": self.lastUsed,
//            "chargeSpeed" : self.spe
            "workingHours": self.workingHours,
            "heightLimit": self.heightLimit,
            "twoArms": self.isTwoArms,
            "powerSlow": self.powerSlow,
            "power50": self.power50,
            "power100": self.power100,
            "power120": self.power120,
            "power200": self.power200,
            "power250": self.power250
        ]
    }
}

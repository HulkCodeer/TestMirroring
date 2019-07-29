//
//  CodableCharger.swift
//  evInfra
//
//  Created by bulacode on 25/01/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

class Charger: Codable {

    var longitude: Double = 0
    var latitude: Double = 0
    
    var lng: String = ""
    var lat: String = ""
    
    var chargerId: String = ""
    var companyId: String = "A"
    
    var stationName: String = ""
    var address: String = ""
    
    var status: String = ""
    
    var totalChargerType: Int = Const.CTYPE_SLOW
    var skind: String = "02"
    var holiday: String = "N"
    var pay: String = "N"
    var isPilot : Bool = false
    var power: Int = 0
    var area: Int = 0
    var grade: String?
    var pcnt: String?
    var direction: Int = 0 // 0: none 1: 고속도로 상행 2: 고속도로 하행

    var usage: Array<Int> = Array() // 충전소 시간별 이용횟수

    var marker : TMapMarkerItem!
    var cidInfo: CidInfo!
    
    var statusName = ""
    
    var favorite = false
    var favoriteAlarm = false // 즐겨찾기 알람 on/off
    
    var isAroundPath = true // 이동경로 주변
    var isGuard = false  // 지킴이 관리대상 충전소
    
    var gpa = 0.0
    var gpaPersonCnt = 0
    
    enum CodingKeys: String, CodingKey {
        case chargerId = "id"
        case companyId = "co_id"
        case stationName = "snm"
        case address = "adr"
        case totalChargerType = "tp"
        case status = "st"
        case skind = "skind"
        case holiday = "hol"
        case isPilot = "pilot"
        case lat = "x"
        case lng = "y"
        case pay = "pay"
        case power = "power"
        case area = "area"
        case grade = "grade"
        case pcnt = "pcnt"
        case direction = "drt"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lat = try values.decodeIfPresent(String.self, forKey: .lat) ?? ""
        lng = try values.decodeIfPresent(String.self, forKey: .lng) ?? ""
        chargerId = try values.decodeIfPresent(String.self, forKey: .chargerId) ?? ""
        companyId = try values.decodeIfPresent(String.self, forKey: .companyId) ?? "A"
        stationName = try values.decodeIfPresent(String.self, forKey: .stationName) ?? ""
        address = try values.decodeIfPresent(String.self, forKey: .address) ?? ""
        status = try values.decodeIfPresent(String.self, forKey: .status) ?? ""
        totalChargerType = try values.decodeIfPresent(Int.self, forKey: .totalChargerType) ?? Const.CTYPE_SLOW
        skind = try values.decodeIfPresent(String.self, forKey: .skind) ?? "02"
        holiday = try values.decodeIfPresent(String.self, forKey: .holiday) ?? "N"
        pay = try values.decodeIfPresent(String.self, forKey: .pay) ?? "N"
        isPilot = try values.decodeIfPresent(Bool.self, forKey: .isPilot) ?? false
        power = try values.decodeIfPresent(Int.self, forKey: .power) ?? 0
        area = try values.decodeIfPresent(Int.self, forKey: .area) ?? 0
        grade = try values.decodeIfPresent(String.self, forKey: .grade)
        pcnt = try values.decodeIfPresent(String.self, forKey: .pcnt)
        area = try values.decodeIfPresent(Int.self, forKey: .area) ?? 0
        direction = try values.decodeIfPresent(Int.self, forKey: .direction) ?? 0
        
        if let doubleLat = lat.parseDouble() {
            self.latitude = doubleLat
        }
        
        if let doubleLng = lng.parseDouble() {
            self.longitude = doubleLng
        }
        
        self.cidInfo = CidInfo.init()
        self.statusName = self.cidInfo.cstToString(cst: Int(self.status)!)
        
        if isPilot {
            self.pay = "N"
        }
        
        if let gradePointAvg = self.grade, gradePointAvg.count > 0 {
            self.gpa = Double(gradePointAvg)!
        }
        
        if let gradePersonCnt = self.pcnt, !gradePersonCnt.isEmpty {
            self.gpaPersonCnt = Int(gradePersonCnt)!
        }
        
        self.marker = TMapMarkerItem.init()
        self.marker.setTMapPoint(TMapPoint(lon: self.longitude, lat: self.latitude))
        self.marker.setIcon(getMarkerIcon(), anchorPoint: CGPoint(x: 0.5, y: 1.0))
    }
    
    func changeStatus(st: String!) {
        self.status = st
        self.statusName = self.cidInfo.cstToString(cst: Int(self.status)!)
        self.marker.setIcon(getMarkerIcon(), anchorPoint: CGPoint(x: 0.5, y: 1.0))
    }
    
    func getPoint() -> TMapPoint {
        return TMapPoint.init(lon: longitude, lat: latitude)
    }
    
    func check(filter: ChargerFilter) -> Bool {
        // skind = 01:마트 02:관공서 03:공영주차장 04:마을회관 05:고속도로 06:테마파크(공원) 07:광장 08:휴게소(?)
        // 고속도로
        if filter.wayId == ChargerFilter.WAY_HIGH && skind != "05" {
            return false
        }
        
        // 일반도로
        if filter.wayId == ChargerFilter.WAY_NORMAL && skind == "05" {
            return false
        }
        
        if filter.wayId == ChargerFilter.WAY_HIGH_UP && direction != 1 {
            return false
        }
        
        if filter.wayId == ChargerFilter.WAY_HIGH_DOWN && direction != 2  {
            return false
        }
        
        // 유료 충전소
        if filter.payId == 1 && pay == "N" {
            return false
        }
        
        // 무료 충전소
        if filter.payId == 2 && pay == "Y" {
            return false
        }
        
        // 100kW filter
        if filter.payId == 3 && power < 100 {
            return false
        }
        
        // 운영 기관
        guard let company = filter.companies[self.companyId] else {
            return false
        }
        if !company {
            return false
        } else {
            // TODO 임시로 company id hard coding. 딱히 쓸만한게 없네~
            // 운영기관 필터에서 수소충전소를 선택했을 때만 수소충전소 노출
            // 그 외에는 보여주지 않음
            if self.companyId.elementsEqual("J") {
                return true;
            }
        }
        
        // chargerType = 01:DC차데모 02:DC콤보 03:DC차데모+AC상 04:AC상 05:DC차데모 + DC콤보 06:DC차데모+AC상+DC콤보 10:완속
        if filter.dcDemo {
            if (self.totalChargerType & Const.CTYPE_DCDEMO) == Const.CTYPE_DCDEMO {
                return true
            }
        }
        if filter.dcCombo {
            if (self.totalChargerType & Const.CTYPE_DCCOMBO) == Const.CTYPE_DCCOMBO {
                return true
            }
        }
        if filter.ac3 {
            if (self.totalChargerType & Const.CTYPE_AC) == Const.CTYPE_AC {
                return true
            }
        }
        if filter.superCharger {
            if (self.totalChargerType & Const.CTYPE_SUPER_CHARGER) == Const.CTYPE_SUPER_CHARGER {
                return true
            }
        }
        if filter.slow {
            if (self.totalChargerType & Const.CTYPE_SLOW) == Const.CTYPE_SLOW {
                return true
            } else if (self.totalChargerType & Const.CTYPE_DESTINATION) == Const.CTYPE_DESTINATION {
                return true
            }
        }
        
        return false
    }
    
    func getTotalChargerType() -> String {
        var typeName = ""
        if (self.totalChargerType & Const.CTYPE_DCDEMO) == Const.CTYPE_DCDEMO {
            typeName = "DC차데모 "
        }
        if (self.totalChargerType & Const.CTYPE_DCCOMBO) == Const.CTYPE_DCCOMBO {
            typeName = typeName + "DC콤보 "
        }
        if (self.totalChargerType & Const.CTYPE_AC) == Const.CTYPE_AC {
            typeName = typeName + "AC3상 "
        }
        if (self.totalChargerType & Const.CTYPE_SLOW) == Const.CTYPE_SLOW {
            typeName = typeName + "완속 "
        }
        if (self.totalChargerType & Const.CTYPE_HYDROGEN) == Const.CTYPE_HYDROGEN {
            typeName = typeName + "수소연료자동차 "
        }
        if (self.totalChargerType & Const.CTYPE_SUPER_CHARGER) == Const.CTYPE_SUPER_CHARGER {
            typeName = typeName + "수퍼차저 "
        }
        if (self.totalChargerType & Const.CTYPE_DESTINATION) == Const.CTYPE_DESTINATION {
            typeName = typeName + "데스티네이션 "
        }
        return typeName
    }
    
    func getSelectIcon() -> UIImage {
        var markerIcon: UIImage!
        let isPay = (self.pay == "Y")
        let isCharging = (self.statusName == "충전중")
        let dbManager = DBManager.sharedInstance
        let companyArray = dbManager.getCompanyInfoList()
        if let company = companyArray.filter({$0.id!.elementsEqual(self.companyId)}).first {
            if let iconName = company.iconName {
                markerIcon = ImageMarker.marker(state: ImageMarker.markerHere, company: iconName, isCharging: isCharging, isPay: isPay)
            } else {
                markerIcon = ImageMarker.resizeMarker(path: ImageMarker.markerHere);
            }
        } else {
            markerIcon = ImageMarker.resizeMarker(path: ImageMarker.markerHere);
        }
        
        return markerIcon
    }
    
    func getMarkerIcon() -> UIImage {
        if (self.companyId.isEmpty) {
            return ImageMarker.NORMAL!;
        }
        
        var markerIcon: UIImage!
        if (statusName == "운영중지" || statusName == "점검중" || holiday == "Y") {
            markerIcon = ImageMarker.markers["marker_state_no_op_\(companyId)"]
        } else if (statusName == "충전중") {
            markerIcon = ImageMarker.markers["marker_state_charging_\(companyId)"]
        } else if (statusName == "통신미연결" || statusName == "기타(상태미확인)") {
            markerIcon = ImageMarker.markers["marker_state_no_connect_\(companyId)"]
        } else {
            markerIcon = ImageMarker.markers["marker_state_normal_\(companyId)"]
        }
        
        if markerIcon == nil {
            markerIcon = ImageMarker.NORMAL!;
        }
        
        return markerIcon;
    }
}

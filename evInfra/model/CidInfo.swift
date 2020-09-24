//
//  CidInfo.swift
//  evInfra
//
//  Created by bulacode on 2018. 3. 7..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation

class CidInfo {
    
    var cid: String?
    var chargerType: Int!
    var status: Int!
    var recentDate: String?
    var power: Int!
    init() {
    }
    
    init(cid: String, chargerType: Int, cst: String, recentDate: String, power:Int) {
        self.cid = cid
        self.chargerType = chargerType
        self.status = Int(cst)!
        self.recentDate = recentDate
        self.power = power
    }
    
    public func cstToString(cst:Int) -> String {
        var chargerState: String!
        switch (cst) {
            case Const.CHARGER_STATE_UNCONNECTED:
                chargerState = "통신미연결"
                break
            
            case Const.CHARGER_STATE_WAITING:
                chargerState = "대기중"
                break
            
            case Const.CHARGER_STATE_CHARGING:
                chargerState = "충전중"
                break
            
            case Const.CHARGER_STATE_INACTIVE:
                chargerState = "운영중지"
                break
            
            case Const.CHARGER_STATE_CHECKING:
                chargerState = "점검중"
                break
            
            case Const.CHARGER_STATE_BOOKING:
                chargerState = "예약중"
                break
            
            case Const.CHARGER_STATE_PILOT:
                chargerState = "시범운영중"
                break
            
            case Const.CHARGER_STATE_UNKNOWN:
                chargerState = "기타(상태미확인)"
                break
            
            default:
                chargerState = "통신미연결"
                break
        }
        return chargerState
    }
    
    public func getCstColor(cst:Int) -> UIColor{
        var cstColor: UIColor!
        switch (cst) {
            case Const.CHARGER_STATE_WAITING:
            cstColor = UIColor(rgb: 0x77BCE2)
            break
            
            case Const.CHARGER_STATE_CHARGING:
            cstColor = UIColor(rgb: 0x1BBA3C)
            break
            
            case Const.CHARGER_STATE_PILOT:
            cstColor = UIColor(rgb: 0xC9AFE3)
            break
            
            case Const.CHARGER_STATE_UNCONNECTED,
                 Const.CHARGER_STATE_UNKNOWN:
            cstColor = UIColor(rgb: 0xEDC44A)
            break
            
            default: // no operation, unknown
            cstColor = UIColor(rgb: 0xDE1A1A)
            break
        }
        return cstColor
    }

    public func getRecentDateSimple() -> String {
        var recentDateString = ""
        if let dateString = self.recentDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let date = dateFormatter.date(from: dateString) {
                dateFormatter.dateFormat = "yy.MM.dd \r\nHH:mm"
                recentDateString = dateFormatter.string(from: date)
            }
        }
        return recentDateString
    }
    
    public func getChargingDuration() -> String {
        var durationString = ""
        if let dateString = self.recentDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let date = dateFormatter.date(from: dateString) {
                durationString = Date().offsetFrom(date: date)
            }
        }
        
        if durationString.elementsEqual("") {
            durationString = "1분"
        }
        return durationString
    }
}

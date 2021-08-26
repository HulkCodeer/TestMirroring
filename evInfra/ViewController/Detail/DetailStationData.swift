//
//  DetailStationData.swift
//  evInfra
//
//  Created by SooJin Choi on 2021/08/26.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

class DetailStationData {
    var cidInfoList = [CidInfo]()
    var uTime:String = ""
    var op:String = ""
    var memo:String = ""
    var tel: String = ""
    var status:Int = -1
    
    func setStationInfo(jsonList : JSON) {
        let clist = jsonList["cl"]
        
        for (_, item):(String, JSON) in clist {
            let cidInfo = CidInfo.init(cid: item["cid"].stringValue, chargerType: item["tid"].intValue, cst: item["cst"].stringValue, recentDate: item["rdt"].stringValue, power: item["p"].intValue)
            print("csj_", "test", cidInfo.power)
            self.cidInfoList.append(cidInfo)
        }
        print("csj_", "cidInfo : ", self.cidInfoList.count)
        
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
        
        // 운영기관
        let stationOperator:String = jsonList["op"].stringValue
        var stationOp:String = ""
        if !stationOperator.isEmpty{
            if stationOperator.equalsIgnoreCase(compare: "") || stationOperator.equalsIgnoreCase(compare: "null"){
                stationOp = "기타"
            }else{
                stationOp = stationOperator
            }
        } else {
            stationOp = "기타"
        }
        print("csj_", "op : " + stationOp)
        self.op = stationOp
        
        // 이용시간
        let time = jsonList["ut"].stringValue
        var opTime:String = ""
        if !time.isEmpty {
            if time.equalsIgnoreCase(compare: "") || time.equalsIgnoreCase(compare: "null"){
                opTime = "등록된 정보가 없습니다."
            }else{
                opTime = time
            }
        } else {
            opTime = "등록된 정보가 없습니다."
        }
        self.uTime = opTime
        
        // 메모
        self.memo = jsonList["mm"].stringValue
    
        // 센터 전화번호
        let call = jsonList["tel"].stringValue
        var callStr:String = "등록된 정보가 없습니다."
        if !call.isEmpty {
            if !call.equalsIgnoreCase(compare: "") && !call.equalsIgnoreCase(compare: "null"){
                callStr = call
            }
        }
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
}

//
//  EIPOIItem.swift
//  evInfra
//
//  Created by Michael Lee on 2020/08/13.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
import HandyJSON
class EIPOIItem : HandyJSON {
    /*
    "id": "6504587",
                    "name": "이마트24 PDCC점",
                    "telNo": "",
                    "frontLat": "37.40216992",
                    "frontLon": "127.10087564",
                    "noorLat": "37.40247544",
                    "noorLon": "127.10123671",
                    "upperAddrName": "경기",
                    "middleAddrName": "성남시 분당구",
                    "lowerAddrName": "삼평동",
                    "detailAddrName": "",
                    "mlClass": "1",
                    "firstNo": "624",
                    "secondNo": "",
                    "roadName": "판교로",
                    "firstBuildNo": "242",
                    "secondBuildNo": "",
                    "radius": "0.482",
                    "bizName": "",
                    "upperBizName": "쇼핑",
                    "middleBizName": "대형유통점",
                    "lowerBizName": "편의점",
                    "detailBizName": "이마트24",
                    "rpFlag": "16",
                    "parkFlag": "0",
                    "detailInfoFlag": "0",
                    "desc": ""
     */
    required init() {}
    public var id : String?
    public var name : String?
    public var telNo : String?
    public var frontLat : Double?
    public var frontLon : Double?
    public var noorLat : Double?
    public var noorLon : Double?
    public var upperAddrName : String?
    public var middleAddrName : String?
    public var lowerAddrName : String?
    public var detailAddrName : String?
    public var mlClass : String?
    public var firstNo : String?
    public var secondNo : String?
    public var roadName : String?
    public var firstBuildNo : String?
    public var secondBuildNo : String?
    public var radius : String?
    public var bizName : String?
    public var upperBizName : String?
    public var middleBizName : String?
    public var lowerBizName : String?
    public var detailBizName : String?
    public var rpFlag : String?
    public var parkFlag : Int?
    public var detailInfoFlag : Int?
    public var desc: String?
    public var distance : String?

    public func getPOIName() -> String? {
        return self.name
    }
    public func getPOIAddress() -> String{
        var address = upperAddrName!
        if(StringUtils.isNullOrEmpty(middleAddrName) == false){
            address += " " + middleAddrName!
        }
        if(StringUtils.isNullOrEmpty(lowerAddrName) == false){
            address += " " + lowerAddrName!
        }
        if(StringUtils.isNullOrEmpty(roadName) == false){
            address += " " + roadName!
        }
        if(StringUtils.isNullOrEmpty(firstBuildNo) == false){
            address += " " + firstBuildNo!
        }
        return address
    }
    public func getPOIPoint() -> TMapPoint{
        return TMapPoint(lon: self.noorLon!, lat: self.noorLat!);
    }
}

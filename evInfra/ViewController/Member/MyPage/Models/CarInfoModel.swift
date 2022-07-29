//
//  CarInfoModel.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import SwiftyJSON

internal struct CarInfoListModel: ServerResultProtocol {
    var code: Int
    var msg: String
    var membId: String
    var body: [CarInfoModel]
        
    init(_ json: JSON){
        self.code = json["code"].intValue
        self.msg = json["msg"].stringValue
        self.membId = json["body"]["membId"].stringValue
        self.body = json["body"]["cars"].arrayValue.map { CarInfoModel($0) }
        
    }
}

struct CarInfoModel: ServerResultProtocol {
    var code: Int
    var msg: String
    var carNum: String
    var evType: String
    var mainCar: Bool
    var carType: Int
    
    var carOwner: String
    var appRegDate: Date
    
    var dpYes: DpYes
    var dpNo: DpNo
    var series: Series
    
    var dk: String
    
    init(_ json: JSON){
        self.code = json["code"].intValue
        self.msg = json["msg"].stringValue
        self.carNum = json["carNum"].stringValue
        self.evType = json["evType"].stringValue
        self.mainCar = json["mainCar"].boolValue
        self.carType = json["carType"].intValue
        self.carOwner = json["carOwner"].stringValue
        self.appRegDate = json["appRegDate"].dateValue
        self.dpYes = DpYes(json["dpYes"])
        self.dpNo = DpNo(json["dpNo"])
        self.series = Series(json["series"])
        
        self.dk = json["dk"].stringValue
    }
    
    struct DpYes {
        var carSep: String
        var img: String
        var btryCpcty: String
        var mdRep: String
        var mdSep: String
        var regDate: Date
        var cmpy: String
        
        init(_ json: JSON){
            self.carSep = json["carSep"].stringValue
            self.img = json["img"].stringValue
            self.btryCpcty = json["btryCpcty"].stringValue
            self.mdRep = json["mdRep"].stringValue
            self.mdSep = json["mdSep"].stringValue
            self.regDate = json["regDate"].dateValue
            self.cmpy = json["cmpy"].stringValue
        }
    }
    
    struct DpNo {
        var chrgFst: String
        var chrgSlw: String
        var btrSep: String
        var voltg: String
        var amphr: String
        var drvCpcty: String
        
        init(_ json: JSON){
            self.chrgFst = json["chrgFst"].stringValue
            self.chrgSlw = json["chrgSlw"].stringValue
            self.btrSep = json["btrSep"].stringValue
            self.voltg = json["voltg"].stringValue
            self.amphr = json["amphr"].stringValue
            self.drvCpcty = json["drvCpcty"].stringValue
        }
    }
    
    struct Series {
        var s1: SerieItem
        var s2: SerieItem
        var s3: SerieItem
        
        init(_ json: JSON){
            self.s1 = SerieItem(json["s1"])
            self.s2 = SerieItem(json["s2"])
            self.s3 = SerieItem(json["s3"])
        }
        
        struct SerieItem {
            var name: String
            var num: String
            
            init(_ json: JSON){
                self.name = json["name"].stringValue
                self.num = json["num"].stringValue
            }
        }
    }
}

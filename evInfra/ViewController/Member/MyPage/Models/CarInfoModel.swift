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
    var body: CarInfoModel
        
    init(_ json: JSON){
        self.code = json["code"].intValue
        self.msg = json["msg"].stringValue
        self.membId = json["body"]["membId"].stringValue
        self.body = json["body"]["cars"].arrayValue.map { CarInfoModel($0) }
        
    }
    
    struct CarInfoModel {
        var carNum: String
        var evType: String
        var mainCar: Bool
        var carType: Int
        
        var carOwner: String
        var appRegDate: Date
        
        var dpYes: DpYes
        
        var dk: String
        
        init(_ json: JSON){
            self.carNum = json["carNum"].stringValue
            self.evType = json["evType"].stringValue
            self.mainCar = json["mainCar"].boolValue
            self.carType = json["carType"].intValue
            self.carOwner = json["carOwner"].stringValue
            self.appRegDate = json["appRegDate"].dateValue
            self.dpYes = DpYes(json["dpYes"])
        }
        
        struct DpYes {
            var carSep: String
            var img: String
            var btryCpcty: String
            var mdRep: String
            var mdSep: String
            var regDate: String
            
            init(_ json: JSON){
                self.carSep = json["carSep"].stringValue
                self.img = json["img"].stringValue
                self.btryCpcty = json["btryCpcty"].boolValue
                self.mdRep = json["mdRep"].intValue
                self.mdSep = json["mdSep"].stringValue
                self.regDate = json["regDate"].dateValue
                
            }
        }
    }
}

//   "body":{
//      "memId":"103721",
//      "cars":[
//         {

//            "dpYes":{
//               "carSep":"SUV",
//               "img":"https://code2.car2b.com/data/_NewCarDB/FrontImage//20180725/5b57c692d0fe4_0.png",
//               "btryCpcty":"64",
//               "mdRep":"니로",
//               "mdSep":"니로 EV",
//               "regDate":"2018-09-06",
//               "pwrMax":"150",
//               "cpcty":"5.3",
//               "cmpy":"기아",
//               "brthY":"2019"
//            },
//            "dpNo":{
//               "chrgFst":"54분",
//               "chrgSlw":"",
//               "btrSep":"리튬이온",
//               "voltg":"356",
//               "amphr":"180",
//               "drvCpcty":"385"
//            },
//            "series":{
//               "s3":{
//                  "name":"",
//                  "num":"36559"
//               },
//               "s1":{
//                  "name":"노블레스",
//                  "num":"40634"
//               },
//               "s2":{
//                  "name":"노블레스",
//                  "num":"18008"
//               }
//            },
//            "dk":"95db8033-9933-47bd-9e30-5c5fc4735917"
//         },
//         {
//            "carNum":"TBD",
//            "evType":null,
//            "mainCar":false,
//            "carType":4,
//            "carOwner":null,
//            "appRegDate":"2022-06-14 21:12:17",
//            "dpYes":{
//               "carSep":null,
//               "img":"https://soft-berry.s3.ap-northeast-2.amazonaws.com/carImage/temporary_car_img.png",
//               "btryCpcty":"32.6",
//               "mdRep":"쿠퍼 SE",
//               "mdSep":"쿠퍼 SE",
//               "regDate":null,
//               "pwrMax":"135",
//               "cpcty":null,
//               "cmpy":"미니",
//               "brthY":null
//            },
//            "dpNo":{
//               "chrgFst":"",
//               "chrgSlw":"",
//               "btrSep":"리튬이온",
//               "voltg":"",
//               "amphr":""
//            },
//            "series":null,
//            "dk":"0102ed62-f935-4240-bde0-76225e195f31"
//         }
//      ]
//   }
//}

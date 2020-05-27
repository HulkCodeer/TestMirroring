//
//  CarModels.swift
//  evInfra
//
//  Created by zenky1 on 2018. 5. 11..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

class CarModels {
    
    struct CarModel {
        var id = 0
        var name = ""
        var type = Const.CHARGER_TYPE_ETC
    }
    
    private var arrayCarList = Array<CarModel>()
    
    init() {
        arrayCarList.removeAll()
    }
    
    func setData(json:JSON) {
        arrayCarList.removeAll()
        for (_, item):(String, JSON) in json["list"] {
            let carModel = CarModel(id: item["id"].intValue, name: item["model"].stringValue, type: 8)
            self.arrayCarList.append(carModel)
        }
    }
    
    func getCarList() -> Array<CarModel>{
        return self.arrayCarList
    }
    
    func getNameList() -> Array<String> {
        var arrayCarModel = Array<String>()
        for car in self.arrayCarList {
            arrayCarModel.append(car.name)
        }
        return arrayCarModel
    }
}

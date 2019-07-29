//
//  ChargerModel.swift
//  evInfra
//
//  Created by bulacode on 2018. 5. 9..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ChargerModel {
    var id: Int?
    var name: String?
    var ampare: String?
    var image: String?
    var current: String?
    var voltage: String?
    var vehicles: String?
    var level: String?
    
    init(json: JSON){
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.ampare = json["ampare"].stringValue
        self.image = json["image"].stringValue
        self.current = json["current"].stringValue
        self.voltage = json["voltage"].stringValue
        self.vehicles = json["vehicles"].stringValue
        self.level = json["level"].stringValue
        
    }
    
    
}

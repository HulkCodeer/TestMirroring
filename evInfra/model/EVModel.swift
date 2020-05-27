//
//  EVModel.swift
//  evInfra
//
//  Created by bulacode on 2018. 5. 2..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class EVModel {
    
    var id: Int?
    var name: String?
    var company: String?
    var image: String?
    var apes: String?
    var speed: String?
    var distance: String?
    var batt: String?
    var uiImage: UIImage?
    
    init(json: JSON){
        self.id = json["id"].intValue
        self.name = json["model"].stringValue
        self.company = json["company"].stringValue
        self.image = json["image"].stringValue
        self.apes = json["apes"].stringValue
        self.speed = json["speed"].stringValue
        self.distance = json["distance"].stringValue
        self.batt = json["batt"].stringValue
    }
}

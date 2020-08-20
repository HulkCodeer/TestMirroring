//
//  GeoRegion.swift
//  evInfra
//
//  Created by 임은주 on 2020/08/20.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

class GeoRegion{
	var charger_id:String
	var latitude:String
	var longitude:String
	var radius:String
	
	init(bJson: JSON) {
	   charger_id = bJson["charger_id"].stringValue
	   latitude = bJson["latitude"].stringValue
	   longitude = bJson["longitude"].stringValue
	   radius = bJson["radius"].stringValue
	}
}

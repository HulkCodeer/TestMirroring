//
//  WaitTimeModel.swift
//  evInfra
//
//  Created by 임은주 on 2020/09/22.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

class WaitTimeModel: Codable {
	var code:Int?
	var data:WaitTimeData?
}

class WaitTimeData: Codable{
	var status:[WaitTimeStatus] = []
	var user_count:Double?
}

class WaitTimeStatus: Codable {
	var cid:String?
	var company_id:String?
	var charger_list_id:String?
	var remain_time:Double?
}


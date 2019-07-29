//
//  TestCharger.swift
//  evInfra
//
//  Created by bulacode on 2018. 7. 19..
//  Copyright © 2018년 bulacode. All rights reserved.
//

import Foundation

class TestCharger{
    var marker : TMapMarkerItem!
    var cidInfo: CidInfo!
    var statusName: String = ""
    var charger: Charger? = nil
    struct Charger: Codable{
        var x: Double = 0 //longitude
        var y: Double = 0 // latitude
        
        var id: String = "" // charger id
        var co_id: String = "A" // compnay id
        
        var snm: String = "" // station Name
        var adr: String = "" // address
        
        var cst: String = "" // status
//
        
        var ctp: Int = 0 // type
        
        var skind: String = "" // skind
        var hol: String = "N"
        var pay: String = "N"
        var isPilot: String = "N" // 시범운영중
    }
    
    
    
    
    var isVisible: Bool = true // 화면에 나타날지 숨길지 판단
}

//
//  CommonManager.swift
//  evInfra
//
//  Created by bulacode on 2018. 5. 25..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChargerListManager {
    static let sharedInstance = ChargerListManager()
    private init() {
        
    }
    
    var chargerList: [Charger]? = nil
    var chargerDict = [String: Charger]()
    
    func getChargerFromChargerId(id: String) -> Charger? {
        if let charger = chargerList?.first(where: {$0.chargerId == id}) {
            return charger
        } else {
            return nil
        }
    }
    
    func getFavoriteCharger() {
        if MemberManager.getMbId() > 0 {
            Server.getFavoriteList { (isSuccess, value) in
                if isSuccess {
                    let json = JSON(value)
                    for (_, item):(String, JSON) in json {
                        let id = item["id"].stringValue
                        if let charger = self.chargerDict[id] {
                            charger.favorite = true
                            charger.favoriteAlarm = item["noti"].boolValue
                        }
                    }
                }
            }
        }
    }
    
    func setFavoriteCharger(charger: Charger, completion: ((Charger) -> Void)?) {
        if MemberManager.getMbId() > 0 {
            Server.setFavorite(chargerId: charger.chargerId, mode: !charger.favorite) { (isSuccess, value) in
                if isSuccess {
                    let json = JSON(value)
                    
                    let result = json["result"].stringValue
                    if result.elementsEqual("1000") {
                        charger.favorite = json["mode"].boolValue
                        charger.favoriteAlarm = true
                        
                        completion?(charger)
                    }
                }
            }
        }
    }
}

//
//  NewArticleChecker.swift
//  evInfra
//
//  Created by bulacode on 2018. 7. 23..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

class NewArticleChecker {
    
    static let sharedInstance = NewArticleChecker()
    
    var delegate: NewArticleCheckDelegate?
    var latestBoardIds = Array<Int>()
    
    private init() {
    }
    
    func checkLastBoardId() {
        Server.getLastBoardId { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let notice = json["notice"].intValue
                let station = json["station"].intValue
                let free = json["free"].intValue
                let event = json["event"].intValue
                
                self.latestBoardIds.removeAll()
                self.latestBoardIds.append(notice)
                self.latestBoardIds.append(free)
                self.latestBoardIds.append(station)
                self.latestBoardIds.append(event)
                
                let defaults = UserDefault()
                if (defaults.readInt(key: UserDefault.Key.LAST_NOTICE_ID) == 0) {
                    defaults.saveInt(key: UserDefault.Key.LAST_NOTICE_ID, value: notice)
                }
                if (defaults.readInt(key: UserDefault.Key.LAST_STATION_ID) == 0) {
                    defaults.saveInt(key: UserDefault.Key.LAST_STATION_ID, value: station)
                }
                if (defaults.readInt(key: UserDefault.Key.LAST_FREE_ID) == 0) {
                    defaults.saveInt(key:UserDefault.Key.LAST_FREE_ID, value: free)
                }
                if (defaults.readInt(key: UserDefault.Key.LAST_EVENT_ID) == 0) {
                    defaults.saveInt(key:UserDefault.Key.LAST_EVENT_ID, value: event)
                }
                
                self.delegate?.finishCheckArticleFromServer()
            }
        }
    }
}

//
//  SBDateFormat.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 18..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
class SBDateFormat {

    let dateFormatterGet = DateFormatter()
    let dataFormmaterForBoard = DateFormatter()
    let dataFormmaterForReply = DateFormatter()
    
    init() {
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dataFormmaterForBoard.dateFormat = "yyyy-MM-dd HH:mm"
        dataFormmaterForReply.dateFormat = "yyyy-MM-dd HH:mm"
    }
    
    func getBoardDateString(data:String) -> String {
        if let date: Date = dateFormatterGet.date(from: data) {
            return dataFormmaterForBoard.string(from: date)
        } else {
            return "-"
        }
    }
    
    func getBoardReplyString(data:String) -> String {
        if let date: Date = dateFormatterGet.date(from: data) {
            return dataFormmaterForReply.string(from: date)
        } else {
            return "-"
        }
    }
}

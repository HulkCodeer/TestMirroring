//
//  BoardData.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 23..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

class BoardData {

    // 게시판 카테고리
    public static let BOARD_CATEGORY_CHARGER   = "boardCharger"
    public static let BOARD_CATEGORY_FREE      = "boardFree"
    public static let BOARD_CATEGORY_NOTICE    = "boardNotice"
    public static let BOARD_CATEGORY_COMPANY   = "boardCompany"

    var boardId: Int?
    
    var chargerId: String?
    var stationName: String?
    var chargerType: String?
    
    var mbId: Int?
    var mbLevel = MemberManager.MB_LEVEL_NORMAL
    var nick: String?
    var profile_img: String?
    
    var date: String?
    var content: String?
    var content_img: String?
    
    var adId: Int = 0
    var adUrl: String?
    
    var reply: Array<ReplyData>?
    
    class ReplyData {
        var mbId: Int?
        var mbLevel = MemberManager.MB_LEVEL_NORMAL
        var nick: String?
        var profile_img: String?
        var replyId: Int?
        var content: String?
        var date: String?
        var chargerType: String?
        
        init(json: JSON) {
            mbId = json["rmb_id"].intValue
            mbLevel = json["rmb_level"].intValue
            nick = json["rnick_nm"].stringValue
            profile_img = json["rfile_nm"].stringValue
            replyId = json["reply_id"].intValue
            content = json["rcomment"].stringValue
            date = json["rdate"].stringValue
            chargerType = json["c_type"].stringValue
        }
    }
    
    init() {
        
    }
    
    init(bJson: JSON) {
        mbId = bJson["bmb_id"].intValue
        mbLevel = bJson["bmb_level"].intValue
        nick = bJson["bnick_nm"].stringValue
        date = bJson["bdate"].stringValue
        content = bJson["bcomment"].stringValue
        if bJson["bfile_nm"] != JSON.null {
            profile_img = bJson["bfile_nm"].stringValue
        } else {
            profile_img = nil
        }
        
        if bJson["charger_id"] != JSON.null {
            chargerId = bJson["charger_id"].stringValue
        } else {
            chargerId = nil
        }
        
        if bJson["file_name"] == JSON.null || bJson["has_image"] == 0 {
            content_img = nil
        } else {
            content_img = bJson["file_name"].stringValue
        }
        
        if bJson["snm"] != JSON.null {
            stationName = bJson["snm"].stringValue
        } else {
            stationName = nil
        }
        
        if bJson["ad_id"] != JSON.null {
            adId = bJson["ad_id"].intValue
        } else {
            adId = 0
        }
        
        if bJson["ad_url"] != JSON.null {
            adUrl = bJson["ad_url"].stringValue
        } else {
            adUrl = nil
        }
        
        boardId = bJson["board_id"].intValue
        chargerType = bJson["c_type"].stringValue
        
        let rJson = bJson["reply"]
        if (rJson == JSON.null || rJson.arrayValue.count == 0 || rJson.arrayValue[0]["reply_id"] == JSON.null) {
            reply = nil
        } else {
            reply = Array<ReplyData>()
            for json in rJson.arrayValue {
                let replyData = ReplyData(json: json)
                reply?.append(replyData)
            }
//            reply?.sort(by: {$0.replyId! > $1.replyId!}) // 서버에서 sorting해서 내려줌
        }
        
    }
}
//

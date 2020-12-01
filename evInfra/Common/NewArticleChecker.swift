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
    
    public static let KEY_NOTICE        = "notice" // 공지사항
    public static let KEY_FREE_BOARD    = "free" // 자유게시판
    public static let KEY_CHARGER_BOARD = "charger" // 충전소게시판
    public static let KEY_EVENT         = "event" // 이벤트
    public static let KEY_COMPANY       = "company_" // 사업자게시판
    
//    public static let KEY_GS            = 4 // GS
//    public static let KEY_JEJU          = 5 // JEJU
//    public static let KEY_AST           = 6 // AST
    

    // Key = company id(key), value = board id (Get last ID from each board)
    public static var latestBoardIds: Dictionary = [String:Int]()
    
    // Key = client name, value = company id (Get companyId using ClientName)
    public static var companyNameIdDict: Dictionary = [String:String]()
    
    // ClientName (For LeftVC_partnership board's setText)
    public static var companyList:Array = Array<String>()
    
    // CompanyId (For Check all menu(board) for new content)
    var companyIdList:Array = Array<String>()
    
    static let sharedInstance = NewArticleChecker()
    
    var delegate: NewArticleCheckDelegate?
    
    // 서버에서 새 brd id, companyId, clientName 받아와 저장.
    func checkLastBoardId() {
        Server.getBoardData { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].intValue == 1000 {
                    let latestId = JSON(json["latest_id"])
                    
                    NewArticleChecker.latestBoardIds.removeAll()
                    
                    for (key, value) in latestId {
                        print("key \(key) value2 \(value)")
                        NewArticleChecker.latestBoardIds.updateValue(value.intValue, forKey: key)
                        
                    }
                    
                    if let companyArr = json["company_list"].array {
                       for company in companyArr {
                            var companyId:String = company["company_id"].stringValue
                            let clientId:String = String(company["client_id"].intValue)
                            let brdId = company["brd_id"].intValue
                            let clientName:String = company["client_name"].stringValue
                        
                            // companyId 가 없을경우 KEY+clientId 로..
                            if companyId.isEmpty {
                                companyId = NewArticleChecker.KEY_COMPANY+clientId
                            }
                        
                            NewArticleChecker.latestBoardIds.updateValue(brdId, forKey: NewArticleChecker.KEY_COMPANY+companyId)
                        
                            NewArticleChecker.companyList.append(clientName)
                            
                            NewArticleChecker.companyNameIdDict.updateValue(companyId, forKey: clientName)
                            
                            self.companyIdList.append(companyId)
                       }
                     }
                }
            }
            self.delegate?.finishCheckArticleFromServer()
        }
    }
    
    // 전체 메뉴에 새 글이 있는지 확인
    // 기존에 봤던 board id  = UserDefault().readInt(KEY값)
    // 서버에서 받은 새 borad id = NewArticleChecker.latestBoardIds[KEY값]
    func hasNew() -> Bool {
        let noticeId = UserDefault().readInt(key: UserDefault.Key.LAST_NOTICE_ID)
        let freeId = UserDefault().readInt(key: UserDefault.Key.LAST_FREE_ID)
        let chargerId = UserDefault().readInt(key: UserDefault.Key.LAST_CHARGER_ID)
        let eventId = UserDefault().readInt(key: UserDefault.Key.LAST_EVENT_ID)
        
        let companyKey = UserDefault.Key.LAST_COMPANY
        for companyId in companyIdList {
            if UserDefault().readInt(key: companyKey+companyId) != 0{
                return UserDefault().readInt(key: companyKey+companyId) < NewArticleChecker.latestBoardIds[NewArticleChecker.KEY_COMPANY+companyId] ?? 0
            }
        }
        return noticeId < NewArticleChecker.latestBoardIds[NewArticleChecker.KEY_NOTICE] ?? 0
            || freeId < NewArticleChecker.latestBoardIds[NewArticleChecker.KEY_FREE_BOARD] ?? 0
            || chargerId < NewArticleChecker.latestBoardIds[NewArticleChecker.KEY_CHARGER_BOARD] ?? 0
            || eventId < NewArticleChecker.latestBoardIds[NewArticleChecker.KEY_EVENT] ?? 0
    }
    
    // 게시판에 새 글이 있는지 확인
    func hasNewBoard() -> Bool {
        let noticeId = UserDefault().readInt(key: UserDefault.Key.LAST_NOTICE_ID)
        let freeId = UserDefault().readInt(key: UserDefault.Key.LAST_FREE_ID)
        let chargerId = UserDefault().readInt(key: UserDefault.Key.LAST_CHARGER_ID)
        
        let companyKey = UserDefault.Key.LAST_COMPANY
        for companyId in companyIdList {
            if UserDefault().readInt(key: companyKey+companyId) != 0{
                return UserDefault().readInt(key: companyKey+companyId) < NewArticleChecker.latestBoardIds[NewArticleChecker.KEY_COMPANY+companyId] ?? 0
            }
        }
        return noticeId < NewArticleChecker.latestBoardIds[NewArticleChecker.KEY_NOTICE] ?? 0
            || freeId < NewArticleChecker.latestBoardIds[NewArticleChecker.KEY_FREE_BOARD] ?? 0
            || chargerId < NewArticleChecker.latestBoardIds[NewArticleChecker.KEY_CHARGER_BOARD] ?? 0
    }
}

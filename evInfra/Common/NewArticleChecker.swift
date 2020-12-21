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
    
    public static let KEY_NOTICE        = 0 // 공지사항
    public static let KEY_FREE_BOARD    = 1 // 자유게시판
    public static let KEY_CHARGER_BOARD = 2 // 충전소게시판
    public static let KEY_EVENT         = 3 // 이벤트
    
    static let sharedInstance = NewArticleChecker()
    
    var delegate: NewArticleCheckDelegate?
    var latestBoardIds: Dictionary = [Int:Int]()
    
    private init() {
    }

    func checkLastBoardId() {
        Server.getBoardData { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].intValue == 1000 {
                    let latestId = JSON(json["latest_id"])
                    self.latestBoardIds.removeAll()
                    self.latestBoardIds[NewArticleChecker.KEY_NOTICE] = latestId["notice"].intValue
                    self.latestBoardIds[NewArticleChecker.KEY_FREE_BOARD] = latestId["free"].intValue
                    self.latestBoardIds[NewArticleChecker.KEY_CHARGER_BOARD] = latestId["charger"].intValue
                    self.latestBoardIds[NewArticleChecker.KEY_EVENT] = latestId["event"].intValue
                }
            }
            self.delegate?.finishCheckArticleFromServer()
        }
    }
    
    // 전체 메뉴에 새 글이 있는지 확인
    func hasNew() -> Bool {
        let noticeId = UserDefault().readInt(key: UserDefault.Key.LAST_NOTICE_ID)
        let freeId = UserDefault().readInt(key: UserDefault.Key.LAST_FREE_ID)
        let chargerId = UserDefault().readInt(key: UserDefault.Key.LAST_CHARGER_ID)
        let eventId = UserDefault().readInt(key: UserDefault.Key.LAST_EVENT_ID)
        
        return noticeId < latestBoardIds[NewArticleChecker.KEY_NOTICE] ?? 0
            || freeId < latestBoardIds[NewArticleChecker.KEY_FREE_BOARD] ?? 0
            || chargerId < latestBoardIds[NewArticleChecker.KEY_CHARGER_BOARD] ?? 0
            || eventId < latestBoardIds[NewArticleChecker.KEY_EVENT] ?? 0
    }
    
    // 게시판에 새 글이 있는지 확인
    func hasNewBoard() -> Bool {
        let noticeId = UserDefault().readInt(key: UserDefault.Key.LAST_NOTICE_ID)
        let freeId = UserDefault().readInt(key: UserDefault.Key.LAST_FREE_ID)
        let chargerId = UserDefault().readInt(key: UserDefault.Key.LAST_CHARGER_ID)
        
        return noticeId < latestBoardIds[NewArticleChecker.KEY_NOTICE] ?? 0
            || freeId < latestBoardIds[NewArticleChecker.KEY_FREE_BOARD] ?? 0
            || chargerId < latestBoardIds[NewArticleChecker.KEY_CHARGER_BOARD] ?? 0
    }
}

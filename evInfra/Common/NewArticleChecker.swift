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
    var freeBoardId:Int = 0
    var chargeBoardId:Int = 0
    
    var brdNewInfo:Array<BoardNewInfo> = Array<BoardNewInfo>()
    
    private init() {
    }

    func checkLastBoardId() {
        Server.getBoardData { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].intValue == 1000 {
                    let latestId = JSON(json["latest_id"])
                    
                    self.latestBoardIds.removeAll()
                    
                    self.freeBoardId = latestId["free"].intValue
                    self.chargeBoardId = latestId["charger"].intValue
                    
                    self.latestBoardIds[NewArticleChecker.KEY_NOTICE] = latestId["notice"].intValue
                    self.latestBoardIds[NewArticleChecker.KEY_FREE_BOARD] = self.freeBoardId
                    self.latestBoardIds[NewArticleChecker.KEY_CHARGER_BOARD] = self.chargeBoardId
                    self.latestBoardIds[NewArticleChecker.KEY_EVENT] = latestId["event"].intValue
                    
                    let companyList = JSON(json["company_list"])
                    let companyArr = companyList.arrayValue

                    var boardNewInfoList = self.getBoardNewInfoList()
                    for company in companyArr {
                        let boardNewInfo = BoardNewInfo()
                        
                        let companyId = company["company_id"].stringValue
                        let bmId = company["bm_id"].intValue
                        let boardTitle = company["bm_board_title"].stringValue
                        let shardKey = company["bm_shared_key"].stringValue
                        let brdId = company["brd_id"].intValue
                        
                        boardNewInfo.companyId = companyId
                        boardNewInfo.bmId = bmId
                        boardNewInfo.boardTitle = boardTitle
                        boardNewInfo.shardKey = shardKey
                        boardNewInfo.brdId = brdId
                        
                        boardNewInfoList.append(boardNewInfo)
                        self.brdNewInfo.append(boardNewInfo)
                    }
                }
                self.delegate?.finishCheckArticleFromServer()
            }
        }
    }
    
    public func getBoardNewInfoList() -> Array<BoardNewInfo> {
        return brdNewInfo
    }
    
    public func getBoardTitleList() -> Array<String>? {
        var titleList:Array<String> = Array<String>()
        if !brdNewInfo.isEmpty {
            for newInfo:BoardNewInfo in brdNewInfo {
                titleList.append(newInfo.boardTitle ?? "사업자 게시판")
            }
            return titleList
        }else{
            return nil
        }
    }
    
    public func getBoardNewInfo(title:String) -> BoardNewInfo? {
        for newInfo in brdNewInfo {
            if title.equals(newInfo.boardTitle ?? "") {
                return newInfo
            }
        }
        return nil
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
            || eventId < latestBoardIds[NewArticleChecker.KEY_EVENT] ?? 0 || checkNewCompanyId()
    }
    
    // 게시판에 새 글이 있는지 확인
    func hasNewBoard() -> Bool {
        let noticeId = UserDefault().readInt(key: UserDefault.Key.LAST_NOTICE_ID)
        let freeId = UserDefault().readInt(key: UserDefault.Key.LAST_FREE_ID)
        let chargerId = UserDefault().readInt(key: UserDefault.Key.LAST_CHARGER_ID)
        
        return noticeId < latestBoardIds[NewArticleChecker.KEY_NOTICE] ?? 0
            || freeId < latestBoardIds[NewArticleChecker.KEY_FREE_BOARD] ?? 0
            || chargerId < latestBoardIds[NewArticleChecker.KEY_CHARGER_BOARD] ?? 0 || checkNewCompanyId()
    }
    
    func checkNewCompanyId() -> Bool {
        if !brdNewInfo.isEmpty {
            for boardNewInfo:BoardNewInfo in brdNewInfo {
                let latestCompanyId:Int = boardNewInfo.brdId ?? -1
                let companyId = UserDefault().readInt(key: boardNewInfo.shardKey ?? "")
                if latestCompanyId > companyId {
                    return true
                }
            }
        }
        return false
    }
}

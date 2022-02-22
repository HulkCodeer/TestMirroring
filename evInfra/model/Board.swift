//
//  NewArticleChecker.swift
//  evInfra
//
//  Created by bulacode on 2018. 7. 23..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol BoardDelegate {
    func complete()
}

class Board {
    // Top Menu 타입
    enum SortType: String, CaseIterable {
        case LATEST = "0"
        case FAVORITE = "1"
        case TOP = "2"
    }
    
    // 스크린 타입
    enum ScreenType: String {
        case LIST = "1"
        case FEED = "2"
        case GALLERY = "3"
    }
    
    // 검색 타입
    enum SearchType: String {
        case TITLE_WITH_CONTENT = "title"
        case NICK_NAME = "nick_name"
        case MBID = "mb_id"
        case STATION = "station"
        
        var index: Int {
            switch self {
                case .TITLE_WITH_CONTENT: return 0
                case .NICK_NAME: return 1
                case .MBID: return 2
                case .STATION: return 3
            }
        }
        
        static func getSearchType(index: Int) -> String {
            var text: String = SearchType.TITLE_WITH_CONTENT.rawValue

            CommunityType.allCases.forEach {
                if $0.index == index {
                    text = $0.rawValue
                }
            }

            return text
        }
    }
    
    // 게시판 타입
    enum CommunityType: String, CaseIterable {
        case CHARGER = "station"
        case FREE = "free"
        case NOTICE = "notice"
        case CORP_GS = "corp_gs"
        case CORP_JEV = "corp_jev"
        case CORP_STC = "corp_stc"
        case CORP_SBC = "corp_sbc"
        
        var index: Int {
            switch self {
                case .CHARGER: return -1
                case .FREE: return -1
                case .NOTICE: return -1
                case .CORP_GS: return 0
                case .CORP_JEV: return 1
                case .CORP_STC: return 2
                case .CORP_SBC: return 3
            }
        }

        static func getCompanyType(index: Int) -> String {
            var text: String = CommunityType.CORP_GS.rawValue

            CommunityType.allCases.forEach {
                if $0.index == index {
                    text = $0.rawValue
                }
            }

            return text
        }
    }

    // 게시판 카테고리
    public static let BOARD_CATEGORY_CHARGER   = "station"
    public static let BOARD_CATEGORY_FREE      = "free"
    public static let BOARD_CATEGORY_NOTICE    = "boardNotice"
//    public static let BOARD_CATEGORY_COMPANY: CompanyType = .CORP_GS

    public static let KEY_NOTICE        = 0 // 공지사항
    public static let KEY_FREE_BOARD    = 1 // 자유게시판
    public static let KEY_CHARGER_BOARD = 2 // 충전소게시판
    public static let KEY_EVENT         = 3 // 이벤트
    
    static let sharedInstance = Board()
    
    var delegate: BoardDelegate?
    
    var latestBoardIds: Dictionary = [Int:Int]()
    var freeBoardId:Int = 0
    var chargeBoardId:Int = 0
    
    var brdNewInfo:Array<BoardInfo> = Array<BoardInfo>()
    
    private init() {
    }

    func checkLastBoardId() {
        Server.getBoardData { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].intValue == 1000 {
                    print(json)
                    let latestId = JSON(json["latest_id"])
                    
                    self.latestBoardIds.removeAll()
                    
                    self.freeBoardId = latestId["free"].intValue
                    self.chargeBoardId = latestId["charger"].intValue
                    
                    self.latestBoardIds[Board.KEY_NOTICE] = latestId["notice"].intValue
                    self.latestBoardIds[Board.KEY_FREE_BOARD] = self.freeBoardId
                    self.latestBoardIds[Board.KEY_CHARGER_BOARD] = self.chargeBoardId
                    self.latestBoardIds[Board.KEY_EVENT] = latestId["event"].intValue
                    
                    let companyArr = JSON(json["company_list"]).arrayValue
                    for company in companyArr {
                        let boardNewInfo = BoardInfo()
                        
                        let bmId = company["bm_id"].intValue
                        let boardTitle = company["title"].stringValue
                        let shardKey = company["key"].stringValue
                        let brdId = company["brd_id"].intValue
                        
                        boardNewInfo.bmId = bmId
                        boardNewInfo.boardTitle = boardTitle
                        boardNewInfo.shardKey = shardKey
                        boardNewInfo.brdId = brdId
                        
                        self.brdNewInfo.append(boardNewInfo)
                    }
                }
                if let delegate = self.delegate {
                    delegate.complete()
                }
            }
        }
    }
    
    public func getBoardTitleList() -> Array<String> {
        var titleList:Array<String> = Array<String>()
        if !brdNewInfo.isEmpty {
            for newInfo:BoardInfo in brdNewInfo {
                titleList.append(newInfo.boardTitle ?? "사업자 게시판")
            }
        }
        return titleList
    }
    
    public func getBoardNewInfo(title:String) -> BoardInfo? {
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
        
        return noticeId < latestBoardIds[Board.KEY_NOTICE] ?? 0
            || freeId < latestBoardIds[Board.KEY_FREE_BOARD] ?? 0
            || chargerId < latestBoardIds[Board.KEY_CHARGER_BOARD] ?? 0
            || eventId < latestBoardIds[Board.KEY_EVENT] ?? 0 || checkNewCompanyId()
    }
    
    // 게시판에 새 글이 있는지 확인
    func hasNewBoard() -> Bool {
        let noticeId = UserDefault().readInt(key: UserDefault.Key.LAST_NOTICE_ID)
        let freeId = UserDefault().readInt(key: UserDefault.Key.LAST_FREE_ID)
        let chargerId = UserDefault().readInt(key: UserDefault.Key.LAST_CHARGER_ID)
        
        return noticeId < latestBoardIds[Board.KEY_NOTICE] ?? 0
            || freeId < latestBoardIds[Board.KEY_FREE_BOARD] ?? 0
            || chargerId < latestBoardIds[Board.KEY_CHARGER_BOARD] ?? 0 || checkNewCompanyId()
    }
    
    func checkNewCompanyId() -> Bool {
        if !brdNewInfo.isEmpty {
            for boardNewInfo:BoardInfo in brdNewInfo {
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

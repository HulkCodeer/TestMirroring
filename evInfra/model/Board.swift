//
//  NewArticleChecker.swift
//  evInfra
//
//  Created by bulacode on 2018. 7. 23..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

internal final class Board {
    static let sharedInstance = Board()
    
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
    enum SearchType: String, CaseIterable {
        case TITLE_WITH_CONTENT = "title|content"
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

            SearchType.allCases.forEach {
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
        
        var shardKey: String {
            switch self {
                case .CHARGER: return ""
                case .FREE: return "free"
                case .NOTICE: return "notice"
                case .CORP_GS: return "company_gs"
                case .CORP_JEV: return "company_jeju"
                case .CORP_STC: return "company_st"
                case .CORP_SBC: return "company_ev_infra"
            }
        }
        
        static func convertToEventKey(communityType: CommunityType) -> Promotion.Page {
            switch communityType {
            case .CHARGER: return .charging
            case .FREE: return .free
            case .NOTICE: return .notice
            case .CORP_GS: return .gsc
            case .CORP_JEV: return .jeju
            case .CORP_STC: return .est
            case .CORP_SBC: return .evinra
            }
        }

        static func getCompanyType(key: String) -> CommunityType {
            var type: CommunityType = .CORP_GS

            CommunityType.allCases.forEach {
                if $0.shardKey == key {
                    type = $0
                }
            }

            return type
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
    
    var delegate: BoardDelegate?
    
    var latestBoardIds: Dictionary = [Int:Int]()
    var freeBoardId:Int = 0
    var chargeBoardId:Int = 0
    
    var brdNewInfo:Array<BoardInfo> = Array<BoardInfo>()
    
    private init() {
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

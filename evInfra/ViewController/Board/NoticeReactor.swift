//
//  NoticeReactor.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/05/26.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import SwiftyJSON

internal final class NoticeReactor: ViewModel, Reactor {
    enum Action {
        case none
    }
    
    enum Mutation {
        case setNoticeList([Notice])
        case none
    }
    
    struct State {
        var noticeList: [Notice]?
    }
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    struct NoticeInfo {
        let code: Int
        let list: [Notice]
        
        init(_ json: JSON) {
            self.code = json["code"].intValue
            self.list = [Notice(json["list"])]
        }
    }
    
    struct Notice: Codable {
        let id: String
        let title: String
        let datetime: String
        
        init(_ json: JSON) {
            self.id = json["id"].stringValue
            self.title = json["title"].stringValue
            self.datetime = json["datetime"].stringValue
        }
    }
    
    /*
    func mutate(action: Action) -> Observable<Action> {
        switch action {
        case .none:
            printLog("공지사항 데이터 가져오기")
            return
        }
    }
    */
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.noticeList = nil
        
        switch mutation {
        case .setNoticeList(let noticeList):
            newState.noticeList = noticeList
        case .none: break
        }
        
        return newState
    }
}

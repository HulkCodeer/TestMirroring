//
//  NoticeDetailReactor.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/29.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

import ReactorKit
import RxSwift

internal final class NoticeDetailReactor: ViewModel, Reactor {
    typealias Contents = (title: String, date: String, html: String)
    enum Action {
        case loadHTML
    }
    
    enum Mutation {
        case setHTML(Contents)
    }
    
    struct State {
        var title: String = "[공지]"
        var date: String = Date().toStringToMinute(data: "yyyy.MM.dd")
        var html: String = String()
    }
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadHTML:
            return Observable.empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setHTML(let contents):
            newState.title = contents.title
            newState.date = contents.date
            newState.html = contents.html
        }
        
        return newState
    }
    
}

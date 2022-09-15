//
//  NoticeCellReactor.swift
//  evInfra
//
//  Created by youjin kim on 2022/09/07.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import ReactorKit

final class NoticeCellReactor: Reactor {
    enum Action {
        case moveDetailView
    }
    
    enum Mutation {
        case moveDetail
    }
    
    struct State {
        let title: String
        let date: String
        
        var isMoveDetail: Bool?
    }
        
    internal var initialState: State
            
    init(title: String, date: String) {
        self.initialState = State(title: title, date: date)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .moveDetailView:
            return Observable.just(.moveDetail)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .moveDetail:
            newState.isMoveDetail = true
        }
        
        return newState
    }
    
}

//
//  NoticeReactor.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/30.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

import ReactorKit
import RxSwift

final class NoticeReactor: ViewModel, Reactor {
    enum Action {
    }
    
    enum Mutation {
    }
    
    struct State {
        
    }
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {

    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        return newState
    }
}

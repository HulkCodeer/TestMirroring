//
//  AdsReactor.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/08/02.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit

internal final class AdsReactor: ViewModel, Reactor {
    enum Action {
        case none
    }
    
    enum Mutation {
        case none
    }
    
    struct State {
    }
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .none: return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .none: break
        }
        
        return newState
    }
}

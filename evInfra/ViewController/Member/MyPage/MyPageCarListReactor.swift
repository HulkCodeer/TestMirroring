//
//  MyPageCarListReactor.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit

internal final class MyPageCarListReactor: ViewModel, Reactor {
    enum Action {
        case loadData
    }
    
    enum Mutation {
        case none
    }
    
    struct State {
        var sections = [MyCarListSectionModel]()
    }
        
    internal var initialState: State
            
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData:
            return .just(.none)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        return newState
    }
}

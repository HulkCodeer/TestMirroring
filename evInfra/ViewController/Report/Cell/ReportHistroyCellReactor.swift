//
//  ReportHistroyCellReactor.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/06/29.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit

internal final class ReportHistoryCellReactor<T: Equatable>: Reactor, Equatable {
    enum Action {
        case none
    }
    
    enum Mutation {
        case none
    }
    
    struct State {
        var model: T
    }
    
    var initialState: State
    
    init(model: T) {
        defer { _ = self.state }
        self.initialState = State(model: model)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .none:
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        let newState = state
        return newState
    }
    
    static func == (lhs: ReportHistoryCellReactor<T>, rhs: ReportHistoryCellReactor<T>) -> Bool {
        lhs.initialState.model == rhs.initialState.model
    }
}

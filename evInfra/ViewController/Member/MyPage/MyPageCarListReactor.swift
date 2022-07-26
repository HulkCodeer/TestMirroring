//
//  MyPageCarListReactor.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class MyPageCarListReactor: Reactor {
    enum Action {
        case moveCarRegisterView
    }
    
    enum Mutation {        
        case setMoveCarRegisterView
    }
    
    struct State {
        var carInfoModel: CarInfoModel = CarInfoModel(JSON.null)
        var isMove: Bool?
    }
        
    internal var initialState: State
            
    init(model: CarInfoModel) {
        self.initialState = State(carInfoModel: model)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .moveCarRegisterView:
            return .just(.setMoveCarRegisterView)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.isMove = nil
        
        switch mutation {
        case .setMoveCarRegisterView:
            newState.isMove = true
        }
        
        return newState
    }
}

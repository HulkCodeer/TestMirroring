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
        case loadData
    }
    
    enum Mutation {
        case none
    }
    
    struct State {
        var carInfoModel: CarInfoListModel.CarInfoModel = CarInfoListModel.CarInfoModel(JSON.null)
    }
        
    internal var initialState: State
            
    init(model: CarInfoListModel.CarInfoModel) {
        self.initialState = State(carInfoModel: model)
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

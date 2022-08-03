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
        case moveCarInfoView
        case setChangeMainCar
    }
    
    enum Mutation {
        case setChangeMainCar
        case none
    }
    
    struct State {
        var carInfoModel: CarInfoModel = CarInfoModel(JSON.null)
        
        var isChangeMainCar: Bool?
    }
        
    internal var initialState: State
    
    
            
    init(model: CarInfoModel) {
        self.initialState = State(carInfoModel: model)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .moveCarRegisterView:            
            let reactor = CarRegistrationReactor(provider: RestApi())
            reactor.fromViewType = .mypageAdd
            let viewcon = CarRegistrationViewController()
            viewcon.reactor = reactor
            GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
            
            return .empty()
            
        case .moveCarInfoView:
            let reactor = CarRegistrationCompleteReactor(model: currentState.carInfoModel)
            reactor.fromViewType = .mypageInfo
            let viewcon = CarRegistrationCompleteViewController()
            viewcon.reactor = reactor
            GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
            
            return .empty()
            
        case .setChangeMainCar:
            return .just(.setChangeMainCar)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.isChangeMainCar = nil
                        
        switch mutation {
        case .setChangeMainCar:
            newState.isChangeMainCar = true
            
        case .none: break
        }
        
        return newState
    }
}

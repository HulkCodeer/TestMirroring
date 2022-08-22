//
//  NewPaymentStatusReactor.swift
//  evInfra
//
//  Created by 박현진 on 2022/08/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class PaymentStatusReactor: ViewModel, Reactor {
    enum Action {
        case chronometerStop
        case setChargePower(String)
    }
    
    enum Mutation {
        case setChronometerRunning(Bool)
        case setChargePower(String)
    }
    
    struct State {
        var isChronometerRunning: Bool?
        var chargePower: String?
    }
    
    internal var initialState: State
       
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .chronometerStop:
            return .just(.setChronometerRunning(false))
            
        case .setChargePower(let chargePower):
            return .just(.setChargePower(chargePower))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isChronometerRunning = nil
        newState.chargePower = nil
        
        switch mutation {
        case .setChronometerRunning(let isCronMeterRunning):
            newState.isChronometerRunning = isCronMeterRunning
            
        case .setChargePower(let chargePower):
            newState.chargePower = chargePower
        }
        
        return newState
    }
}

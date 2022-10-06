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
    typealias Action = NoAction
    typealias Mutation = NoMutation
            
    struct State {
        var isChronometerRunning: Bool?
    }
    
    internal var initialState: State
       
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }        
}

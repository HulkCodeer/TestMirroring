//
//  EventDetailReactor.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/09/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class EventDetailReactor: Reactor {
   
    typealias Action = NoAction
    typealias Mutation = NoMutation
    
    struct State {
        var adsInfo: AdsInfo = AdsInfo(JSON.null)
    }
    
    internal var initialState: State
    
    init(model: AdsInfo) {
        self.initialState = State(adsInfo: model)
    }
}

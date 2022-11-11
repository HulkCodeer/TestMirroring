//
//  PermissionsGuideReactor.swift
//  evInfra
//
//  Created by 박현진 on 2022/09/01.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit

protocol PermissionGuideDelegate: AnyObject {
    func presentMainView()
}

internal final class PermissionsGuideReactor: ViewModel, Reactor {
    enum Action {
        case requestLocation
    }
    
    enum Mutation {
        case setRunnigQRReaderView(Bool)
    }
    
    struct State {
        var isQRScanRunning: Bool?
    }
    
    internal weak var delegate: PermissionGuideDelegate?
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestLocation:
            delegate?.presentMainView()
            return .just(.setRunnigQRReaderView(false))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isQRScanRunning = nil
        
        switch mutation {
        case .setRunnigQRReaderView(let isRunning):
            newState.isQRScanRunning = isRunning
            return newState
        }
    }
}

//
//  PermissionsGuideReactor.swift
//  evInfra
//
//  Created by 박현진 on 2022/09/01.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import ReactorKit


protocol PermissionGuideDelegate: AnyObject {
    func presentMainView()
}

internal final class PermissionsGuideReactor: ViewModel, Reactor {
    enum Action {
        case requestLocation
        case moveToMain(Bool)
    }
    
    enum Mutation {
        case setRunnigQRReaderView(Bool)
        case moveToMain(Bool)
    }
    
    struct State {
        var isQRScanRunning: Bool?
        var canMoveMain: Bool?
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
            
        case .moveToMain(let canMoveMain):
            return .just(.moveToMain(canMoveMain))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isQRScanRunning = nil
        newState.canMoveMain = nil
        
        switch mutation {
        case .setRunnigQRReaderView(let isRunning):
            newState.isQRScanRunning = isRunning
                    
        case .moveToMain(let canMoveMain):
            newState.canMoveMain = canMoveMain
        }
        
        return newState
    }
}

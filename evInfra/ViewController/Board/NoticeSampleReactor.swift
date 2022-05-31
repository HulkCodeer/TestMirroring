//
//  NoticeSampleReactor.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/26.
//  Copyright © 2022 soft-berry. All rights reserved.
//
/*
import Foundation
import ReactorKit
import RxCocoa
import RxSwift
import SwiftyJSON

internal final class NewAccountListReactor: ViewModel, Reactor {
    enum Action {
        case loadData
    }
    
    enum Mutation {
        case setList([TestListItem])
    }
    
    struct State {
        var sections = [TestListSectionModel]()
    }
        
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData:
            return .just(.setList([TestListItem]))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.sections = nil
        switch mutation {
        case .setAccount(let items):
            newState.sections = [TestListSectionModel(items: items)]
                        
        }
        return newState
    }
}
*/

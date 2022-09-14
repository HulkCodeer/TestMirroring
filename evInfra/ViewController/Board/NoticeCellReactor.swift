//
//  NoticeCellReactor.swift
//  evInfra
//
//  Created by youjin kim on 2022/09/07.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import ReactorKit

final class NoticeCellReactor: Reactor {
    enum Action {
        case moveDetailView
    }
    
    enum Mutation {
        case setDetailID(Int)
    }
    
    struct State {
        let noticeID: Int
    }
        
    internal var initialState: State
            
    init(noticeID: Int) {
        self.initialState = State(noticeID: noticeID)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .moveDetailView:
            let reactor = NoticeDetailReactor(
                provider: RestApi(),
                noticeID: currentState.noticeID)
            let detailVC = NewNoticeDetailViewController(reactor: reactor)
            GlobalDefine.shared.mainNavi?.push(viewController: detailVC)
            
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
    
}

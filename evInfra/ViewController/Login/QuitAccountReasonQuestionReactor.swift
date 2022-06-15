//
//  QuitAccountReasonQuestionReactor.swift
//  evInfra
//
//  Created by 박현진 on 2022/06/15.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class QuitAccountReasonQuestionReactor: ViewModel, Reactor {
    enum Action {
        case none
    }
    
    enum Mutation {
        case none
    }
    
    struct State {
        var isBasicNotification: Bool?
        var isLocalNotification: Bool?
        var isMarketingNotification: Bool?
    }
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .none:
            return .just(.none)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.isBasicNotification = nil
        newState.isLocalNotification = nil
        newState.isMarketingNotification = nil
        
        switch mutation {        
            
        case .none: break
        }
        return newState
    }
    
    private func convertToData(with result: ApiResult<Data, ApiErrorMessage> ) -> Bool? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            
            let code = jsonData["code"].stringValue
            guard "1000".equals(code) else {
                return nil
            }
            
            return jsonData["receive"].boolValue
            
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            return nil
        }
    }
}

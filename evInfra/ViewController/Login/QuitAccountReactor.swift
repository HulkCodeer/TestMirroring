//
//  QuitAccountReactor.swift
//  evInfra
//
//  Created by 박현진 on 2022/06/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class QuitAccountReactor: ViewModel, Reactor {
    enum Action {
        case none
    }
    
    enum Mutation {
        case none
    }
    
    struct State {
        var quitAccountReasonList: [QuitAccountReasonModel]?
    }
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .none:
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.quitAccountReasonList = nil
        
        switch mutation {
        case .none:
            break
                    
        }
        return newState
    }
    
    private func convertToData(with result: ApiResult<Data, ApiErrorMessage> ) -> [QuitAccountReasonModel]? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            
            let code = jsonData["code"].stringValue
            guard "1000".equals(code) else {
                return nil
            }
            
            return jsonData["list"].arrayValue.map { QuitAccountReasonModel($0) }
            
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            
//            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//                GlobalDefine.shared.mainNavi?.pop()
//            })
            return nil
        }
    }
}

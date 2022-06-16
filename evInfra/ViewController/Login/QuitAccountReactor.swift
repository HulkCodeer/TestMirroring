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
        case deleteAppleAccount
        case deleteKakaoAccount
    }
    
    enum Mutation {
        case setComplete(Bool)
    }
    
    struct State {
        var isComplete: Bool?
    }
    
    internal var initialState: State
    internal var reasonID: String = ""
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .deleteAppleAccount:
            guard !self.reasonID.isEmpty else { return .empty()}
            return self.provider.deleteAppleAccount(reasonID: self.reasonID)
                            .convertData()
                            .compactMap(convertToData)
                            .map { isComplete in
                                return .setComplete(isComplete)
                            }
            
        case .deleteKakaoAccount:
            guard !self.reasonID.isEmpty else { return .empty()}
            return self.provider.deleteKakaoAccount(reasonID: self.reasonID)
                .convertData()
                .compactMap(convertToData)
                .map { isComplete in
                    return .setComplete(isComplete)
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.isComplete = nil
        
        switch mutation {
        case .setComplete(let isComplete):
            newState.isComplete = isComplete
                                                    
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
                Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
                return nil
            }
            
            return true
            
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
            return nil
        }
    }
}

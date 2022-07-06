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
        case getQuitAccountReasonList
    }
    
    enum Mutation {
        case setQuitAccountReasonList([QuitAccountReasonModel])
    }
    
    struct State {
        var quitAccountReasonList: [QuitAccountReasonModel]?
    }
    
    internal var initialState: State
    internal var selectedReasonIndex: Int = 0
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .getQuitAccountReasonList:
            return self.provider.getQuitAccountReasonList()
                .convertData()
                .compactMap(convertToData)
                .map { reasonList in
                    return .setQuitAccountReasonList(reasonList)
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.quitAccountReasonList = nil
        
        switch mutation {        
        case .setQuitAccountReasonList(let reasonList):
            newState.quitAccountReasonList = reasonList
                    
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
            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
            return nil
        }
    }
}

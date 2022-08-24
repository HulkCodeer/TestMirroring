//
//  MembershipReissuanceInfoReactor.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/05/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import SwiftyJSON

internal final class MembershipReissuanceInfoReactor: ViewModel, Reactor {
    enum Action {
        case setReissuance(ReissuanceModel)
    }
    
    enum Mutation {
        case setCompleteReissuance(ServerResult)
        case none
    }
    
    struct State {
        var serverResult: ServerResult?
    }
    
    internal var initialState: State
    internal var cardNo: String = ""
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setReissuance(var model):
            model.cardNo = self.cardNo
            return self.provider.postReissueMembershipCard(model: model)
                .convertData()
                .compactMap(convertToDataModel)
                .map { serverResult in
                    if serverResult.code == 1000 {
                        UserDefault().saveBool(key: UserDefault.Key.IS_HIDDEN_DELEVERY_COMPLETE_TOOLTIP, value: false)
                        UserDefault().saveBool(key: UserDefault.Key.MB_HAS_MEMBERSHIP, value:  true)
                    } else {
                        Snackbar().show(message: "\(serverResult.msg)")
                    }
                    return .setCompleteReissuance(serverResult)
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.serverResult = nil
        
        switch mutation {
        case .setCompleteReissuance(let serverResult):
            newState.serverResult = serverResult
            
        case .none: break
        }
        return newState
    }
    
    private func convertToDataModel(with result: ApiResult<Data, ApiError> ) -> ServerResult? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "Json Data : \(jsonData)")
            return ServerResult(jsonData)
            
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            return nil
        }
    }
}

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
        case setCompleteReissuance(Int)
        case none
    }
    
    struct State {
        var completeCode: Int?
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
                .map { completeCode in .setCompleteReissuance(completeCode) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.completeCode = nil
        
        switch mutation {
        case .setCompleteReissuance(let code):
            newState.completeCode = code
            
        case .none: break
        }
        return newState
    }
    
    private func convertToDataModel(with result: ApiResult<Data, ApiErrorMessage> ) -> Int {
        switch result {
        case .success(let data):
            let codeData = JSON(data)["code"].intValue
            printLog(out: "CodeData : \(codeData)")
            return codeData
            
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            return 0
        }
    }
}

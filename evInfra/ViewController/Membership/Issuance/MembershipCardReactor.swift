//
//  MembershipCardReactor.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/11/03.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class MembershipCardReactor: ViewModel, Reactor {
    enum Action {
        case membershipCardInfo
    }
    
    enum Mutation {
        case setMembershipCardInfo(MembershipCardInfo)
    }
    
    struct State {
        var membershipCardInfo: MembershipCardInfo?
    }
    
    internal var initialState: State
            
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .membershipCardInfo:
            return self.provider.postMembershipCardInfo()
                            .convertData()
                            .compactMap(convertToData)
                            .map { model in
                                return .setMembershipCardInfo(model)
                            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.membershipCardInfo = nil
        
        switch mutation {
        case .setMembershipCardInfo(let model):
            newState.membershipCardInfo = model
                                                    
        }
        return newState
    }
    
    private func convertToData(with result: ApiResult<Data, ApiError>) -> MembershipCardInfo? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            
            let membershipCardInfo = MembershipCardInfo(jsonData)
            
            guard membershipCardInfo.code == 1000 else { return nil }
            
            return membershipCardInfo
                                                                         
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
            return nil
        }
    }
}

//
//  MyPageReactor.swift
//  evInfra
//
//  Created by 박현진 on 2022/07/21.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class MyPageReactor: ViewModel, Reactor {
    enum Action {
        case fetchUserInfo
    }
    
    enum Mutation {
        case setUserInfo(UserInfoModel)
    }
    
    struct State {
        var userInfoModel: UserInfoModel?
    }
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchUserInfo:
            return self.provider.postMemberInfo()
                .convertData()
                .compactMap(convertToData)
                .map { userInfoModel in
                    return .setUserInfo(userInfoModel)
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
                
        newState.userInfoModel = nil
        
        switch mutation {
        case .setUserInfo(let userInfoModel):
            newState.userInfoModel = userInfoModel
                                                                    
        }
        return newState
    }
    
    private func convertToData(with result: ApiResult<Data, ApiErrorMessage> ) -> UserInfoModel? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            
            let code = jsonData["code"].stringValue
            
            switch code {
            case "1000":
                return UserInfoModel(json: jsonData)
                
            default:
                return nil
            }
                                                             
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
            return nil
        }
    }
}

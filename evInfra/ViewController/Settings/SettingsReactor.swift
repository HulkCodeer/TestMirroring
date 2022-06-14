//
//  SettingsReactor.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/06/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class SettingsReactor: ViewModel, Reactor {
    enum Action {
        case updateBasicNotification(Bool)
//        case updateLocalNotification
//        case updateMarketingNotification
//        case quitAccount
        case none
    }
    
    enum Mutation {
        case setBasicNotification(Bool)
        case none
    }
    
    struct State {
        var isBasicNotification: Bool = UserDefault().readBool(key: UserDefault.Key.SETTINGS_ALLOW_NOTIFICATION)
    }
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateBasicNotification(let isState):
            return self.provider.updateBasicNotificationState(state: isState)
                .convertData()
                .compactMap(convertToData)
                .map { isReceivePush in
                    UserDefault().saveBool(key: UserDefault.Key.SETTINGS_ALLOW_NOTIFICATION, value: isReceivePush)
                    return .setBasicNotification(isReceivePush)
                }
            
        case .none:
            return .just(.none)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setBasicNotification(let isReceivePush):
            newState.isBasicNotification = isReceivePush
            
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

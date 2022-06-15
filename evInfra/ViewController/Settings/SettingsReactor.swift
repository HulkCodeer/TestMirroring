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
        case updateLocalNotification(Bool)
        case updateMarketingNotification(Bool)
//        case quitAccount
        case none
    }
    
    enum Mutation {
        case setBasicNotification(Bool)
        case setLocalNotification(Bool)
        case setMarketingNotification(Bool)
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
        case .updateBasicNotification(let isState):
            return self.provider.updateBasicNotificationState(state: isState)
                .convertData()
                .compactMap(convertToData)
                .map { isReceivePush in
                    UserDefault().saveBool(key: UserDefault.Key.SETTINGS_ALLOW_NOTIFICATION, value: isReceivePush)
                    return .setBasicNotification(isReceivePush)
                }
            
        case .updateLocalNotification(let isState):
            return self.provider.updateBasicNotificationState(state: isState)
                .convertData()
                .compactMap(convertToData)
                .map { isReceivePush in
                    UserDefault().saveBool(key: UserDefault.Key.SETTINGS_ALLOW_JEJU_NOTIFICATION, value: isReceivePush)
                    return .setLocalNotification(isReceivePush)
                    
        case .updateMarketingNotification(let isState):
            return self.provider.updateBasicNotificationState(state: isState)
                .convertData()
                .compactMap(convertToData)
                .map { isReceivePush in
                    UserDefault().saveBool(key: UserDefault.Key.SETTINGS_ALLOW_MARKETING_NOTIFICATION, value: isReceivePush)
                    let currDate = DateUtils.getFormattedCurrentDate(format: "yyyy년 MM월 dd일")
                    
                    let message = isReceivePush ? "[EV Infra] \(currDate)마케팅 수신 동의 처리가 완료되었어요! ☺️ 더 좋은 소식 준비할게요!" : "[EV Infra] \(currDate)마케팅 수신 거부 처리가 완료되었어요."
                    
                    Snackbar().show(message: "[EV Infra] " + currDate + "마케팅 수신 동의 처리가 완료되었어요! ☺️ 더 좋은 소식 준비할게요!")
                    
                    return .setMarketingNotification(isReceivePush)
            
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
        case .setBasicNotification(let isReceivePush):
            newState.isBasicNotification = isReceivePush
            
        case .setLocalNotification(let isReceivePush):
            newState.isLocalNotification = isReceivePush
            
        case .setMarketingNotification(let isReceivePush):
            newState.isMarketingNotification = isReceivePush
            
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
        case .updateMarketingNotification(_):
            <#code#>
        case .none:
            <#code#>
        }

//
//  FavoriteCellReactor.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/07/08.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class NewFavoriteCellReactor<T: Equatable> : Reactor, Equatable {
    enum Action {
        case alarmButtonTapped(chargerId: String, isOn: Bool)
        case favoriteButtonTapped(chargerId: String, isOn: Bool)
        case cellSelected
    }
    
    enum Mutation {
        case setAlarm(Bool)
        case setFavorite(Bool)
        case cellSelected
    }
    
    struct State {
        var model: FavoriteListInfo
        var isSelected: Bool = false
    }
    
    var initialState: State
    
    init(model: FavoriteListInfo) {
        defer { _ = self.state }
        self.initialState = State(model: model)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .alarmButtonTapped(let chargerId, let isOn):
            return RestApi().updateFavoriteAlarm(chargerId: chargerId, state: isOn)
                .convertData()
                .compactMap(convertToJson)
                .compactMap {
                    $0["noti"].boolValue
                }.map { .setAlarm($0) }
        case .favoriteButtonTapped(let chargerId, let isOn):
            return RestApi().updateFavorite(chargerId: chargerId, state: isOn)
                .convertData()
                .compactMap(convertToJson)
                .compactMap {
                    $0["mode"].boolValue
                }.map { .setFavorite($0) }
        case .cellSelected:
            return Observable.just(.cellSelected)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setAlarm(let isOn):
            newState.model.isAlarmOn = isOn
            // 충전소 리스트 싱글톤으로 구성되어있어, 메인뷰에서도 즐겨찾기 on/off UI 표시
            if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: state.model.chargerId) {
                charger.mFavoriteNoti = isOn
            }
        case .setFavorite(let isOn):
            newState.model.isFavorite = isOn
            // 충전소 리스트 싱글톤으로 구성되어있어, 메인뷰에서도 즐겨찾기 노티 알람 on/off UI 표시
            if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: state.model.chargerId) {
                charger.mFavorite = isOn
            }
        case .cellSelected:
            newState.isSelected = true
        }
        
        return newState
    }
    
    private func convertToJson(with result: ApiResult<Data, ApiErrorMessage>) -> JSON? {
        switch result {
        case .success(let data):
            return JSON(data)
        case .failure(let error):
            printLog(error.errorMessage)
            return nil
        }
    }
    
    static func == (lhs: NewFavoriteCellReactor<T>, rhs: NewFavoriteCellReactor<T>) -> Bool {
        lhs.initialState.model == rhs.initialState.model
    }
}

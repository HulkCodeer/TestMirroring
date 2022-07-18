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
        case alarmButtonTapped(Bool)
        case favoriteButtonTapped(Bool)
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
        var isAlarmButtonTapped: Bool = false
        var isFavoriteButtonTapped: Bool = false
    }
    
    var initialState: State
    
    init(model: FavoriteListInfo) {
        defer { _ = self.state }
        self.initialState = State(model: model)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .alarmButtonTapped(let isOn):
            return .just(.setAlarm(isOn))
        case .favoriteButtonTapped(let isOn):
            return .just(.setFavorite(isOn))
        case .cellSelected:
            return .just(.cellSelected)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setAlarm(let isOn):
            newState.model.isAlarmOn = isOn
            newState.isAlarmButtonTapped = true
            // 충전소 리스트 싱글톤으로 구성되어있어, 메인뷰에서도 즐겨찾기 on/off UI 표시
            if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: state.model.chargerId) {
                charger.mFavoriteNoti = isOn
            }
        case .setFavorite(let isOn):
            newState.model.isFavorite = isOn
            newState.isFavoriteButtonTapped = true
            // 충전소 리스트 싱글톤으로 구성되어있어, 메인뷰에서도 즐겨찾기 노티 알람 on/off UI 표시
            if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: state.model.chargerId) {
                charger.mFavorite = isOn
            }
        case .cellSelected:
            newState.isSelected = true
        }
        
        return newState
    }
    
    static func == (lhs: NewFavoriteCellReactor<T>, rhs: NewFavoriteCellReactor<T>) -> Bool {
        lhs.initialState.model == rhs.initialState.model
    }
}

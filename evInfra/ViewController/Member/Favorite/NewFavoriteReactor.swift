//
//  FavoriteReactor.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/07/06.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import CoreLocation
import UIKit
import SwiftyJSON
import CloudKit
import RxCocoa
import Differentiator

internal final class NewFavoriteReactor: ViewModel, Reactor {
    enum Action {
        case loadData
        case cellSelected(String)
        case isAlarmOn(String, Bool)
        case isFavorite(String, Bool)
    }
    
    enum Mutation {
        case setFavoriteList([FavoriteListItem])
        case cellSelected(String)
        case isAlarmOn(Bool)
        case isFavorite(Bool)
    }
    
    struct State {
        var sections = [FavoriteListSectionModel]()
        var isHiddenEmptyView: Bool = true
        var isSelectedChargerId: String = ""
    }
    
    internal var initialState: State
    internal var delegate: ChargerSelectDelegate?
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData:
            return self.provider.getFavoriteList()
                .convertData()
                .compactMap(convertToDataModel)
                .compactMap {
                    self.convertToFavoriteList(with: $0)
                }.compactMap {
                    .setFavoriteList(self.convertToItem(models: $0))
                }
        case .cellSelected(let chargerId):
            return Observable.just(.cellSelected(chargerId))
        case .isAlarmOn(let chargerId, let isOn):
            return self.provider.updateFavoriteAlarm(chargerId: chargerId, state: isOn)
                .convertData()
                .compactMap(convertToJson)
                .compactMap {
                    $0["noti"].boolValue
                }.map { .isAlarmOn($0) }
        case .isFavorite(let chargerId, let isOn):
            return self.provider.updateFavorite(chargerId: chargerId, state: isOn)
                .convertData()
                .compactMap(convertToJson)
                .compactMap {
                    $0["mode"].boolValue
                }.map { .isFavorite($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setFavoriteList(let favoriteList):
            newState.sections = [FavoriteListSectionModel(items: favoriteList)]
            newState.isHiddenEmptyView = !favoriteList.isEmpty
        case .cellSelected(let chargerId):
            newState.isSelectedChargerId = chargerId
        case .isAlarmOn(let isOn): break
        case .isFavorite(let isOn): break
        }
        
        return newState
    }
    
    private func convertToDataModel(with result: ApiResult<Data, ApiErrorMessage>) -> [FavoriteListDataModel.FavoriteModel]? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            return FavoriteListDataModel(jsonData).list
        case .failure(let error):
            printLog(error.errorMessage)
            return nil
        }
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
    
    private func convertToFavoriteList(with list: [FavoriteListDataModel.FavoriteModel]) -> [FavoriteListInfo]? {
        var newList = [FavoriteListInfo]()
        list.forEach {
            if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: $0.id) {
                var favorite = FavoriteListInfo(charger)
                printLog(out: "== PKH:: ==")
                printLog(out: "\(favorite)")
                favorite.isAlarmOn = $0.noti
                newList.append(favorite)
            }
        }
        return newList
    }
    
    private func convertToItem(models: [FavoriteListInfo]) -> [FavoriteListItem] {
        var items = [FavoriteListItem]()
        for data in models {
            let reactor = NewFavoriteCellReactor<FavoriteListInfo>(model: data)
            let chargerId = reactor.currentState.model.chargerId
            
            reactor.state
                .compactMap { $0.isSelected }
                .subscribe(onNext: { [weak self] isSelected in
                    guard let self = self, isSelected else { return }
                    Observable.just(NewFavoriteReactor.Action.cellSelected(chargerId))
                        .bind(to: self.action)
                        .disposed(by: self.disposeBag)
                    
                    GlobalDefine.shared.mainNavi?.dismiss(animated: true)
                }).disposed(by: disposeBag)
            
            // reactor ui가 변경됨
            reactor.state.compactMap { $0.isAlarmButtonTapped }
                .distinctUntilChanged()
                .subscribe(onNext: { isSelect in
                    guard isSelect else { return }
                    Observable.just(NewFavoriteReactor.Action.isAlarmOn(chargerId, reactor.currentState.model.isAlarmOn))
                        .bind(to: self.action)
                        .disposed(by: self.disposeBag)
                }).disposed(by: disposeBag)

            reactor.state.compactMap { $0.isFavoriteButtonTapped }
                .distinctUntilChanged()
                .subscribe(onNext: { isSelect in
                    guard isSelect else { return }
                    Observable.just(NewFavoriteReactor.Action.isFavorite(chargerId, reactor.currentState.model.isFavorite))
                        .bind(to: self.action)
                        .disposed(by: self.disposeBag)
                }).disposed(by: disposeBag)
            
            items.append(.favoriteListItem(reactor: reactor))
        }
        
        return items
    }
}

struct FavoriteListDataModel {
    let code: Int
    let list: [FavoriteModel]
    
    init(_ json: JSON) {
        self.code = json["code"].intValue
        self.list = json["list"].arrayValue.map {
            FavoriteModel($0)
        }
    }
    
    struct FavoriteModel {
        let id: String
        let noti: Bool
        
        init(_ json: JSON) {
            self.id = json["id"].stringValue
            self.noti = json["noti"].boolValue
        }
    }
}

struct FavoriteListInfo: Equatable {
    var chargerId: String = ""
    var stationName: String = ""
    var address: String = ""
    var totalStatusName: String = ""
    var type: String = ""
    var distance: String = ""
    var status: Int = 0
    var cstColor: UIColor = Colors.contentDisabled.color
    var isFavorite: Bool = false
    var isAlarmOn: Bool = false
    
    init() {}
    init(_ charger: ChargerStationInfo) {
        self.chargerId = charger.mChargerId ?? ""
        self.stationName = charger.mStationInfoDto?.mSnm ?? "충전소 이름"
        self.address = charger.mStationInfoDto?.mAddress ?? ""
        self.totalStatusName = charger.mTotalStatusName ?? ""
        self.type = charger.getTotalChargerType()
        self.distance = getDistance(at: charger.mStationInfoDto)
        self.cstColor = Colors.contentTertiary.color
        self.status = charger.mTotalStatus ?? Const.CHARGER_STATE_UNKNOWN
        self.cstColor = charger.cidInfo.getCstColor(cst: charger.mTotalStatus ?? Const.CHARGER_STATE_UNKNOWN)
        self.isFavorite = charger.mFavorite
        self.isAlarmOn = charger.mFavoriteNoti
    }
    
    private func getDistance(at station: StationInfoDto?) -> String {
        guard let station = station else { return "" }
        let coordinate = CLLocationCoordinate2D(latitude: station.mLatitude ?? .zero, longitude: station.mLongitude ?? .zero)
        let distance = CLLocationCoordinate2D().distance(to: coordinate)
        return StringUtils.convertDistanceString(distance: distance)
    }
}

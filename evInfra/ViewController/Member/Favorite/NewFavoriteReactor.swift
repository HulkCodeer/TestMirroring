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

internal final class NewFavoriteReactor: ViewModel, Reactor {
    enum Action {
        case loadData
    }
    
    enum Mutation {
        case setFavoriteList([FavoriteListItem])
        case none
    }
    
    struct State {
        var sections = [FavoriteListSectionModel]()
    }
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData:
//            ChargerManager.sharedInstance.getFavoriteCharger()
//            let favoriteList: [FavoriteListItem] = ChargerManager.sharedInstance.getChargerStationInfoList().filter {
//                $0.mFavorite }
//                .map { FavoriteListInfo($0) }
//                .compactMap { .favoriteListItem(reactor: NewFavoriteCellReactor(model: $0)) }
//            return Observable.just(favoriteList).map {
//                .setFavoriteList($0)
//            }
            return self.provider.getFavoriteList()
                .convertData()
                .compactMap(convertToDataModel)
                .compactMap {
                    self.convertToFavoriteList(with: $0)
                }.compactMap {
                    .setFavoriteList(self.convertToItem(models: $0))
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.sections = []
        
        switch mutation {
        case .setFavoriteList(let favoriteList):
            newState.sections = [FavoriteListSectionModel(items: favoriteList)]
        case .none: break
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
    
    private func convertToFavoriteList(with list: [FavoriteListDataModel.FavoriteModel]) -> [FavoriteListInfo]? {
        var newList = [FavoriteListInfo]()
        list.forEach {
            if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: $0.id) {
                var favorite = FavoriteListInfo(charger)
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

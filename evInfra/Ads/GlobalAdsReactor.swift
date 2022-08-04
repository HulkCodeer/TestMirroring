//
//  AdsReactor.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/08/02.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class GlobalAdsReactor: ViewModel, Reactor {
    enum Action {
        case loadStartBanner(Page, Layer)
        case addEventClickCount(String)
        case addEventViewCount(String)
    }
    
    enum Mutation {
        case setAds([AdsInfo])
    }
    
    struct State {
        var startBanner: AdsInfo? = nil
        var ads = [AdsInfo]()
    }
    
    internal var initialState: State
    
    enum Page: Int {
        case start = 1
        case end = 3
        case notice = 51
        case free = 52
        case charging = 53
        case gsc = 61
        case est = 62
    }
    
    enum Layer: Int {
        case top = 1
        case mid = 2
        case bottom = 3
        case popup = 4
    }

    enum AdsType: String, CaseIterable {
        case ad = "1"
        case event = "2"
    }
    
    enum EventAction: Int {
        case view = 0
        case click = 1
    }
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadStartBanner(let page, let layer):
            return self.provider.getAds(page: page.rawValue, layer: layer.rawValue)
                .convertData()
                .compactMap(convertToDataModel)
                .compactMap(convertToModel)
                .compactMap { .setAds($0) }
        case .addEventClickCount(let eventId):
            return .empty()
        case .addEventViewCount(let eventId):
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.ads = []
        
        switch mutation {
        case .setAds(let ads):
            newState.startBanner = ads.first ?? AdsInfo()
        }
        
        return newState
    }
    
    private func convertToDataModel(with result: ApiResult<Data, ApiErrorMessage>) -> JSON? {
        switch result {
        case .success(let data):
            return JSON(data)
        case .failure(let errorMessage):
            printLog(out: "error: \(errorMessage)")
            return nil
        }
    }
    
    private func convertToModel(with json: JSON) -> [AdsInfo]? {
        let adsList = AdsListDataModel(json).data
        var adsModels = [AdsInfo]()
        adsList.forEach { adsModels.append($0) }
        return adsList
    }
}

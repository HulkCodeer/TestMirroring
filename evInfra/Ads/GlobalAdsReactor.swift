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
        case loadStartBanner
        case addEventClickCount(String)
        case addEventViewCount(String)
    }
    
    enum Mutation {
        case setAds([AdsInfo])
    }
    
    struct State {
        var startBanner: AdsInfo?
    }
    
    internal var initialState: State
    static let sharedInstance: GlobalAdsReactor = GlobalAdsReactor(provider: RestApi())
    
    enum AdsType: String, CaseIterable {
        case ad = "1"
        case event = "2"
    }

    override private init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadStartBanner:
            return self.provider.getAdsList(page: .start, layer: .bottom)
                .convertData()
                .compactMap(convertToDataModel)
                .compactMap { .setAds($0) }
            
        case .addEventClickCount(let eventId):
            _ = self.provider.logAds(adId: [eventId], action: Promotion.Action.click.toValue, page: .start, layer: .bottom)
            return .empty()
            
        case .addEventViewCount(let eventId):
            _ = self.provider.logAds(adId: [eventId], action: Promotion.Action.view.toValue, page: .start, layer: .bottom)
            return .empty()
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.startBanner = nil
        
        switch mutation {
        case .setAds(let ads):
            guard let randomBanner = ads.randomElement() else { return newState }
            newState.startBanner = randomBanner
        }
        
        return newState
    }
    
    private func convertToDataModel(with result: ApiResult<Data, ApiError>) -> [AdsInfo]? {
        switch result {
        case .success(let data):
            let json = JSON(data)
            let adsList = json["data"].arrayValue.map { AdsInfo($0) }            
            guard adsList.count != 0 else { return nil }
            
            return adsList
            
        case .failure(let errorMessage):
            printLog(out: "error: \(errorMessage)")
            Snackbar().show(message: "오류가 발생하였습니다.")
            return nil
        }
    }
}

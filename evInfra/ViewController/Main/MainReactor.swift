//
//  MainReactor.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/09/10.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class MainReactor: ViewModel, Reactor {
    typealias SelectedFilterInfo = (filterTagType: FilterTagType, isSeleted: Bool)
    typealias SelectedPlaceFilter = (placeType: PlaceType, isSelected: Bool)
    typealias SelectedRoadFilter = (roadType: RoadType, isSelected: Bool)
    typealias SelectedChargerTypeFilter = (chargerType: ChargerType, isSelected: Bool)
    typealias SelectedSpeedFilter = (minSpeed: Int, maxSpeed: Int)
    typealias SelectedAccessFilter = (accessType: AccessType, isSelected: Bool)
    
    enum Action {        
        case showMarketingPopup
        case setAgreeMarketing(Bool)
        case setSelectedFilterInfo(SelectedFilterInfo)
        case setSelectedPlaceFilter(SelectedPlaceFilter)
        case setSelectedRoadFilter(SelectedRoadFilter)
        case setSelectedChargerTypeFilter(SelectedChargerTypeFilter)
        case setSelectedSpeedFilter(SelectedSpeedFilter)
        case setSelectedAccessFilter(SelectedAccessFilter)
        case swipeLeft
        case swipeRight
        case showFilterSetting
        case updateFilterBarTitle
        case setEvPayFilter(Bool)
        case setFavoriteFilter(Bool)
        case setRepresentCarFilter(Bool)
        case openEvPayTooltip
    }
    
    enum Mutation {
        case setShowMarketingPopup(Bool)
        case setShowStartBanner(Bool)
        case setSelectedFilterInfo(SelectedFilterInfo)
        case setSelectedPlaceFilter(SelectedPlaceFilter)
        case setSelectedRoadFilter(SelectedRoadFilter)
        case setSelectedChargerTypeFilter(SelectedChargerTypeFilter)
        case setSelectedSpeedFilter(SelectedSpeedFilter)
        case setSelectedAccessFilter(SelectedAccessFilter)
        case showFilterSetting
        case updateFilterBarTitle
        case setEvPayFilter(Bool)
        case setFavoriteFilter(Bool)
        case setRepresentCarFilter(Bool)
        case openEvPayTooltip
    }
    
    struct State {
        var isShowMarketingPopup: Bool?
        var isShowStartBanner: Bool?
        var selectedFilterInfo: SelectedFilterInfo?
        var selectedPlaceFilter: SelectedPlaceFilter?
        var selectedRoadFilter: SelectedRoadFilter?
        var selectedChargerTypeFilter: SelectedChargerTypeFilter?
        var selectedSpeedFilter: SelectedSpeedFilter?
        var selectedAccessFilter: SelectedAccessFilter?
        var isShowFilterSetting: Bool?
        var isUpdateFilterBarTitle: Bool?
        var isEvPayFilter: Bool? = FilterManager.sharedInstance.getIsMembershipCardChecked()
        var isFavoriteFilter: Bool? = FilterManager.sharedInstance.getIsFavoriteChecked()
        var isRepresentCarFilter: Bool?
        var isShowEvPayToolTip: Bool?
    }
    
    internal var initialState: State    

    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .showMarketingPopup:
            let isShowMarketingPopup = UserDefault().readBool(key: UserDefault.Key.DID_SHOW_MARKETING_POPUP)
            if !isShowMarketingPopup {
                return .just(.setShowMarketingPopup(true))
            } else {
                return .just(.setShowStartBanner(true))
            }
            
        case .setAgreeMarketing(let isAgree):
            return self.provider.updateMarketingNotificationState(state: isAgree)
                .convertData()
                .compactMap(convertToData)
                .map { isShowStartBanner in
                    return .setShowStartBanner(isShowStartBanner)
                }
            
        case .setSelectedFilterInfo(let selectedFilterInfo):
            return .just(.setSelectedFilterInfo(selectedFilterInfo))
            
        case .setSelectedPlaceFilter(let selectedPlaceFilter):
            return .just(.setSelectedPlaceFilter(selectedPlaceFilter))
            
        case .setSelectedRoadFilter(let selectedRoadFilter):
            return .just(.setSelectedRoadFilter(selectedRoadFilter))
            
        case .setSelectedChargerTypeFilter(let selectedChargerTypeFilter):
            return .just(.setSelectedChargerTypeFilter(selectedChargerTypeFilter))
            
        case .setSelectedSpeedFilter(let selectedSpeedFilter):
            return .just(.setSelectedSpeedFilter(selectedSpeedFilter))
            
        case .setSelectedAccessFilter(let selectedAccessFilter):
            selectedAccessFilter.accessType == .publicCharger ? FilterManager.sharedInstance.savePublic(with: selectedAccessFilter.isSelected) : FilterManager.sharedInstance.saveNonPublic(with: selectedAccessFilter.isSelected)
            return .just(.setSelectedAccessFilter(selectedAccessFilter))
            
        case .swipeLeft:
            let selectedFilterInfo: SelectedFilterInfo = (filterTagType: self.currentState.selectedFilterInfo?.filterTagType.swipeLeft() ?? .speed, isSeleted: true)
            return .just(.setSelectedFilterInfo(selectedFilterInfo))
            
        case .swipeRight:
            let selectedFilterInfo: SelectedFilterInfo = (filterTagType: self.currentState.selectedFilterInfo?.filterTagType.swipeRight() ?? .speed, isSeleted: true)
            return .just(.setSelectedFilterInfo(selectedFilterInfo))
            
        case .showFilterSetting:
            return .just(.showFilterSetting)
            
        case .updateFilterBarTitle:
            return .just(.updateFilterBarTitle)
            
        case .setEvPayFilter(let isEvPayFilter):
            FilterManager.sharedInstance.saveIsMembershipCardChecked(isEvPayFilter)
            return .just(.setEvPayFilter(isEvPayFilter))
            
        case .setFavoriteFilter(let isFavoriteFilter):
            FilterManager.sharedInstance.saveIsFavoriteChecked(isFavoriteFilter)
            return .just(.setFavoriteFilter(isFavoriteFilter))
            
        case .setRepresentCarFilter(let isRepresentCarFilter):
            return .just(.setRepresentCarFilter(isRepresentCarFilter))
            
        case .openEvPayTooltip:
            return .just(.openEvPayTooltip)
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isShowMarketingPopup = nil        
        newState.isShowFilterSetting = nil
        newState.isShowEvPayToolTip = nil        
        
        switch mutation {
        case .setShowMarketingPopup(let isShow):
            newState.isShowMarketingPopup = isShow
            
        case .setShowStartBanner(let isShow):
            newState.isShowStartBanner = isShow
            
        case .setSelectedFilterInfo(let selectedFilterInfo):
            newState.selectedFilterInfo = selectedFilterInfo
            newState.isUpdateFilterBarTitle = true
            
        case .setSelectedPlaceFilter(let selectedPlaceFilter):
            newState.selectedPlaceFilter = selectedPlaceFilter
            newState.isUpdateFilterBarTitle = true
            
        case .setSelectedRoadFilter(let selectedRoadFilter):
            newState.selectedRoadFilter = selectedRoadFilter
            newState.isUpdateFilterBarTitle = true
            
        case .setSelectedChargerTypeFilter(let selectedChargerTypeFilter):
            newState.selectedChargerTypeFilter = selectedChargerTypeFilter
            newState.isUpdateFilterBarTitle = true
            
        case .setSelectedSpeedFilter(let selectedSpeedFilter):
            newState.selectedSpeedFilter = selectedSpeedFilter
            newState.isUpdateFilterBarTitle = true
            
        case .setSelectedAccessFilter(let selectedAccessFilter):
            newState.selectedAccessFilter = selectedAccessFilter
            
        case .showFilterSetting:
            newState.isShowFilterSetting = true
            
        case .updateFilterBarTitle:
            newState.isUpdateFilterBarTitle = true
            
        case .setEvPayFilter(let isEvPayFilter):
            newState.isEvPayFilter = isEvPayFilter
            
        case .setFavoriteFilter(let isFavoriteFilter):
            newState.isFavoriteFilter = isFavoriteFilter
            
        case .setRepresentCarFilter(let isRepresentCarFilter):
            newState.isRepresentCarFilter = isRepresentCarFilter
            
        case .openEvPayTooltip:
            newState.isShowEvPayToolTip = FCMManager.sharedInstance.originalMemberId.isEmpty
        }
        
        return newState
    }
    
    private func convertToData(with result: ApiResult<Data, ApiError> ) -> Bool? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            
            let code = jsonData["code"].stringValue
            guard "1000".equals(code) else {
                return nil
            }
                                                
            let receive = jsonData["receive"].boolValue
            
            MemberManager.shared.isAllowMarketingNoti = receive                        
            UserDefault().saveBool(key: UserDefault.Key.DID_SHOW_MARKETING_POPUP, value: true)
            let currDate = DateUtils.getFormattedCurrentDate(format: "yyyy년 MM월 dd일")
            
            var message = "[EV Infra] \(currDate) "
            message += receive ? "마케팅 수신 동의 처리가 완료되었어요! ☺️ 더 좋은 소식 준비할게요!" : "마케팅 수신 거부 처리가 완료되었어요."
            
            Snackbar().show(message: message)
        
            return true
            
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
            return nil
        }
    }
}

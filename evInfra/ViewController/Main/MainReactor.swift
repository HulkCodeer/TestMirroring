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
    
    enum Action {        
        case showMarketingPopup
        case setAgreeMarketing(Bool)
        case setMenuBadge(Bool)
        case setSelectedFilterInfo(SelectedFilterInfo)
        case swipeLeft
        case swipeRight
        case showFilterSetting
        case updateFilterBarTitle
        case showSearchChargingStation
        case showMenu
        case closeMenu
        case hideSearchWay(Bool)
        case searchDestination(SearchWayPointType, String)
        case hideDestinationResult(Bool)
        case clearSearchWayData
        case clearSearchPoint(SearchWayPointType)
        case setEvPayFilter(Bool)
        case openEvPayTooltip
    }
    
    enum Mutation {
        case setShowMarketingPopup(Bool)
        case setShowStartBanner(Bool)
        case setMenuBadge(Bool)
        case showFilterSetting
        case updateFilterBarTitle
        case showSearchChargingStation
        case setIsShowMenu(Bool)
        case hidSearchWay(Bool)
        case searchDestination(SearchWayPointType, String)
        case hideDestinationResult(Bool)
        case clearSearchWayData
        case clearSearchPoint(SearchWayPointType)
        case setSelectedFilterInfo(SelectedFilterInfo)
        case setEvPayFilter(Bool)
        case openEvPayTooltip
    }
    
    struct State {
        var isShowMarketingPopup: Bool?
        var isShowStartBanner: Bool?
        var hasNewBoardContents: Bool?
        var isShowFilterSetting: Bool?
        var isUpdateFilterBarTitle: Bool?
        var isShowSearchChargingStation: Bool?
        var isShowMenu: Bool?
        var isHideSearchWay: Bool?
        var isHideDestinationResult: Bool?
        var isClearSearchWayData: Bool?
        var isClearSearchWayPoint: (Bool, SearchWayPointType)?
        var searchDetinationData: (SearchWayPointType, String)?
        var selectedFilterInfo: SelectedFilterInfo?
        var isEvPayFilter: Bool?
        var isShowEvPayToolTip: Bool?
    }
    
    internal var initialState: State

    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    // MARK: - mutate
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
        case .setMenuBadge(let hasNewContents):
            return .just(.setMenuBadge(hasNewContents))

        case .setSelectedFilterInfo(let selectedFilterInfo):
            return .just(.setSelectedFilterInfo(selectedFilterInfo))
            
        case .swipeLeft:
            let selectedFilterInfo: SelectedFilterInfo = (filterTagType: self.currentState.selectedFilterInfo?.filterTagType.swipeLeft() ?? .price, isSeleted: true)
            return .just(.setSelectedFilterInfo(selectedFilterInfo))
            
        case .swipeRight:
            let selectedFilterInfo: SelectedFilterInfo = (filterTagType: self.currentState.selectedFilterInfo?.filterTagType.swipeRight() ?? .price, isSeleted: true)
            return .just(.setSelectedFilterInfo(selectedFilterInfo))
            
        case .showFilterSetting:
            return .just(.showFilterSetting)
            
        case .updateFilterBarTitle:
            return .just(.updateFilterBarTitle)
            
        case .showSearchChargingStation:
            return Observable.concat([
                .just(.showSearchChargingStation),
            ])
            
            // 메뉴화면.
        case .showMenu:
            GlobalDefine.shared.rootVC?.showLeftView(true)
            return .just(.setIsShowMenu(true))

        case .closeMenu:
            GlobalDefine.shared.rootVC?.showLeftView(false)
            return .just(.setIsShowMenu(false))
            
        case .hideSearchWay(let isHide) where isHide == true:
            return Observable.concat([
                .just(.hidSearchWay(isHide)),
                .just(.clearSearchWayData),
                .just(.hideDestinationResult(isHide)),
            ])
        case .hideSearchWay(let isHide):
            return Observable.concat([
                .just(.hidSearchWay(isHide)),
            ])
            
        case let .searchDestination(_, text) where text == String():
            return .just(.hideDestinationResult(true))
        case let.searchDestination(type, text):
            return Observable.concat([
                .just(.searchDestination(type, text)),
                .just(.hideDestinationResult(false))
            ])
            
        case .hideDestinationResult(let isHide):
            return .just(.hideDestinationResult(isHide))
            
        case .clearSearchWayData:
            return Observable.concat([
                .just(.clearSearchWayData),
                .just(.hideDestinationResult(true))])
            
        case .clearSearchPoint(let searchPoint):
            return Observable.concat([
                .just(.clearSearchPoint(searchPoint)),
                .just(.hideDestinationResult(true))
            ])

        case .setEvPayFilter(let isEvPayFilter):
            return .just(.setEvPayFilter(isEvPayFilter))
            
        case .openEvPayTooltip:
            return .just(.openEvPayTooltip)
            
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isShowMarketingPopup = nil
        newState.isShowStartBanner = nil
        newState.hasNewBoardContents = nil
        newState.isShowFilterSetting = nil
        newState.isUpdateFilterBarTitle = nil
        newState.isShowSearchChargingStation = nil
        newState.isShowMenu = nil
        newState.isHideSearchWay = nil
        newState.isHideDestinationResult = nil
        newState.isClearSearchWayData = nil
        newState.isClearSearchWayPoint = nil
        newState.searchDetinationData = nil
        newState.isShowEvPayToolTip = nil
        
        switch mutation {
        case .setShowMarketingPopup(let isShow):
            newState.isShowMarketingPopup = isShow
            
        case .setShowStartBanner(let isShow):
            newState.isShowStartBanner = isShow
                    
        case .setMenuBadge(let hasNewContents):
            newState.hasNewBoardContents = hasNewContents
            
        case .setSelectedFilterInfo(let selectedFilterInfo):
            newState.selectedFilterInfo = selectedFilterInfo
            newState.isUpdateFilterBarTitle = true
            
        case .showFilterSetting:
            newState.isShowFilterSetting = true
            
        case .updateFilterBarTitle:
            newState.isUpdateFilterBarTitle = true
            
        case .showSearchChargingStation:
            newState.isShowSearchChargingStation = true
            
        case .setIsShowMenu(let isShowMenu):
            newState.isShowMenu = isShowMenu
            
        case .hidSearchWay(let isHideSearchWay):
            newState.isHideSearchWay = isHideSearchWay
            
        case let .searchDestination(type, text):
            newState.searchDetinationData = (type, text)
            
        case .hideDestinationResult(let isHideDestinationResult):
            newState.isHideDestinationResult = isHideDestinationResult
            
        case .clearSearchWayData:
            newState.isClearSearchWayData = true
         
        case .clearSearchPoint(let pointType):
            newState.isClearSearchWayPoint = (true, pointType)

        case .setEvPayFilter(let isEvPayFilter):
            newState.isEvPayFilter = isEvPayFilter
            
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
    
    enum SearchWayPointType {
        case startPoint
        case endPoint
    }
}

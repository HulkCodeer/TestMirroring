//
//  MainReactor.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/09/10.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON
import UIKit

internal final class MainReactor: ViewModel, Reactor {
    typealias SelectedFilterInfo = (filterTagType: FilterTagType, isSeleted: Bool)
    typealias ChargingData = (chargingType: ChargeShowType, chargingData: ChargingID?)
    
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
        case toggleLeftMenu
        case hideSearchWay(Bool)
        case searchDestination(SearchWayPointType, String)
        case hideDestinationResult(Bool)
        case clearSearchWayData
        case clearSearchPoint(SearchWayPointType)
        case setEvPayFilter(Bool)
        case openEvPayTooltip
        case setChargingID
        case selectedBottomMenu(BottomMenuType)
        case setQR
    }
    
    enum Mutation {
        case setShowMarketingPopup(Bool)
        case setShowStartBanner(Bool)
        case setMenuBadge(Bool)
        case showFilterSetting
        case updateFilterBarTitle
        case showSearchChargingStation
        case toggleLeftMenu
        case hidSearchWay(Bool)
        case searchDestination(SearchWayPointType, String)
        case hideDestinationResult(Bool)
        case clearSearchWayData
        case clearSearchPoint(SearchWayPointType)
        case setSelectedFilterInfo(SelectedFilterInfo)
        case setEvPayFilter(Bool)
        case openEvPayTooltip
        case setChargingData(ChargeShowType)
        case setQRMenu(ChargingData)
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
        var chargingType: ChargeShowType?
        var qrMenuChargingData: ChargingData?
        
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
        case .toggleLeftMenu:
            return .just(.toggleLeftMenu)
                    
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
            
        case .setChargingID:
            return self.provider.getChargingID()
                .convertData()
                .compactMap(MainReactor.convertToChargingData)
                .map { return .setChargingData($0.chargingType) }

        case .selectedBottomMenu(let bottomType):
            bottomType.action(reactor: self, provider: provider)
            return .empty()
            
        case .setQR:
            return self.provider.getChargingID()
                .convertData()
                .compactMap(MainReactor.convertToChargingData)
                .map { return .setQRMenu($0) }
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
        newState.chargingType = nil
        newState.qrMenuChargingData = nil
        
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
            
        case .toggleLeftMenu:
            newState.isShowMenu = true
            
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

        case .setChargingData(let chargingType):
            newState.chargingType = chargingType
            
        case .setQRMenu(let chargingData):
            newState.qrMenuChargingData = chargingData
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
    
    static func convertToChargingData(with result: ApiResult<Data, ApiError>) -> ChargingData? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog("--> convertToChargingData \(jsonData), \(jsonData["pay_code"])")
            let code = jsonData["code"]
            let payCode = jsonData["pay_code"].stringValue
            
            switch (code, payCode) {
            case (_, "8804") :  // 미수금
                return ( .accountsReceivable, nil)
                
            case (1000, _) :    // 충전중
                let chargingData = try? JSONDecoder().decode(ChargingID.self, from: data)
                return (.charging, chargingData)

            case (2002, _) where jsonData["status"].stringValue == "delete":      // 탈퇴 회원
                return (.leave, nil)
                
            case (2002, _):      // 충전 x
                return (.none, nil)
                
            default:
                return nil
            }
 
        case .failure(let error):
            printLog(out: "Error Message : \(error)")
            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
            return nil
        }
    }
    
    enum SearchWayPointType {
        case startPoint
        case endPoint
    }

    enum BottomMenuType: CaseIterable {
        case qrCharging
        case community
        case evPay
        case favorite
        
        var value: (icon: UIImage, title: String) {
            switch self {
            case .qrCharging:
                return (Icons.iconQr.image, "QR충전")
                
            case .community:
                return (Icons.iconComment.image, "자유게시판")
                
            case .evPay:
                return (Icons.iconEvpay.image, "EV Pay 관리")
                
            case .favorite:
                return (Icons.iconFavorite.image, "즐겨찾기")
            }
        }
        
        func action(reactor: MainReactor, provider: SoftberryAPI) {
            
            switch self {
            case .qrCharging:
                MemberManager.shared.tryToLoginCheck { isLogin in
                    if isLogin {
                        Observable.just(MainReactor.Action.setQR)
                            .bind(to: reactor.action)
                            .disposed(by: reactor.disposeBag)
                        
                    } else {
                        // 비로그인시 로그인 플로우 확인용
                        AmplitudeEvent.shared.setFromViewDesc(fromViewDesc: "QR충전")
                        MemberManager.shared.showLoginAlert()
                    }
                }
                
            case .community:
                break
                
            case .evPay:
                break
                
            case .favorite:
                break
            }
        }
        
//        var specificValue: (UIImage, String)? {
//            switch self{
//            case .qrCharging:
//                return (Icons.icLineCharging.image, "충전중")
//
//            case .evPay:
//                return (Icons.iconEvpayNew.image, "EV Pay 관리")
//
//            default:
//                return nil
//            }
//        }
    }
    
    enum ChargeShowType {
        case charging
        case none
        case accountsReceivable
        
        case leave
    }
    
}

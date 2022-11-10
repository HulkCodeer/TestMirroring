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
        case actionBottomQR
        case actionEVPay
        case actionBottomMenu(BottomMenuType)
        case setIsAccountsReceivable(Bool)
        case setIsCharging(Bool)
        case showChargePrice
        case setPaymentStatus
        case hasEVPayCard(Bool)
        case openBottomEvPayTooltip
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
        case setEVPay(EVPayShowType)
        case setSelectedBottomMenu(BottomMenuType)
        case setIsAccountsReceivable(Bool)
        case setIsCharging(Bool)
        case setChargePrice
        case hasEVPayCard(Bool)
        case openBottomEvPayTooltip
        case none
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
        var evPayPresentType: EVPayShowType?
        var qrMenuChargingData: ChargingData?
        var bottomItemType: BottomMenuType?
        var isAccountsReceivable: Bool? = false
        var isCharging: Bool? = false
        var isShowChargePrice: Bool?
        var hasEVPayCard: Bool?
        var isShowBottomEvPayToolTip: Bool?
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
                .compactMap(convertToChargingData)
                .map { return .setChargingData($0.chargingType) }

        case .selectedBottomMenu(let bottomType):
            bottomType.action(reactor: self, provider: provider)
            return .empty()
            
        case .actionBottomQR:
            return self.provider.getChargingID()
                .convertData()
                .compactMap(convertToChargingData)
                .map { return .setQRMenu($0) }
            
        case .actionEVPay:
            return provider.postPaymentStatus()
                .convertData()
                .compactMap(convertToEVPayShowType)
                .map { return .setEVPay($0)}
            
        case .actionBottomMenu(let menuType):
            return .just(.setSelectedBottomMenu(menuType) )
            
        case .setIsAccountsReceivable(let isReceivable):
            return .just(.setIsAccountsReceivable(isReceivable))
            
        case .setIsCharging(let isCharging):
            return .just(.setIsCharging(isCharging))
            
        case .showChargePrice:
            return .just(.setChargePrice)
            
        case .setPaymentStatus:
            return provider.postPaymentStatus()
                .convertData()
                .map(setPaymentStatus)
                
        case .hasEVPayCard(let hasEvPayCard):
            return .just(.hasEVPayCard(hasEvPayCard))
            
        case .openBottomEvPayTooltip:
            return .just(.openBottomEvPayTooltip)
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
        newState.evPayPresentType = nil
        newState.bottomItemType = nil
        newState.isAccountsReceivable = nil
        newState.isCharging = nil
        newState.isShowChargePrice = nil
        newState.hasEVPayCard = nil
        newState.isShowBottomEvPayToolTip = nil
        
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
            
        case .setEVPay(let showType):
            newState.evPayPresentType = showType
            
        case .setSelectedBottomMenu(let itemType):
            newState.bottomItemType = itemType
            
        case .setIsAccountsReceivable(let isReceivable):
            newState.isAccountsReceivable = isReceivable
            
        case .setIsCharging(let isCharging):
            newState.isCharging = isCharging
            
        case .setChargePrice:
            newState.isShowChargePrice = true
            
        case .hasEVPayCard(let hasEVPayCard):
            newState.hasEVPayCard = hasEVPayCard
            
        case .openBottomEvPayTooltip:
            newState.isShowBottomEvPayToolTip = true
            
        case .none:
            break
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
    
    private func convertToChargingData(with result: ApiResult<Data, ApiError>) -> ChargingData? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog("--> convertToChargingData \(jsonData), \(jsonData["pay_code"])")
            let code = jsonData["code"]
            let payCode = jsonData["pay_code"].intValue
            
            // setChargingID용
            Observable.just(MainReactor.Action.setIsCharging(code == 1000))
                .bind(to: self.action)
                .disposed(by: disposeBag)
            
            switch (code, PaymentStatus(rawValue: payCode)) {
            case (_, .PAY_DEBTOR_USER) :  // 미수금
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
    
    private func setPaymentStatus(with result: ApiResult<Data, ApiError>) -> Mutation  {
        switch result {
        case .success(let data):
            let json = JSON(data)
            let payCode = json["pay_code"].intValue
                        
            switch PaymentStatus(rawValue: payCode) {
            case .PAY_DEBTOR_USER:   // 미수금
                Observable.just(MainReactor.Action.setIsAccountsReceivable(true))
                    .bind(to: self.action)
                    .disposed(by: disposeBag)
                                
            case .PAY_NO_USER, .PAY_NO_CARD_USER, .PAY_NO_VERIFY_USER, .PAY_DELETE_FAIL_USER:
                // 미등록,         카드 미등록,         인증되지 않은 유저 (해커의심),  비정상 삭제 멤버
                Observable.just(MainReactor.Action.hasEVPayCard(false))
                    .bind(to: self.action)
                    .disposed(by: disposeBag)
                

            default: break
            }
            
        case .failure(let error):
            printLog(out: "Error Message : \(error)")
        }
        
        return .none
    }
    
    private func convertToEVPayShowType(with result: ApiResult<Data, ApiError>) -> EVPayShowType? {
        switch result {
        case .success(let data):
            let json = JSON(data)
            let payCode = json["pay_code"].intValue
            
            switch PaymentStatus(rawValue: payCode) {
            case .PAY_FINE_USER:    // 유저체크
                return .evPayManagement
                
            case .PAY_DEBTOR_USER:   // 미수금
                Observable.just(MainReactor.Action.setIsAccountsReceivable(true))
                    .bind(to: self.action)
                    .disposed(by: disposeBag)
                
                return .accountsReceivable
                
            case .PAY_NO_USER, .PAY_NO_CARD_USER, .PAY_NO_VERIFY_USER, .PAY_DELETE_FAIL_USER:
                // 미등록,         카드 미등록,         인증되지 않은 유저 (해커의심),  비정상 삭제 멤버
                return .evPayGuide

            default:
                printLog(out: "Error Message : PaymentStatus")
                Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
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
        
        // 예외상황 표기
        var specificValue: (icon: UIImage, title: String)? {
            switch self {
            case .qrCharging:   // 충전중
                return (Icons.icLineCharging.image, "충전중")

            case .evPay:        // 미수금
                return (Icons.iconEvpay.image, "EV Pay 신청")

            default:
                return nil
            }
        }
        
        // 미수금
        var accountsReceivableIcon: UIImage? {
            guard self == .evPay else { return nil }
            
            return Icons.iconEvpayNew.image
        }

        private var actionValue: (action: MainReactor.Action, logoutAplitudeMSG: String?) {
            switch self {
            case .qrCharging:
                return (MainReactor.Action.actionBottomQR, "QR충전")
                
            case .community:
                return (MainReactor.Action.actionBottomMenu(.community), nil)
                
            case .favorite:
                return (MainReactor.Action.actionBottomMenu(.favorite), "즐겨찾기 리스트/버튼")
                
            case .evPay:
                // 앰플리튜드 설정 필요한지 확인해야함. "EV Pay 관리" 임의로 문구 넣어둔것.
                return (MainReactor.Action.actionEVPay, "EV Pay 관리")
             
            }
        }
        
        func action(reactor: MainReactor, provider: SoftberryAPI) {
            switch self {
            case .community:
                Observable.just(actionValue.action)
                    .bind(to: reactor.action)
                    .disposed(by: reactor.disposeBag)
                
            default:
                MemberManager.shared.tryToLoginCheck { isLogin in
                    if isLogin {
                        Observable.just(actionValue.action)
                            .bind(to: reactor.action)
                            .disposed(by: reactor.disposeBag)
                    } else {    // 비로그인시 로그인 플로우 확인용
                        AmplitudeEvent.shared.setFromViewDesc(fromViewDesc: actionValue.logoutAplitudeMSG ?? String())
                        MemberManager.shared.showLoginAlert()
                    }
                }
            }
        }
        
    }
    
    enum ChargeShowType {
        case charging
        case none
        case accountsReceivable
        case leave
    }
    
    enum EVPayShowType {
        case evPayGuide         // 신규, 미참여, gs사용유저
        case evPayManagement    // 결제카드 없고 회원카드 있는사람, 그냥 있는 사람.
        case accountsReceivable // 미수금.
    }

}

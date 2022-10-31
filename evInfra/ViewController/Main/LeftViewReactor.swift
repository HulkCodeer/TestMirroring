//
//  LeftViewReactor.swift
//  evInfra
//
//  Created by 박현진 on 2022/08/08.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

protocol LeftViewReactorDelegate: AnyObject {
    func completeResiterMembershipCard()
    func completeRegisterPayCard()
}

protocol MoveSmallCategoryView {
    var mediumCategory: LeftViewReactor.MediumCategoryType { get set }
    var smallMenuList: [String] { get set }
    func moveViewController(index: IndexPath)
}

internal final class LeftViewReactor: ViewModel, Reactor {
    enum Action {
        case changeMenuCategoryType(MenuCategoryType)
        case getMyBerryPoint
        case refreshBerryPoint
        case setIsAllBerry(Bool)
        case loadPaymentStatus
        case isAllBerryReload
    }
    
    enum Mutation {
        case setMenuCategoryType(MenuCategoryType)
        case setMyBerryPoint(String)
        case setIsAllBerry(Bool)
        case setIsAllBerryReload(Bool)
        case firstLoadIsAllBerry(Bool)
        case empty
    }
    
    struct State {
        var menuCategoryType: MenuCategoryType = .mypage
        var myBerryPoint: String = "0"
        var isAllBerry: Bool = false
    }
    
    internal var initialState: State

    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .changeMenuCategoryType(let menuCategoryType):
            return .just(.setMenuCategoryType(menuCategoryType))
            
        case .getMyBerryPoint:
            return .concat([ self.provider.postMyBerryPoint()
                .observe(on: self.backgroundScheduler)
                .convertData()
                .compactMap(convertToData)
                .map { pointModel in
                    return .setMyBerryPoint(pointModel.displayPoint)
                },
             self.provider.postGetIsAllBerry()
                .observe(on: self.backgroundScheduler)
                .convertData()
                .compactMap(convertToIsUseAllBerry)
                .map { isAll in
                    return .firstLoadIsAllBerry(isAll)
                }
            ])
            
        case .refreshBerryPoint:
            return self.provider.postMyBerryPoint()
                .observe(on: self.backgroundScheduler)
                .convertData()
                .compactMap(convertToData)
                .map { pointModel in
                    return .setMyBerryPoint(pointModel.displayPoint)
                }
            
        case .setIsAllBerry(let isAll):
            return self.provider.postUseAllBerry(isAll: isAll)
                .observe(on: self.backgroundScheduler)
                .convertData()
                .compactMap(convertToIsSuccess)
                .map { isSuccess in
                    return .setIsAllBerry(isAll)
                }
            
        case .loadPaymentStatus:
            return self.provider.postPaymentStatus()
                .convertData()
                .compactMap(convertToPaymentStatus)
                .compactMap { [weak self] isPaymentFineUser in
                    guard let self = self else { return .empty }
                    
                    let _isAllBerry = self.currentState.isAllBerry
                    let hasPayment = isPaymentFineUser
                    let hasMembership = MemberManager.shared.hasMembership
                    switch (hasPayment, hasMembership) {
                        // TEST CODE
//                    switch (true, true) {
                    case (false, false): // 피그마 case 1
                        guard !_isAllBerry else {
                            Observable.just(LeftViewReactor.Action.setIsAllBerry(!_isAllBerry))
                                .bind(to: self.action)
                                .disposed(by: self.disposeBag)
                            return .empty
                        }
                        let popupModel = PopupModel(title: "EV Pay카드를 발급하시겠어요?",
                                                    message: "베리는 EV Pay카드 발급 후\n충전 시 베리로 할인 받을 수 있어요.",
                                                    confirmBtnTitle: "네 발급할게요.", cancelBtnTitle: "다음에 할게요.",
                                                    confirmBtnAction: {
                            AmplitudeEvent.shared.setFromViewDesc(fromViewDesc: "좌측메뉴 상단 베리 팝업")
                            let viewcon = MembershipGuideViewController()
                            GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                        }, textAlignment: .center)
                        
                        let popup = VerticalConfirmPopupViewController(model: popupModel)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                        })
                        
                    case (false, true):
                        let popupModel = PopupModel(title: "결제 카드를 확인해주세요",
                                                    message: "현재 회원님의 결제정보에 오류가 있어\n다음 충전 시 베리를 사용할 수 없어요.",
                                                    confirmBtnTitle: "결제정보 확인하러가기", cancelBtnTitle: "다음에 할게요.",
                                                    confirmBtnAction: {
                            AmplitudeEvent.shared.setFromViewDesc(fromViewDesc: "좌측메뉴 상단 베리 팝업")
                            let viewcon = UIStoryboard(name : "Member", bundle: nil).instantiateViewController(ofType: MyPayinfoViewController.self)
                            viewcon.delegate = self
                            GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                            
                        }, textAlignment: .center)
                                                
                        let popup = VerticalConfirmPopupViewController(model: popupModel)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                        })
                        
                    case (true, false): // 피그마 case 3
                        guard !_isAllBerry, !UserDefault().readBool(key: UserDefault.Key.IS_SHOW_BERRYSETTING_CASE3_POPUP) else {
                            Observable.just(LeftViewReactor.Action.setIsAllBerry(!_isAllBerry))
                                .bind(to: self.action)
                                .disposed(by: self.disposeBag)
                            return .empty
                        }
                        Observable.just(LeftViewReactor.Action.setIsAllBerry(!_isAllBerry))
                            .bind(to: self.action)
                            .disposed(by: self.disposeBag)
                        
                        UserDefault().saveBool(key: UserDefault.Key.IS_SHOW_BERRYSETTING_CASE3_POPUP, value: true)
                        let popupModel = PopupModel(title: "더 많은 충전소에서\n베리를 적립해보세요!",
                                                    message: "EV Pay카드 발급 시 환경부, 한국전력 등\n더 많은 충전소에서 적립할 수 있어요.",
                                                    confirmBtnTitle: "EV Pay카드 안내 보러가기", cancelBtnTitle: "다음에 할게요.",
                                                    confirmBtnAction: {
                            AmplitudeEvent.shared.setFromViewDesc(fromViewDesc: "좌측메뉴 상단 베리 팝업")
                            let viewcon = MembershipGuideViewController()
                            GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                        }, textAlignment: .center)
                        
                        let popup = VerticalConfirmPopupViewController(model: popupModel)
                        GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                        
                    case (true, true): // 피그마 case 4
                        Observable.just(LeftViewReactor.Action.setIsAllBerry(!_isAllBerry))
                            .bind(to: self.action)
                            .disposed(by: self.disposeBag)
                        
//                    default:
//                        Observable.just(LeftViewReactor.Action.loadPaymentStatus)
//                            .bind(to: self.action)
//                            .disposed(by: self.disposeBag)
                    }
                    
                    return .empty
                }
            
        case .isAllBerryReload:
            return self.provider.postGetIsAllBerry()
                .observe(on: self.backgroundScheduler)
                .convertData()
                .compactMap(convertToIsUseAllBerry)
                .map { isAll in
                    return .setIsAllBerryReload(isAll)
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
                                
        switch mutation {
        case .setMenuCategoryType(let menuCategoryType):
            newState.menuCategoryType = menuCategoryType
            
        case .setMyBerryPoint(let point):
            newState.myBerryPoint = point
            
        case .setIsAllBerry(let isAll):
            newState.isAllBerry = isAll
            
            guard isAll else { return newState}
            let message = "0".equals(self.currentState.myBerryPoint) ? "베리가 적립되면 다음 충전 시 베리가 자동으로 전액 사용됩니다." : "다음 충전 후 결제 시 베리가 전액 사용됩니다."
            Snackbar().show(message: "\(message)")
            
        case .firstLoadIsAllBerry(let isAll):
            newState.isAllBerry = isAll
                                                    
        case .setIsAllBerryReload(let isAll):
            newState.isAllBerry = isAll
            
        case .empty: break
        }
        return newState
    }
    
    private func convertToPaymentStatus(with result: ApiResult<Data, ApiError>) -> Bool {
        switch result {
        case .success(let data):
            let json = JSON(data)
                        
            let payCode = json["pay_code"].intValue
                  
            switch PaymentStatus(rawValue: payCode) {
            case .PAY_FINE_USER:
                return true
                                                            
            case .PAY_NO_USER, .PAY_NO_CARD_USER, .PAY_NO_VERIFY_USER, .PAY_DELETE_FAIL_USER:
                return false
                                                                                                                               
            case .PAY_DEBTOR_USER: // 돈안낸 유저
                return true
                                                                            
            default: return false
            }
                                        
        case .failure(let errorMessage):
            printLog(out: "error: \(errorMessage)")
            Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            return false
        }
    }
    
    private func convertToData(with result: ApiResult<Data, ApiError> ) -> MyBerryPointModel? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            let myBerryPointModel = MyBerryPointModel(jsonData)
            printLog(out: "JsonData : \(jsonData)")
                        
            guard myBerryPointModel.code == 1000 else {
                return nil
            }
            
            return myBerryPointModel
            
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            return nil
        }
    }
    
    private func convertToIsSuccess(with result: ApiResult<Data, ApiError> ) -> Bool? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
                        
            guard jsonData["code"] == 1000 else {
                return nil
            }
            
            return true
            
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            return nil
        }
    }
    
    private func convertToIsUseAllBerry(with result: ApiResult<Data, ApiError> ) -> Bool? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
                        
            guard jsonData["code"] == 1000 else {
                return nil
            }
            
            return jsonData["use_point"].intValue == -1
            
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            return nil
        }
    }
    
    struct MyBerryPointModel {
        var code: Int
        var usePoint: String
        var point: String
        var displayPoint: String
        
        init(_ json: JSON) {
            self.code = json["code"].intValue
            self.usePoint = json["use_point"].stringValue
            self.point = json["point"].stringValue
            self.displayPoint = json["point"].intValue.toPrice()
        }
    }

    enum MediumCategoryType: String {
        case mypage = "내 활동"
        case pay = "EV Pay"
        
        case generalCommunity = "커뮤니티"
        case partnershipCoummunity = "제휴 커뮤니티"
        
        case event = "이벤트/쿠폰"
        
        case evInfo = "전기차 정보"
        
        case batteryInfo = "배터리 진단 정보"
        
        case settings = "설정"
    }
    
    enum MenuCategoryType: Int, CaseIterable {
        typealias MenuList = MoveSmallCategoryView
        
        case mypage = 0
        case community = 1
        case event = 2
        case evinfo = 3
        case battery = 4
        case settings = 5
        
        init(menuIndex: Int) {
            switch menuIndex {
            case 0: self = .mypage
            case 1: self = .community
            case 2: self = .event
            case 3: self = .evinfo
            case 4: self = .battery
            case 5: self = .settings
            default: self = .mypage
            }
        }
        
        internal var menuImgView: UIImage {
            switch self {
            case .mypage: return Icons.iconUserLg.image
            case .community: return Icons.iconCommentLg.image
            case .event: return Icons.iconGiftLg.image
            case .evinfo: return Icons.iconEvLg.image
            case .battery: return Icons.iconBattery.image
            case .settings: return Icons.iconSettingLg.image
            }
        }
        
        internal var menuTitle: String {
            switch self {
            case .mypage: return "마이페이지"
            case .community: return "커뮤니티"
            case .event: return "이벤트"
            case .evinfo: return "전기차 정보"
            case .battery: return "배터리 정보"
            case .settings: return "설정"
            }
        }
                
        internal var menuList: [MenuList] {
            switch self {
            case .mypage:
                return [MyPage(), Pay()]
                
            case .community:
                return [GeneralCommunity(), PartnershipCommunity()]
                
            case .event:
                return [Event()]
                
            case .evinfo:
                return [EvInfo()]
                
            case .battery:
                return [BatteryInfo()]
                
            case .settings:
                return [Settings()]
                
            }
        }
    }
    
    struct Settings: MoveSmallCategoryView {
        var mediumCategory: MediumCategoryType = MediumCategoryType.settings
        var smallMenuList: [String] = ["전체 설정", "자주묻는 질문", "이용 안내", "버전 정보"]
                
        func moveViewController(index: IndexPath) {
            switch index.row {
            case 0: // 전체 설정
                let reactor = SettingsReactor(provider: RestApi())
                let viewcon = NewSettingsViewController(reactor: reactor)
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                
            case 1: // 자주묻는 질문
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let termsVC = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
                termsVC.tabIndex = .faqTop
                GlobalDefine.shared.mainNavi?.push(viewController: termsVC)
            
            case 2:
                let loginStoryboard = UIStoryboard(name : "Login", bundle: nil)
                let guideVC = loginStoryboard.instantiateViewController(ofType: ServiceGuideViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: guideVC)

            default: break
            }
        }
    }
    
    struct BatteryInfo: MoveSmallCategoryView {
        var mediumCategory: MediumCategoryType = MediumCategoryType.batteryInfo
        var smallMenuList: [String] = ["내 차 배터리 관리"]
        
        func moveViewController(index: IndexPath) {
            Server.getBatteryJwt(completion: {(isSuccess, response) in
                if isSuccess {
                    let json = JSON(response)
                    if json["code"].stringValue.elementsEqual("1000") {
                        let accessToken = json["access_token"].stringValue
                        if !accessToken.isEmpty {
                            let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                            let termsVC = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
                            termsVC.tabIndex = .BatteryInfo
                            termsVC.setHeader(key: "Authorization", value: "Bearer " + accessToken)
                            GlobalDefine.shared.mainNavi?.push(viewController: termsVC)
                        } else {
                            Snackbar().show(message: "인증실패")
                        }
                    } else {
                        Snackbar().show(message: "인증실패")
                    }
                } else {
                    Snackbar().show(message: "인증실패")
                }
            })
        }
    }
    
    struct EvInfo: MoveSmallCategoryView {
        var mediumCategory: MediumCategoryType = MediumCategoryType.evInfo
        var smallMenuList: [String] = ["전기차 정보", "충전기 정보", "보조금 안내", "보조금 현황", "충전요금 안내"]
        
        func moveViewController(index: IndexPath) {
            switch index.row {
            case 0: // 전기차 정보
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let evInfoVC = infoStoryboard.instantiateViewController(ofType: EvInfoViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: evInfoVC)
            case 1: // 충전기 정보
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let chargerInfoVC = infoStoryboard.instantiateViewController(ofType: ChargerInfoViewController.self)
                // ChargerInfoViewController 자체 animation 사용
                GlobalDefine.shared.mainNavi?.push(viewController: chargerInfoVC)
            case 2: // 보조금 안내
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let bojoInfoVC = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
                bojoInfoVC.tabIndex = .EvBonusGuide
                GlobalDefine.shared.mainNavi?.push(viewController: bojoInfoVC)
            
            case 3: // 보조금 현황
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let bojoDashVC = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
                bojoDashVC.tabIndex = .EvBonusStatus
                GlobalDefine.shared.mainNavi?.push(viewController: bojoDashVC)
                
            case 4: // 충전요금 안내
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let priceInfoVC = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
                priceInfoVC.tabIndex = .priceInfo
                GlobalDefine.shared.mainNavi?.push(viewController: priceInfoVC)
                
            default: break
            }
        }
    }
    
    struct Event: MoveSmallCategoryView {
        var mediumCategory: MediumCategoryType = MediumCategoryType.event
        var smallMenuList: [String] = ["이벤트", "내 쿠폰함"]
        
        func moveViewController(index: IndexPath) {
            switch index.row {
            case 0: // 이벤트
                let eventStoryboard = UIStoryboard(name : "Event", bundle: nil)
                let eventBoardVC = eventStoryboard.instantiateViewController(ofType: EventViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: eventBoardVC)
            case 1: // 내 쿠폰함
                MemberManager.shared.tryToLoginCheck { isLogin in
                    if isLogin {
                        let couponStoryboard = UIStoryboard(name : "Coupon", bundle: nil)
                        let coponVC = couponStoryboard.instantiateViewController(ofType: MyCouponViewController.self)
                        GlobalDefine.shared.mainNavi?.push(viewController: coponVC)
                    }else {
                        MemberManager.shared.showLoginAlert()
                    }
                }
                
            default: break
            }
        }
    }
    
    struct PartnershipCommunity: MoveSmallCategoryView {
        var mediumCategory: MediumCategoryType = MediumCategoryType.partnershipCoummunity
        var smallMenuList: [String] = Board.sharedInstance.getBoardTitleList()
        
        func moveViewController(index: IndexPath) {
            let title: String = smallMenuList[index.row]
            if !title.isEmpty {
                if let boardInfo = Board.sharedInstance.getBoardNewInfo(title: title) {
                    UserDefault().saveInt(key: boardInfo.shardKey!, value: boardInfo.brdId!)
                    let viewcon = CardBoardViewController()
                    viewcon.category = Board.CommunityType.getCompanyType(key: boardInfo.shardKey ?? "")
                    viewcon.bmId = boardInfo.bmId!
                    viewcon.brdTitle = title
                    viewcon.mode = Board.ScreenType.FEED
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                }
            }
        }
    }
        
    struct GeneralCommunity: MoveSmallCategoryView {
        var mediumCategory: MediumCategoryType = MediumCategoryType.generalCommunity
        var smallMenuList: [String] = ["공지사항", "자유게시판", "충전소 게시판"]
        
        func moveViewController(index: IndexPath) {
            switch index.row {
            case 0: // 공지사항
                let reactor = NoticeReactor(provider: RestApi())
                let noticeVC = NewNoticeViewController(reactor: reactor)
                GlobalDefine.shared.mainNavi?.push(viewController: noticeVC)

            
            case 1: // 자유 게시판
                UserDefault().saveInt(key: UserDefault.Key.LAST_FREE_ID, value: Board.sharedInstance.freeBoardId)
                
                let viewcon = CardBoardViewController()
                viewcon.category = Board.CommunityType.FREE
                viewcon.mode = Board.ScreenType.FEED
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
            
            case 2: // 충전소 게시판
                UserDefault().saveInt(key: UserDefault.Key.LAST_CHARGER_ID, value: Board.sharedInstance.chargeBoardId)
                
                let viewcon = CardBoardViewController()
                viewcon.category = Board.CommunityType.CHARGER
                viewcon.mode = Board.ScreenType.FEED
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                
            default: break
            }
        }
    }
    
    struct MyPage: MoveSmallCategoryView {
        var mediumCategory: MediumCategoryType = MediumCategoryType.mypage
        var smallMenuList: [String] = ["내가 쓴 글 보기", "충전소 제보내역"]
        
        func moveViewController(index: IndexPath) {
            MemberManager.shared.tryToLoginCheck { isLogin in
                if isLogin {
                    switch index.row {
                    case 0: // 내가 쓴 글 보기
                        var myWritingControllers = [MyWritingViewController]()
                        let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
                        let freeMineVC = boardStoryboard.instantiateViewController(ofType: MyWritingViewController.self)
                        freeMineVC.boardCategory = Board.CommunityType.FREE
                        freeMineVC.screenType = .LIST
                                            
                        let chargerMineVC = boardStoryboard.instantiateViewController(ofType: MyWritingViewController.self)
                        chargerMineVC.boardCategory = Board.CommunityType.CHARGER
                        chargerMineVC.screenType = .FEED
                        
                        myWritingControllers.append(chargerMineVC)
                        myWritingControllers.append(freeMineVC)
                        
                        let tabsController = AppTabsController(viewControllers: myWritingControllers)
                        tabsController.customNavi.naviTitleLbl.text = "내가 쓴 글 보기"
                        for controller in myWritingControllers {
                            tabsController.appTabsControllerDelegates.append(controller)
                        }
                        GlobalDefine.shared.mainNavi?.push(viewController: tabsController)
                    
                    case 1: // 충전소 제보 내역
                        let reportStoryboard = UIStoryboard(name : "Report", bundle: nil)
                        let reportVC = reportStoryboard.instantiateViewController(ofType: ReportBoardViewController.self)
                        GlobalDefine.shared.mainNavi?.push(viewController: reportVC)

                    default: break
                    }
                } else {
                    switch index.row {
                    case 0: // 내가 쓴 글 보기
                        AmplitudeEvent.shared.setFromViewDesc(fromViewDesc: "내가 쓴 글 보기 메뉴")
                        
                    case 1: // 충전소 제보 내역
                        AmplitudeEvent.shared.setFromViewDesc(fromViewDesc: "층전소 제보 내역 메뉴")
                        
                    default: break
                    }
                    
                    MemberManager.shared.showLoginAlert()
                }
            }
        }
    }
    
    struct Pay: MoveSmallCategoryView {
        var mediumCategory: MediumCategoryType = MediumCategoryType.pay
        var smallMenuList: [String] = ["결제카드 관리", "회원카드 관리", "렌터카 정보 등록" , "충전이력 조회"]
        
        func moveViewController(index: IndexPath) {
            MemberManager.shared.tryToLoginCheck { isLogin in
                if isLogin {
                    switch index.row {
                    case 0: // 개인정보 관리
                        AmplitudeEvent.shared.setFromViewDesc(fromViewDesc: "결제 정보 등록 메뉴")
                        let memberStoryboard = UIStoryboard(name : "Member", bundle: nil)
                        let myPayInfoVC = memberStoryboard.instantiateViewController(ofType: MyPayinfoViewController.self)
                        GlobalDefine.shared.mainNavi?.push(viewController: myPayInfoVC)
                
                    case 1: // 회원카드 관리
                        let viewcon: UIViewController
                        if MemberManager.shared.hasMembership {
                            let mbsStoryboard = UIStoryboard(name : "Membership", bundle: nil)
                            viewcon = mbsStoryboard.instantiateViewController(ofType: MembershipCardViewController.self)
                        } else {
                            AmplitudeEvent.shared.setFromViewDesc(fromViewDesc: "EV Pay 카드 신청 메뉴")
                            viewcon = MembershipGuideViewController()
                        }
                        
                        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                        
                    case 2: // 렌탈정보 관리
                        let viewcon = RentalCarCardListViewController()
                        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)

                    case 3: // 충전이력조회
                        let chargeStoryboard = UIStoryboard(name : "Charge", bundle: nil)
                        let chargesVC = chargeStoryboard.instantiateViewController(ofType: ChargesViewController.self)
                        GlobalDefine.shared.mainNavi?.push(viewController: chargesVC)

                    default: break
                    }
                } else {
                    switch index.row {
                    case 0: // 개인정보 관리
                        AmplitudeEvent.shared.setFromViewDesc(fromViewDesc: "결제 정보 등록 메뉴")
                
                    case 1: // 회원카드 관리
                        AmplitudeEvent.shared.setFromViewDesc(fromViewDesc: "EV Pay카드 신청 메뉴")
                        
                    case 2: // 렌탈정보 관리
                        AmplitudeEvent.shared.setFromViewDesc(fromViewDesc: "렌터카 정보 등록 메뉴")

                    case 3: // 충전이력조회
                        AmplitudeEvent.shared.setFromViewDesc(fromViewDesc: "충전이력 조회 메뉴")

                    default: break
                    }
                    
                    MemberManager.shared.showLoginAlert()
                }
            }
        }
    }
}

extension LeftViewReactor: LeftViewReactorDelegate {
    func completeResiterMembershipCard() {
        Observable.just(LeftViewReactor.Action.setIsAllBerry(true))
            .bind(to: self.action)
            .disposed(by: self.disposeBag)
    }
    
    func completeRegisterPayCard() {
        Observable.just(LeftViewReactor.Action.setIsAllBerry(true))
            .bind(to: self.action)
            .disposed(by: self.disposeBag)
    }
}

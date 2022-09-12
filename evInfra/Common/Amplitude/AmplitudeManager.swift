//
//  AmplitudeManager.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/07/20.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Amplitude

internal final class AmplitudeManager {
    // MARK: - Variable
    
    internal static var shared = AmplitudeManager()
    #if DEBUG
    private let apiKey: String = "57bdb148be2db2b5ef49ae6b576fbd15" // Dev Key
//    private let apiKey: String = "5b0c10b3154cb361b516ea64682d2f8b" // Staging Key
    #else
    private let apiKey: String = "f22b183357026eaed8bbe215e0bbf0a1" // Release Key
    #endif
    
    private var eventProperty: EventProperty?
    private let identify = AMPIdentify()
    
    // MARK: - Initializers
    
    init() {
        Amplitude.instance().initializeApiKey(apiKey)
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().setUserId(nil)
    }
    
    internal func createEventType(type: EventProperty) -> EventProperty {
        self.eventProperty = type
        return type
    }
    
    // MARK: - Event Function
    
    internal func setUser(with id: String?) {
        Amplitude.instance().setUserId(id)
        // 로그인 했을 경우 -> user_id = mb_id
        // 로그인 안했을 경우 -> user_id = null
    }
    
    // MARK: - UserProperty
    private func setUserProperty() {
        identify.set("membership card", value: MemberManager.shared.hasMembership as NSObject)
        identify.set("signup", value: (MemberManager.shared.mbId > 0 ? true : false) as NSObject)
        identify.set("signup date", value: MemberManager.shared.regDate as NSObject)
        identify.set("berry owned", value: MemberManager.shared.berryPoint as NSObject)
        identify.set("favorite station count", value: NSString(string: ""))
        identify.set("gender", value: MemberManager.shared.gender as NSObject)
        identify.set("age range", value: MemberManager.shared.ageRange as NSObject)
        identify.set("push allowed", value: MemberManager.shared.isAllowNoti as NSObject)
        identify.set("push allowed jeju", value: MemberManager.shared.isAllowJejuNoti as NSObject)
        identify.set("push allowed marketing", value: MemberManager.shared.isAllowMarketingNoti as NSObject)
        
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().identify(self.identify)
        }
    }
    
    // MARK: - UserProperty: 즐겨찾기 충전소 개수 세팅
    internal func setUserProperty(with countOfFavoriteList: Int) {
        identify.set("favorite station count", value: NSString(string: String(countOfFavoriteList)))

        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().identify(self.identify)
        }
    }
            
    // MARK: 카카오, 애플 로그인
    internal func loginEvent() {
        let property: [String: Any] = ["type": String(MemberManager.shared.loginType.description)]
        self.setUser(with: "\(MemberManager.shared.mbId)")
        self.setUserProperty()
        self.eventProperty?.logEvent(property: property)
    }
    
    // MARK: 법인 로그인
    internal func corpLoginEvent() {
        let property: [String: Any] = ["type": String(MemberManager.shared.loginType.description)]
        self.setUser(with: "\(MemberManager.shared.mbId)")
        self.eventProperty?.logEvent(property: property)
    }
}

// MARK: - 화면별 이벤트 이름
internal enum EventType {
    case login(EventProperty)
    case signup(EventProperty)
    case map(EventProperty)
    case route(EventProperty)
    case detail(EventProperty)
    case payment(EventProperty)
    case promotion(EventProperty)
    case filter(EventProperty)
    case search(EventProperty)
    case myReports(EventProperty)
    case reports(EventProperty)
    case board(EventProperty)
    
    var eventName: String {
        switch self {
        case .login(let event): return event.toProperty
        case .signup(let event): return event.toProperty
        case .map(let event): return event.toProperty
        case .route(let event): return event.toProperty
        case .detail(let event): return event.toProperty
        case .payment(let event): return event.toProperty
        case .promotion(let event): return event.toProperty
        case .filter(let event): return event.toProperty
        case .search(let event): return event.toProperty
        case .myReports(let event): return event.toProperty
        case .reports(let event): return event.toProperty
        case .board(let event): return event.toProperty
        }
    }
}

protocol EventProperty {
    var toProperty: String { get }
    func logEvent()
    func logEvent(property: [String: Any])
}

// 회원가입 이벤트
internal enum SignUpEvent: String, EventProperty {
    case clickSignUpButton = "click_signup_button"
    case completeSignUp = "complete_signup"
    
    internal var toProperty: String {
        return self.rawValue
    }
    
    func logEvent() {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty)
        }
    }
    
    func logEvent(property: [String : Any]) {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty, withEventProperties: property)
        }
    }
}

// 내가 쓴 글/나의 제보 내역 이벤트
internal enum MyReportsEvent: String, EventProperty {
    case viewMyPost = "view_my_post"
    case viewMyReports = "view_my_reports"
    
    internal var toProperty: String {
        return self.rawValue
    }
    
    func logEvent() {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty)
        }
    }
    
    func logEvent(property: [String : Any]) {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty, withEventProperties: property)
        }
    }
}

// 충전소 제보 이벤트
internal enum ReportsEvent: String, EventProperty  {
    case clickStationReport = "click_station_report"
    case clickStationCompleteReport = "click_station_complete_report"
    
    internal var toProperty: String {
        return self.rawValue
    }
    
    func logEvent() {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty)
        }
    }
    
    func logEvent(property: [String : Any]) {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty, withEventProperties: property)
        }
    }
}

// 로그인 이벤트
internal enum LoginEvent: String, EventProperty {
    case clickLoginButton = "click_login_button"
    case complteLogin = "complete_login"
            
    internal var toProperty: String {
        return self.rawValue
    }
    
    func logEvent() {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty)
        }
    }
    
    func logEvent(property: [String : Any]) {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty, withEventProperties: property)
        }
    }
}

// 지도화면 이벤트
internal enum MapEvent: String, EventProperty {
    case viewMainPage = "view_main_page"
    case clickMyLocation = "click_my_location"
    case clickRenew = "click_renew"
    case viewStationSummarized = "view_station_summarized"
    case viewChargingPriceInfo = "view_charging_price_info"
    case clickStationAddFavorite = "click_station_add_favorite"
    case clickStationCancelFavorite = "click_station_cancel_favorite"
    case clickFavoriteStationAlarm = "click_favorite_station_alarm"
    case clickGoingToCharge = "click_going_to_charge"
    case clickGoingToChargeCancel = "click_going_to_charge_cancel"
    case viewFavorites = "view_favorites"
    
    internal var toProperty: String {
        return self.rawValue
    }
    
    func logEvent() {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty)
        }
    }
    
    func logEvent(property: [String : Any]) {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty, withEventProperties: property)
        }
    }
}

// 경로찾기 이벤트
internal enum RouteEvent: String, EventProperty {
    case clickStationSelectStarting = "click_station_select_starting"
    case clickStationSelectTransit = "click_station_select_transit"
    case clickStationSelectDestination = "click_station_select_destination"
    case clickNavigation = "click_navigation"
    case clickNavigationFindway = "click_navigation_find_way"
    case clickStationStartNavigaion = "click_station_start_navigation"
    case inputNavigationStartingPoint = "input_navigation_starting_point"
    case inputNavigationDestination = "input_navigation_destination"
    
    internal var toProperty: String {
        return self.rawValue
    }
    
    func logEvent() {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty)
        }
    }
    
    func logEvent(property: [String : Any]) {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty, withEventProperties: property)
        }
    }
}

// 충전소 이벤트
internal enum ChargerStationEvent: String, EventProperty {
    case viewStationDetail = "view_station_detail"
    case clickStationChargingPrice = "click_station_charging_price"
    case clickStationSatelliteView = "click_station_satellite_view"
    case viewStationReview = "view_station_review"
    
    internal var toProperty: String {
        return self.rawValue
    }
    
    func logEvent() {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty)
        }
    }
    
    func logEvent(property: [String : Any]) {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty, withEventProperties: property)
        }
    }
}

// 결제 이벤트
internal enum PaymentEvent: String, EventProperty {
    case viewMyBerry = "view_my_berry"
    case clickSetUpBerry = "click_set_up_berry"
    case clickResetBerry = "click_reset_berry"
    case clickAddPaymentCard = "click_add_payment_card"
    case completePaymentCard = "complete_payment_card"
    case clickApplyEVICard = "click_apply_EVI_card"
    case completeApplyEVICard = "complete_apply_EVI_card"
    case clickApplyAllianceCard = "click_apply_alliance_card"
    case completeApplyAllianceCard = "complete_apply_alliance_card"
    
    internal var toProperty: String {
        return self.rawValue
    }
    
    func logEvent() {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty)
        }
    }
    
    func logEvent(property: [String : Any]) {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty, withEventProperties: property)
        }
    }
}

// 이벤트/광고/배너 이벤트
internal enum PromotionEvent: String, EventProperty {
    case clickEvent = "click_event"
    case clickBanner = "click_banner"
    case clickCloseBanner = "click_close_banner"
    
    internal var toProperty: String {
        return self.rawValue
    }
    
    func logEvent() {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty)
        }
    }
    
    func logEvent(property: [String : Any]) {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty, withEventProperties: property)
        }
    }
}

// 필터 이벤트
internal enum FilterEvent: String, EventProperty {
    case viewFilter = "view_filter"
    case clickFilterCancel = "click_filter_cancel"
    case clickFilterReset = "click_filter_reset"
    case clickFilterSave = "click_filter_save"
    case clickUpperFilter = "click_upper_filter"
    
    internal var toProperty: String {
        return self.rawValue
    }
    
    func logEvent() {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty)
        }
    }
    
    func logEvent(property: [String : Any]) {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty, withEventProperties: property)
        }
    }
}

// 검색 이벤트
internal enum SearchEvent: String, EventProperty {
    case clickSearchChooseStation = "click_search_choose_station"
    
    internal var toProperty: String {
        return self.rawValue
    }
    
    func logEvent() {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty)
        }
    }
    
    func logEvent(property: [String : Any]) {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty, withEventProperties: property)
        }
    }
}

// 게시판 이벤트
internal enum BoardEvent: String, EventProperty {
    case viewBoardPost = "view_board_post"
    case clickWriteBoardPost = "click_write_board_post"
    case completeWriteBoardPost = "complete_write_board_post"
    case viewNotice = "view_notice"
    case viewFAQ = "view_FAQ"
         
    internal var toProperty: String {
        return self.rawValue
    }
    
    func logEvent() {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty)
        }
    }
    
    func logEvent(property: [String : Any]) {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty, withEventProperties: property)
        }
    }
}


// MARK: - 화면 진입 이벤트(view_enter) 프로퍼티 이름
internal enum EnterViewType: String, EventProperty {
    case paymentQRScanViewController = "QR Scan 화면"
    case paymentStatusViewController = "충전 진행 상태 화면"
    case paymentResultViewController = "충전 완료 화면"
    case noticeViewController = "공지사항 화면"
    case eventViewController = "이벤트 리스트 화면"
    case registerResultViewController = "롯데렌터카/SK렌터카 인증 완료/실패 화면"
    case lotteRentInfoViewController = "롯데렌터카 내카드 정보"
    case rentalCarCardListViewController = "롯데렌터카/SK렌터카 회원카드 목록 화면"
    case membershipQRViewController = "SK렌터카 카드 QR scan 화면"
    case lotteRentCertificateViewController = "롯데렌터카 등록 화면"
    case repayListViewController = "미수금 결제 내역 화면"
    case myPayinfoViewController = "결제정보관리 화면"
    case repayResultViewController = "미수금 결제 완료 화면"
    case myPayRegisterViewController = "결제 정보 등록 화면"
    case myPageViewController = "개인정보관리 화면"
    case quitAccountCompleteViewController = "회원탈퇴 완료 화면"
    case quitAccountReasonQuestionViewController = "회원탈퇴 사유 선택화면"
    case membershipIssuanceViewController = "회원카드 신청 화면"
    case membershipInfoViewController = "회원카드 상세 화면"
    case myCouponViewController = "보유 쿠폰 리스트 화면"
    case myCouponContentsViewController = "보유 쿠폰 상세 화면"
    case membershipCardViewController = "회원카드 관리 화면"
    case chargesViewController = "충전이력 조회 화면"
    case evDetailViewController = "전기차 정보 상세 화면"
    case chargerInfoViewController = "충전기 정보 리스트 화면"
    case membershipReissuanceInfoViewController = "재발급 신청 상세 화면"
    case newSettingsViewController = "설정 화면"
    case findPasswordViewController = "비밀번호 찾기 화면"
    case evInfoViewController = "전기차 정보 리스트 화면"
    case couponCodeViewController = "쿠폰번호 등록 화면"
    case termsViewController = "웹뷰"
    case membershipReissuanceViewController = "재발급 신청 화면"
    case eIImageViewerViewController = "이미지 상세보기 화면"
    case serviceGuideViewController = "이용안내 화면"
    case reportBoardViewController = "나의 제보 내역 화면"
    case boardSearchViewController = "게시판 검색 화면"
    case cardBoardViewController = "게시판 리스트 화면"
    case quitAccountViewController = "회원탈퇴 화면"
    case pointUseGuideViewController = "베리 사용 안내 화면"
    case acceptTermsViewController = "회원 가입 이용약관 동의 화면"
    case membershipUseGuideViewController = "회원카드 사용 안내 화면"
    case membershipGuideViewController = "회원카드 안내 화면"
    case none
    
    init(viewName: String) {
        switch viewName {
        case "PaymentQRScanViewController": self = .paymentQRScanViewController
        case "PaymentStatusViewController": self = .paymentStatusViewController
        case "PaymentResultViewController": self = .paymentResultViewController
        case "NoticeViewController": self = .noticeViewController
        case "EventViewController": self = .eventViewController
        case "RegisterResultViewController": self = .registerResultViewController
        case "LotteRentInfoViewController": self = .lotteRentInfoViewController
        case "RentalCarCardListViewController": self = .rentalCarCardListViewController
        case "MembershipQRViewController": self = .membershipQRViewController
        case "LotteRentCertificateViewController": self = .lotteRentCertificateViewController
        case "RepayListViewController": self = .repayListViewController
        case "MyPayinfoViewController": self = .myPayinfoViewController
        case "RepayResultViewController": self = .repayResultViewController
        case "MyPayRegisterViewController": self = .myPayRegisterViewController
        case "MyPageViewController": self = .myPageViewController
        case "QuitAccountCompleteViewController": self = .quitAccountCompleteViewController
        case "QuitAccountReasonQuestionViewController": self = .quitAccountReasonQuestionViewController
        case "MembershipIssuanceViewController": self = .membershipIssuanceViewController
        case "MembershipInfoViewController": self = .membershipInfoViewController
        case "MyCouponViewController": self = .myCouponViewController
        case "MyCouponContentsViewController": self = .myCouponContentsViewController
        case "MembershipCardViewController": self = .membershipCardViewController
        case "ChargesViewController": self = .chargesViewController
        case "EvDetailViewController": self = .evDetailViewController
        case "ChargerInfoViewController": self = .chargerInfoViewController
        case "MembershipReissuanceInfoViewController": self = .membershipReissuanceInfoViewController
        case "NewSettingsViewController": self = .newSettingsViewController
        case "FindPasswordViewController": self = .findPasswordViewController
        case "EvInfoViewController": self = .evInfoViewController
        case "CouponCodeViewController": self = .couponCodeViewController
        case "TermsViewController": self = .termsViewController
        case "MembershipReissuanceViewController": self = .membershipReissuanceViewController
        case "EIImageViewerViewController": self = .eIImageViewerViewController
        case "ServiceGuideViewController": self = .serviceGuideViewController
        case "ReportBoardViewController": self = .reportBoardViewController
        case "BoardSearchViewController": self = .boardSearchViewController
        case "CardBoardViewController": self = .cardBoardViewController
        case "QuitAccountViewController": self = .quitAccountViewController
        case "PointUseGuideViewController": self = .pointUseGuideViewController
        case "AcceptTermsViewController": self = .acceptTermsViewController
        case "MembershipUseGuideViewController": self = .membershipUseGuideViewController
        case "MembershipGuideViewController": self = .membershipGuideViewController
        default: self = .none
        }
    }
    
    internal var viewNameDesc: String {
        return self.rawValue
    }
    
    internal var toProperty: String {
        return self.rawValue
    }
    
    func logEvent() {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toProperty, withEventProperties:  ["type" : self.viewNameDesc])
        }
    }
    
    func logEvent(property: [String : Any]) {}
}

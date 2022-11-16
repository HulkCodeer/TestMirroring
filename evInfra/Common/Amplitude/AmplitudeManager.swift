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
    private let identify = AMPIdentify()
    
    // MARK: - Initializers
    
    private init() {}
    
    internal func configure(_ apiKey: String) {
        Amplitude.instance().initializeApiKey(apiKey)
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().setUserId(nil)
    }
            
    // MARK: - Event Function
    
    internal func setUser(with id: String?) {
        Amplitude.instance().setUserId(id)
        // 로그인 했을 경우 -> user_id = mb_id
        // 로그인 안했을 경우 -> user_id = null
    }
    
    // MARK: - UserProperty
    fileprivate func setUserProperty() {
        identify.set("membership card", value: MemberManager.shared.hasMembership as NSObject)
        identify.set("signup", value: (MemberManager.shared.mbId > 0 ? true : false) as NSObject)
        identify.set("signup date", value: MemberManager.shared.regDate as NSObject)
        identify.set("berry owned", value: MemberManager.shared.berryPoint as NSObject)
        identify.set("favorite station count", value: NSString(string: ""))
        identify.set("gender", value: MemberManager.shared.gender as NSObject)
        identify.set("age range", value: MemberManager.shared.ageRange as NSObject)
        identify.set("push allowed", value: MemberManager.shared.isAllowNoti as NSObject)
        identify.set("push allowed jeju", value: MemberManager.shared.isAllowJejuNoti as NSObject)
        identify.set("push allowed marketing", value: MemberManager.shared.isAllowMarketingNoti as? NSObject)
        
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
}

protocol EventTypeProtocol {
    var toTypeDesc: String { get }
    func logEvent()
    func logEvent(property: [String: Any])
}

extension EventTypeProtocol {
    func logEvent() {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toTypeDesc)
        }
    }
    
    func logEvent(property: [String : Any]) {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toTypeDesc, withEventProperties: property)
        }
    }
}

// 회원가입 이벤트
internal enum SignUpEvent: String, EventTypeProtocol {
    case clickSignUpButton = "click_signup_button"
    case completeSignUp = "complete_signup"
    
    internal var toTypeDesc: String {
        return self.rawValue
    }
}

// 내가 쓴 글/나의 제보 내역 이벤트
internal enum MyReportsEvent: String, EventTypeProtocol {
    case viewMyPost = "view_my_post"
    case viewMyReports = "view_my_reports"
    
    internal var toTypeDesc: String {
        return self.rawValue
    }
}

// 충전소 제보 이벤트
internal enum ReportsEvent: String, EventTypeProtocol  {
    case clickStationReport = "click_station_report"
    case clickStationCompleteReport = "click_station_complete_report"
    
    internal var toTypeDesc: String {
        return self.rawValue
    }
}

// 로그인 이벤트 (카카오, 애플)
internal enum LoginEvent: String, EventTypeProtocol {
    case clickLoginButton = "click_login_button"
    case complteLogin = "complete_login"
            
    internal var toTypeDesc: String {
        return self.rawValue
    }
    
    func logEvent() {
        DispatchQueue.global(qos: .background).async {
            let property: [String: Any] = ["type": String(MemberManager.shared.loginType.description)]
            AmplitudeManager.shared.setUser(with: "\(MemberManager.shared.mbId)")
            AmplitudeManager.shared.setUserProperty()
            Amplitude.instance().logEvent(self.toTypeDesc, withEventProperties: property)
        }
    }
    
    func logEvent(property: [String : Any]) {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toTypeDesc, withEventProperties: property)
        }
    }
}

// 법인 로그인
internal enum CorpLoginEvent: String, EventTypeProtocol {
    case clickLoginButton = "click_login_button"
    case complteLogin = "complete_login"
            
    internal var toTypeDesc: String {
        return self.rawValue
    }
    
    func logEvent() {
        DispatchQueue.global(qos: .background).async {
            let property: [String: Any] = ["type": Login.LoginType.evinfra.description]
            AmplitudeManager.shared.setUser(with: "\(MemberManager.shared.mbId)")
            self.logEvent(property: property)
        }
    }
    
    func logEvent(property: [String : Any]) {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(self.toTypeDesc, withEventProperties: property)
        }
    }
}

// MARK: 지도화면 이벤트
internal enum MapEvent: String, EventTypeProtocol {
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
    case clickMainNavigationBarEVPay = "click_main_navigation_bar_EVPay"
     
    // AB Test
    case clickMainNavigationBarEVPayAB = "click_main_navigation_bar_EVPay_AB"
    
    internal var toTypeDesc: String {
        return self.rawValue
    }
}

// MARK: 경로찾기 이벤트
internal enum RouteEvent: String, EventTypeProtocol {
    case clickStationSelectStarting = "click_station_select_starting"
    case clickStationSelectTransit = "click_station_select_transit"
    case clickStationSelectDestination = "click_station_select_destination"
    case clickNavigation = "click_navigation"
    case clickNavigationFindway = "click_navigation_find_way"
    case clickStationStartNavigaion = "click_station_start_navigation"
    case inputNavigationStartingPoint = "input_navigation_starting_point"
    case inputNavigationDestination = "input_navigation_destination"
    
    internal var toTypeDesc: String {
        return self.rawValue
    }
}

// MARK: 충전소 이벤트
internal enum ChargerStationEvent: String, EventTypeProtocol {
    case viewStationDetail = "view_station_detail"
    case clickStationChargingPrice = "click_station_charging_price"
    case clickStationSatelliteView = "click_station_satellite_view"
    case viewStationReview = "view_station_review"
    
    internal var toTypeDesc: String {
        return self.rawValue
    }
}

// MARK: 결제 이벤트
internal enum PaymentEvent: String, EventTypeProtocol {
    case viewMyBerry = "view_my_berry"
    case clickSetUpBerry = "click_set_up_berry"
    case clickResetBerry = "click_reset_berry"
    case clickAddPaymentCard = "click_add_payment_card"
    case completePaymentCard = "complete_payment_card"
    case clickApplyEVICard = "click_apply_EVI_card"
    case completeApplyEVICard = "complete_apply_EVI_card"
    case clickApplyAllianceCard = "click_apply_alliance_card"
    case completeApplyAllianceCard = "complete_apply_alliance_card"
    
    internal var toTypeDesc: String {
        return self.rawValue
    }
}

// MARK: 3.7.8 버전 앰플리튜드
internal class AmplitudeEvent {
    internal static let shared = AmplitudeEvent()
    
    private init() {}
    
    enum Event: String, EventTypeProtocol {
        case viewAddPaymentCard = "view_add_payment_card"
        case viewApplyEVICard = "view_apply_EVI_card"
        case viewMyInfo = "view_my_info"
        case clickSidemenuRenewBerry = "click_sidemenu_renew_berry"
        case clickSidemenuSetUpBerryAll = "click_sidemenu_set_up_berry_all"
        case clickSidemenuMyBerry = "click_sidemenu_my_berry"
        case viewLogin = "view_login"
        case viewInfoEVICard = "view_info_EVI_card"
        case none
        
        internal var toTypeDesc: String {
            return self.rawValue
        }
    }
         
    private var fromViewDesc: String = ""
        
    func fromViewDescStr() -> String {
        return fromViewDesc
    }
    
    func setFromViewDesc(fromViewDesc: String) {
        self.fromViewDesc = fromViewDesc
    }
            
    func fromViewSourceByLogEvent(eventType: Event) {
        DispatchQueue.global(qos: .background).async {
            guard !self.fromViewDesc.isEmpty else { return }
            let property: [String: Any] = ["source": "\(self.fromViewDesc)"]
            Amplitude.instance().logEvent(eventType.toTypeDesc, withEventProperties: property)
            self.fromViewDesc = ""
        }
    }    
}

// MARK: 이벤트/광고/배너 이벤트
internal enum PromotionEvent: String, EventTypeProtocol {
    case clickEvent = "click_event"
    case clickBanner = "click_banner"
    case clickCloseBanner = "click_close_banner"
    
    internal var toTypeDesc: String {
        return self.rawValue
    }
}

// 필터 이벤트
internal enum FilterEvent: String, EventTypeProtocol {
    case viewFilter = "view_filter"
    case clickFilterCancel = "click_filter_cancel"
    case clickFilterReset = "click_filter_reset"
    case clickFilterSave = "click_filter_save"
    case clickUpperFilter = "click_upper_filter"    
    
    internal var toTypeDesc: String {
        return self.rawValue
    }
}

// 검색 이벤트
internal enum SearchEvent: String, EventTypeProtocol {
    case clickSearchChooseStation = "click_search_choose_station"
    
    internal var toTypeDesc: String {
        return self.rawValue
    }
}

// 게시판 이벤트
internal enum BoardEvent: String, EventTypeProtocol {
    case viewBoardPost = "view_board_post"
    case clickWriteBoardPost = "click_write_board_post"
    case completeWriteBoardPost = "complete_write_board_post"
    case viewNotice = "view_notice"
    case viewFAQ = "view_FAQ"
         
    internal var toTypeDesc: String {
        return self.rawValue
    }
}


// MARK: - 화면 진입 이벤트(view_enter) 프로퍼티 이름
internal enum EnterViewType: String, EventTypeProtocol {
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
    case repayResultViewController = "미수금 결제 완료 화면"
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
    case none
    
    init() { self = .none }
    
    private init(viewName: String) {
        switch viewName {
        case "PaymentQRScanViewController": self = .paymentQRScanViewController
        case "PaymentStatusViewController": self = .paymentStatusViewController
        case "PaymentResultViewController": self = .paymentResultViewController
        case "NewNoticeViewController": self = .noticeViewController
        case "EventViewController": self = .eventViewController
        case "RegisterResultViewController": self = .registerResultViewController
        case "LotteRentInfoViewController": self = .lotteRentInfoViewController
        case "RentalCarCardListViewController": self = .rentalCarCardListViewController
        case "MembershipQRViewController": self = .membershipQRViewController
        case "LotteRentCertificateViewController": self = .lotteRentCertificateViewController
        case "RepayListViewController": self = .repayListViewController
        case "RepayResultViewController": self = .repayResultViewController
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
        default: self = .none
        }
    }
                
    internal var toTypeDesc: String {
        return self.rawValue
    }
                    
    func viewEnterLogEvent(viewName: String) {
        DispatchQueue.global(qos: .background).async {
            Amplitude.instance().logEvent(viewName, withEventProperties: ["type": EnterViewType(viewName: viewName).toTypeDesc])
        }
    }
}

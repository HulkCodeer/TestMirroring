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
    
    private let identify = AMPIdentify()
    
    // MARK: - Initializers
    
    init() {
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
    internal func setUserProperty() {
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
    
    // MARK: - 로깅 이벤트
    internal func logEvent(type: EventType, property: [String: Any?]?) {
        if let property = property {
            DispatchQueue.global(qos: .background).async {
                Amplitude.instance().logEvent(type.eventName, withEventProperties: property)
            }
        } else {
            DispatchQueue.global(qos: .background).async {
                Amplitude.instance().logEvent(type.eventName)
            }
        }
        
    }
}

// MARK: - 화면별 이벤트 이름
internal enum EventType {
    case enter(EnterEvent)
    case login(LoginEvent)
    case signup(SignUpEvent)
    case map(MapEvent)
    case route(RouteEvent)
    case detail(ChargerStationEvent)
    case payment(PaymentEvent)
    case promotion(PromotionEvent)
    case filter(FilterEvent)
    case search(SearchEvent)
    case myReports(MyReportsEvent)
    case reports(ReportsEvent)
    case board(BoardEvent)
    
    var eventName: String {
        switch self {
        case .enter(let event):
            switch event {
            case .viewEnter: return "view_enter"
            }
        case .login(let event):
            switch event {
            case .clickLoginButton: return "click_login_button"
            case .complteLogin: return "complete_login"
            }
        case .signup(let event):
            switch event {
            case .clickSignUpButton: return "click_signup_button"
            case .completeSignUp: return "complete_signup"
            }
        case .map(let event):
            switch event {
            case .viewMainPage: return "view_main_page"
            case .clickMyLocation: return "click_my_location"
            case .clickRenew: return "click_renew"
            case .viewStationSummarized: return "view_station_summarized"
            case .viewChargingPriceInfo: return "view_charging_price_info"
            case .clickStationAddFavorite: return "click_station_add_favorite"
            case .clickStationCancelFavorite: return "click_station_cancel_favorite"
            case .clickFavoriteStationAlarm: return "click_favorite_station_alarm"
            case .clickGoingToCharge: return "click_going_to_charge"
            case .clickGoingToChargeCancel: return "click_going_to_charge_cancel"
            case .viewFavorites: return "view_favorites"
            }
        case .route(let event):
            switch event {
            case .clickStationSelectStarting: return "click_station_select_starting"
            case .clickStationSelectTransit: return "click_station_select_transit"
            case .clickStationSelectDestination: return "click_station_select_destination"
            case .clickNavigation: return "click_navigation"
            case .clickNavigationFindway: return "click_navigation_find_way"
            case .clickStationStartNavigaion: return "click_station_start_navigation"
            case .inputNavigationStartingPoint: return "input_navigation_starting_point"
            case .inputNavigationDestination: return "input_navigation_destination"
            }
        case .detail(let event):
            switch event {
            case .viewStationDetail: return "view_station_detail"
            case .clickStationChargingPrice: return "click_station_charging_price"
            case .clickStationSatelliteView: return "click_station_satellite_view"
            case .viewStationReview: return "view_station_review"
            }
        case .payment(let event):
            switch event {
            case .viewMyBerry: return "view_my_berry"
            case .clickSetUpBerry: return "click_set_up_berry"
            case .clickResetBerry: return "click_reset_berry"
            case .clickAddPaymentCard: return "click_add_payment_card"
            case .completePaymentCard: return "complete_payment_card"
            case .clickApplyEVICard: return "click_apply_EVI_card"
            case .completeApplyEVICard: return "complete_apply_EVI_card"
            case .clickApplyAllianceCard: return "click_apply_alliance_card"
            case .completeApplyAllianceCard: return "complete_apply_alliance_card"
            }
        case .promotion(let event):
            switch event {
            case .clickEvent: return "click_event"
            case .clickBanner: return "click_banner"
            case .clickCloseBanner: return "click_close_banner"
            }
        case .filter(let event):
            switch event {
            case .viewFilter: return "view_filter"
            case .clickFilterCancel: return "click_filter_cancel"
            case .clickFilterReset: return "click_filter_reset"
            case .clickFilterSave: return "click_filter_save"
            case .clickUpperFilter: return "click_upper_filter"
            }
        case .search(let event):
            switch event {
            case .clickSearchChooseStation: return "click_search_choose_station"
            }
        case .myReports(let event):
            switch event {
            case .viewMyPost: return "view_my_post"
            case .viewMyReports: return "view_my_reports"
            }
        case .reports(let event):
            switch event {
            case .clickStationReport: return "click_station_report"
            case .clickStationCompleteReport: return "click_station_complete_report"
            }
        case .board(let event):
            switch event {
            case .viewBoardPost: return "view_board_post"
            case .clickWriteBoardPost: return "click_write_board_post"
            case .completeWriteBoardPost: return "complete_write_board_post"
            case .viewNotice: return "view_notice"
            }
        }
    }
    
    // 화면진입 이벤트
    internal enum EnterEvent {
        case viewEnter
    }

    // 회원가입 이벤트
    internal enum SignUpEvent {
        case clickSignUpButton
        case completeSignUp
    }
    
    // 내가 쓴 글/나의 제보 내역 이벤트
    internal enum MyReportsEvent {
        case viewMyPost
        case viewMyReports
    }
    
    // 충전소 제보 이벤트
    internal enum ReportsEvent {
        case clickStationReport
        case clickStationCompleteReport
    }
    
    // 로그인 이벤트
    internal enum LoginEvent {
        case clickLoginButton
        case complteLogin
    }
    
    // 지도화면 이벤트
    internal enum MapEvent {
        case viewMainPage
        case clickMyLocation
        case clickRenew
        case viewStationSummarized
        case viewChargingPriceInfo
        case clickStationAddFavorite
        case clickStationCancelFavorite
        case clickFavoriteStationAlarm
        case clickGoingToCharge
        case clickGoingToChargeCancel
        case viewFavorites
    }
    
    // 경로찾기 이벤트
    internal enum RouteEvent {
        case clickStationSelectStarting
        case clickStationSelectTransit
        case clickStationSelectDestination
        case clickNavigation
        case clickNavigationFindway
        case clickStationStartNavigaion
        case inputNavigationStartingPoint
        case inputNavigationDestination
    }
    
    // 충전소 이벤트
    internal enum ChargerStationEvent {
        case viewStationDetail
        case clickStationChargingPrice
        case clickStationSatelliteView
        case viewStationReview
    }
    
    // 결제 이벤트
    internal enum PaymentEvent {
        case viewMyBerry
        case clickSetUpBerry
        case clickResetBerry
        case clickAddPaymentCard
        case completePaymentCard
        case clickApplyEVICard
        case completeApplyEVICard
        case clickApplyAllianceCard
        case completeApplyAllianceCard
    }
    
    // 이벤트/광고/배너 이벤트
    internal enum PromotionEvent {
        case clickEvent
        case clickBanner
        case clickCloseBanner
    }
    
    // 필터 이벤트
    internal enum FilterEvent {
        case viewFilter
        case clickFilterCancel
        case clickFilterReset
        case clickFilterSave
        case clickUpperFilter
    }
    
    // 검색 이벤트
    internal enum SearchEvent {
        case clickSearchChooseStation
    }
    
    // 게시판 이벤트
    internal enum BoardEvent {
        case viewBoardPost
        case clickWriteBoardPost
        case completeWriteBoardPost
        case viewNotice
    }
}

// MARK: - 화면 진입 이벤트(view_enter) 프로퍼티 이름
internal enum ViewName: String, CaseIterable {
    case PaymentQRScanViewController
    case PaymentStatusViewController
    case PaymentResultViewController
    case NoticeViewController
    case EventViewController
    case RegisterResultViewController
    case LotteRentInfoViewController
    case RentalCarCardListViewController
    case MembershipQRViewController
    case LotteRentCertificateViewController
    case RepayListViewController
    case MyPayinfoViewController
    case RepayResultViewController
    case MyPayRegisterViewController
    case MyPageViewController
    case QuitAccountCompleteViewController
    case QuitAccountReasonQuestionViewController
    case MembershipIssuanceViewController
    case MembershipInfoViewController
    case MyCouponViewController
    case MyCouponContentsViewController
    case MembershipCardViewController
    case ChargesViewController
    case EvDetailViewController
    case ChargerInfoViewController
    case MembershipReissuanceInfoViewController
    case NewSettingsViewController
    case FindPasswordViewController
    case EvInfoViewController
    case CouponCodeViewController
    case TermsViewController
    case MembershipReissuanceViewController
    case EIImageViewerViewController
    case ServiceGuideViewController
    case ReportBoardViewController
    case BoardSearchViewController
    case CardBoardViewController
    case QuitAccountViewController
    case PointUseGuideViewController
    case AcceptTermsViewController
    case MembershipUseGuideViewController
    case MembershipGuideViewController
    
    internal var propertyName: String {
        switch self {
        case .PaymentQRScanViewController: return "QR Scan 화면"
        case .PaymentStatusViewController: return "충전 진행 상태 화면"
        case .PaymentResultViewController: return "충전 완료 화면"
        case .NoticeViewController: return "공지사항 화면"
        case .EventViewController: return "이벤트 리스트 화면"
        case .RegisterResultViewController: return "롯데렌터카/SK렌터카 인증 완료/실패 화면"
        case .LotteRentInfoViewController: return "롯데렌터카 내카드 정보"
        case .RentalCarCardListViewController: return "롯데렌터카/SK렌터카 회원카드 목록 화면"
        case .MembershipQRViewController: return "SK렌터카 카드 QR scan 화면"
        case .LotteRentCertificateViewController: return "롯데렌터카 등록 화면"
        case .RepayListViewController: return "미수금 결제 내역 화면"
        case .MyPayinfoViewController: return "결제정보관리 화면"
        case .RepayResultViewController: return "미수금 결제 완료 화면"
        case .MyPayRegisterViewController: return "결제 정보 등록 화면"
        case .MyPageViewController: return "개인정보관리 화면"
        case .QuitAccountCompleteViewController: return "회원탈퇴 완료 화면"
        case .QuitAccountReasonQuestionViewController: return "회원탈퇴 사유 선택화면"
        case .MembershipIssuanceViewController: return "회원카드 신청 화면"
        case .MembershipInfoViewController: return "회원카드 상세 화면"
        case .MyCouponViewController: return "보유 쿠폰 리스트 화면"
        case .MyCouponContentsViewController: return "보유 쿠폰 상세 화면"
        case .MembershipCardViewController: return "회원카드 관리 화면"
        case .ChargesViewController: return "충전이력 조회 화면"
        case .EvDetailViewController: return "전기차 정보 상세 화면"
        case .ChargerInfoViewController: return "충전기 정보 리스트 화면"
        case .MembershipReissuanceInfoViewController: return "재발급 신청 상세 화면"
        case .NewSettingsViewController: return "설정 화면"
        case .FindPasswordViewController: return "비밀번호 찾기 화면"
        case .EvInfoViewController: return "전기차 정보 리스트 화면"
        case .CouponCodeViewController: return "쿠폰번호 등록 화면"
        case .TermsViewController: return "웹뷰"
        case .MembershipReissuanceViewController: return "재발급 신청 화면"
        case .EIImageViewerViewController: return "이미지 상세보기 화면"
        case .ServiceGuideViewController: return "이용안내 화면"
        case .ReportBoardViewController: return "나의 제보 내역 화면"
        case .BoardSearchViewController: return "게시판 검색 화면"
        case .CardBoardViewController: return "게시판 리스트 화면"
        case .QuitAccountViewController: return "회원탈퇴 화면"
        case .PointUseGuideViewController: return "베리 사용 안내 화면"
        case .AcceptTermsViewController: return "회원 가입 이용약관 동의 화면"
        case .MembershipUseGuideViewController: return "회원카드 사용 안내 화면"
        case .MembershipGuideViewController: return "회원카드 안내 화면"
        }
    }
}

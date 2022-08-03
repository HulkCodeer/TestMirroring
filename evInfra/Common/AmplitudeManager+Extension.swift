//
//  AmplitudeManager+Extension.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/08/03.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

// MARK: - Extension
extension AmplitudeManager {
    enum ViewController: String {
        case PaymentQRScanViewController
        case PaymentStatusViewController
        case PaymentResultViewController
        case NoticeContentViewController
        case NoticeViewController
        case EventViewController
        case EventContentsViewController
        case MyWritingViewController
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
        case FavoriteViewController
        case MembershipCardViewController
        case ChargerFilterViewController
        case PreUsePointViewController
        case PointViewController
        case ChargesViewController
        case EvDetailViewController
        case ChargerInfoViewController
        case MainViewController
        case MembershipReissuanceInfoViewController
        case NewSettingsViewController
        case FindPasswordViewController
        case EvInfoViewController
        case CouponCodeViewController
        case TermsViewController
        case SearchViewController
        case MembershipReissuanceViewController
        case EIImageViewerViewController
        case SearchAddressViewController
        case ServiceGuideViewController
        case ReportBoardViewController
        case ReportChargeViewController
        case BoardSearchViewController
        case BoardDetailViewController
        case BoardWriteViewController
        case CardBoardViewController
        case LoginViewController
        case SignUpViewController
        case CorporationLoginViewController
        case DetailViewController
        case QuitAccountViewController
        case PointUseGuideViewController
        case AcceptTermsViewController
        case MembershipUseGuideViewController
        case MembershipGuideViewController
        case AddressToLocationController
        
        internal var propertyName: String {
            switch self {
            case .PaymentQRScanViewController: return "QR Scan 화면"
            case .PaymentStatusViewController: return "충전 진행 상태 화면"
            case .PaymentResultViewController: return "충전 완료 화면"
            case .NoticeContentViewController: return "공지사항 상세 화면"
            case .NoticeViewController: return "공지사항 화면"
            case .EventViewController: return "이벤트 리스트 화면"
            case .EventContentsViewController: return "이벤트 상세 화면"
            case .MyWritingViewController: return "내가 쓴 글 화면"
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
            case .FavoriteViewController: return "즐겨찾기 화면"
            case .MembershipCardViewController: return "회원카드 관리 화면"
            case .ChargerFilterViewController: return "필터 설정 화면"
            case .PreUsePointViewController: return "베리 설정 화면"
            case .PointViewController: return "MY 베리 내역 화면"
            case .ChargesViewController: return "충전이력 조회 화면"
            case .EvDetailViewController: return "전기차 정보 상세 화면"
            case .ChargerInfoViewController: return "충전기 정보 리스트 화면"
            case .MainViewController: return "메인(지도)화면"
            case .MembershipReissuanceInfoViewController: return "재발급 신청 상세 화면"
            case .NewSettingsViewController: return "설정 화면"
            case .FindPasswordViewController: return "비밀번호 찾기 화면"
            case .EvInfoViewController: return "전기차 정보 리스트 화면"
            case .CouponCodeViewController: return "쿠폰번호 등록 화면"
            case .TermsViewController: return "웹뷰"
            case .SearchViewController: return "충전소 검색 화면"
            case .MembershipReissuanceViewController: return "재발급 신청 화면"
            case .EIImageViewerViewController: return "이미지 상세보기 화면"
            case .SearchAddressViewController: return "주소 검색 화면"
            case .ServiceGuideViewController: return "이용안내 화면"
            case .ReportBoardViewController: return "나의 제보 내역 화면"
            case .ReportChargeViewController: return "충전소 제보 화면"
            case .BoardSearchViewController: return "게시판 검색 화면"
            case .BoardDetailViewController: return "게시판 상세 화면"
            case .BoardWriteViewController: return "게시판 글 작성 화면"
            case .CardBoardViewController: return "게시판 리스트 화면"
            case .LoginViewController: return "로그인 화면"
            case .SignUpViewController: return "회원가입 화면"
            case .CorporationLoginViewController: return "법인 로그인 화면"
            case .DetailViewController: return "충전소 상세 화면"
            case .QuitAccountViewController: return "회원탈퇴 화면"
            case .PointUseGuideViewController: return "베리 사용 안내 화면"
            case .AcceptTermsViewController: return "회원 가입 이용약관 동의 화면"
            case .MembershipUseGuideViewController: return "회원카드 사용 안내 화면"
            case .MembershipGuideViewController: return "회원카드 안내 화면"
            case .AddressToLocationController: return "충전소 위치 검색 화면"
            }
        }
    }
}

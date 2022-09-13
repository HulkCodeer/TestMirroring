//
//  SoftberryAPI.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/05/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RxSwift
import Alamofire

protocol SoftberryAPI: class {
    func getCheckPassword(password: String, cardNo: String) -> Observable<(HTTPURLResponse, Data)>
    func postReissueMembershipCard(model: ReissuanceModel) -> Observable<(HTTPURLResponse, Data)>
    
    func updateBasicNotificationState(state: Bool) -> Observable<(HTTPURLResponse, Data)>
    func updateLocalNotificationState(state: Bool) -> Observable<(HTTPURLResponse, Data)>
    func updateMarketingNotificationState(state: Bool) -> Observable<(HTTPURLResponse, Data)>
    
    func getQuitAccountReasonList() -> Observable<(HTTPURLResponse, Data)>
    func deleteKakaoAccount(reasonID: String, reasonText: String) -> Observable<(HTTPURLResponse, Data)>
    func deleteAppleAccount(reasonID: String, reasonText: String) -> Observable<(HTTPURLResponse, Data)>
    func postRefreshToken(appleAuthorizationCode: String) -> Observable<(HTTPURLResponse, Data)>
    func postValidateRefreshToken() -> Observable<(HTTPURLResponse, Data)>
    func postGetBerry(eventId: String) -> Observable<(HTTPURLResponse, Data)>
    func logAds(adId: [String], action: Int) -> Disposable
    func getAdsList(page: Promotion.Page, layer: Promotion.Layer) -> Observable<(HTTPURLResponse, Data)>
    func countEventAction(eventId: [String], action: Promotion.Action) -> Disposable
    func postPaymentStatus() -> Observable<(HTTPURLResponse, Data)>
//    func postChargingQR(qrCode: String) -> Observable<(HTTPURLResponse, Data)>
//    func postChargingQR(qrCode: String, tc: String) -> Observable<(HTTPURLResponse, Data)>
    func getNoticeList() -> Observable<(HTTPURLResponse, Data)>
    func getNotice(id noticeID: Int) -> Observable<(HTTPURLResponse, Data)>
    func postChargingQR(qrCode: String, typeId: Int) -> Observable<(HTTPURLResponse, Data)>
    func postChargingQR(qrCode: String, typeId: Int, tc: String) -> Observable<(HTTPURLResponse, Data)>
}

internal final class RestApi: SoftberryAPI {

    init() {}
    
    // MARK: - 비밀번호 확인
    func getCheckPassword(password: String, cardNo: String) -> Observable<(HTTPURLResponse, Data)> {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "mb_pw": password,
            "card_no": cardNo
        ]
            
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/member/membership_card/check_password", httpMethod: .post, parameters: reqParam, headers: nil)
    }
    
    // MARK: - 카드 재발급
    func postReissueMembershipCard(model: ReissuanceModel) -> Observable<(HTTPURLResponse, Data)> {
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/member/membership_card/reissue_membership", httpMethod: .post, parameters: model.toParam, headers: nil)
    }
    
    // MARK: - 기본 알림 설정
    func updateBasicNotificationState(state: Bool) -> Observable<(HTTPURLResponse, Data)> {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "receive_push": state
        ]
        
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/member/user/setNotification", httpMethod: .post, parameters: reqParam, headers: nil)
    }
    
    // MARK: - 지역 알림 설정
    func updateLocalNotificationState(state: Bool) -> Observable<(HTTPURLResponse, Data)> {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "receive_push": state
        ]
        
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/member/user/setJejuNotification", httpMethod: .post, parameters: reqParam, headers: nil)
    }
    
    // MARK: - 마켓팅 알림 설정
    func updateMarketingNotificationState(state: Bool) -> Observable<(HTTPURLResponse, Data)> {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "receive_push": state
        ]
        
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/member/user/setMarketingNotification", httpMethod: .post, parameters: reqParam, headers: nil)
    }
    
    // MARK: - 탈퇴 사유
    func getQuitAccountReasonList() -> Observable<(HTTPURLResponse, Data)> {
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/member/member/deregister_type", httpMethod: .get, parameters: nil, headers: nil)
    }
    
    // MARK: - 카카오 연결 끊고 탈퇴
    func deleteKakaoAccount(reasonID: String, reasonText: String) -> Observable<(HTTPURLResponse, Data)> {
        let reqParam: Parameters = [
            "user_id": MemberManager.shared.userId,
            "reason_id": reasonID,
            "reason_descript": reasonText
        ]
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/member/member/deregister_kakao", httpMethod: .post, parameters: reqParam, headers: nil)
    }
    
    // MARK: - 회원 탈퇴
    func deleteAppleAccount(reasonID: String, reasonText: String) -> Observable<(HTTPURLResponse, Data)> {
        let reqParam: Parameters = [
            "user_id": MemberManager.shared.userId,
            "reason_id": reasonID,
            "refresh_token": MemberManager.shared.appleRefreshToken,
            "reason_descript": reasonText
        ]       
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/member/member/deregister_apple", httpMethod: .post, parameters: reqParam, headers: nil)
    }
    
    // MARK: - 애플 리프레쉬 토큰 요청
    func postRefreshToken(appleAuthorizationCode: String) -> Observable<(HTTPURLResponse, Data)> {
        let reqParam: Parameters = [
            "auth_code": appleAuthorizationCode
        ]
                
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/member/member/request_apple_token", httpMethod: .post, parameters: reqParam, headers: nil)
    }
    
    // MARK: - 애플 리프레쉬 토큰 검증
    func postValidateRefreshToken() -> Observable<(HTTPURLResponse, Data)> {
        let reqParam: Parameters = [
            "refresh_token": MemberManager.shared.appleRefreshToken
        ]
                
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/member/member/refresh_apple_token", httpMethod: .post, parameters: reqParam, headers: nil)
    }
    
    // MARK: - 3000베리 받기
    func postGetBerry(eventId: String) -> Observable<(HTTPURLResponse, Data)> {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "event_id": eventId
        ]
                
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/event/event/attendEvent", httpMethod: .post, parameters: reqParam, headers: nil)
    }
    
    // MARK: - 광고/이벤트 로깅
    func logAds(adId: [String], action: Int) -> Disposable {
        let reqParam: Parameters = [
            "mb_Id": "\(MemberManager.shared.mbId)",
            "action": "\(action)",
            "ad_id": adId,
            "member_id": MemberManager.shared.memberId
        ]
        return NetworkWorker.shared.rxRequest(url: "\(Const.AWS_SERVER)/promotion/log", httpMethod: .post, parameters: reqParam, headers: nil)
    }
    
    // MARK: - AWS 광고 리스트 조회
    func getAdsList(page: Promotion.Page, layer: Promotion.Layer) -> Observable<(HTTPURLResponse, Data)> {
        let memberId = Int(MemberManager.shared.memberId) ?? 0
        return NetworkWorker.shared.rxRequest(url: "\(Const.AWS_SERVER)/promotion?memberId=\(memberId)&page=\(page.rawValue)&layer=\(layer.rawValue)", httpMethod: .get, parameters: nil, headers: nil)
    }
    
    // MARK: - 이벤트 click event 전송
    func countEventAction(eventId: [String], action: Promotion.Action) -> Disposable {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "mb_id": MemberManager.shared.mbId,
            "event_ids": eventId,
            "action": action
        ]
        
        return NetworkWorker.shared.rxRequest(url: "\(Const.AWS_SERVER)/promotion/log", httpMethod: .post, parameters: reqParam, headers: nil)
    }
    
    // MARK: - 현재 회원의 Payment 상태 조회
    func postPaymentStatus() -> Observable<(HTTPURLResponse, Data)> {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId
        ]
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/pay/v2/evPay/checkRegistration", httpMethod: .post, parameters: reqParam, headers: nil)
    }
    
    // MARK: - QR충전 조회
    func postChargingQR(qrCode: String, typeId: Int) -> Observable<(HTTPURLResponse, Data)> {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "qr_code": qrCode,
            "type_id": typeId
        ]
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/charger/v2/app_charging/qr", httpMethod: .post, parameters: reqParam, headers: nil)
    }
    
    // MARK: - QR충전 조회
    func postChargingQR(qrCode: String, typeId: Int, tc: String) -> Observable<(HTTPURLResponse, Data)> {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "qr_code": qrCode,
            "tc": tc
            
        ]
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/charger/v2/app_charging/qr", httpMethod: .post, parameters: reqParam, headers: nil)
    }
    
    // MARK: - 공지사항 리스트 조회
    func getNoticeList() -> Observable<(HTTPURLResponse, Data)> {
        return NetworkWorker.shared.rxRequest(
            url: "\(Const.EV_PAY_SERVER)/board/board_notice/list",
            httpMethod: .get,
            parameters: nil,
            headers: nil)
    }
    
    // MARK: - 공지사항 상세 조회
    func getNotice(id noticeID: Int) -> Observable<(HTTPURLResponse, Data)> {

        return NetworkWorker.shared.rxRequest(
            url: "\(Const.EV_PAY_SERVER)/board/board_notice/content_v2?id=\(noticeID)",
            httpMethod: .get,
            parameters: nil,
            headers: nil)
    }
}

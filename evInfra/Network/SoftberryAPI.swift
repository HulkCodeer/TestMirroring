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
    
    // MARK: - 잔여 포인트 조회
    
    static func postMyBerryPoint() -> Observable<(HTTPURLResponse, Data)> {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId
        ]
        
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/member/member/my_point", httpMethod: .post, parameters: reqParam, headers: nil)
    }
}

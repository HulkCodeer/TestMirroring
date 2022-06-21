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
    func deleteKakaoAccount(reasonID: String) -> Observable<(HTTPURLResponse, Data)>
    func deleteAppleAccount(reasonID: String) -> Observable<(HTTPURLResponse, Data)>
    func revokeAppleAccount() -> Observable<(HTTPURLResponse, Data)>
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
    func deleteKakaoAccount(reasonID: String) -> Observable<(HTTPURLResponse, Data)> {
        let reqParam: Parameters = [
            "user_id": MemberManager.shared.userId,
            "reason_id": reasonID
        ]
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/member/member/deregister_kakao", httpMethod: .post, parameters: reqParam, headers: nil)
    }
    
    // MARK: - 회원 탈퇴
    func deleteAppleAccount(reasonID: String) -> Observable<(HTTPURLResponse, Data)> {
        let reqParam: Parameters = [
            "user_id": MemberManager.shared.userId,
            "reason_id": reasonID
        ]        
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/member/member/deregister_apple", httpMethod: .post, parameters: reqParam, headers: nil)
    }
    
    // MARK: - 회원 탈퇴
    func revokeAppleAccount() -> Observable<(HTTPURLResponse, Data)> {
        let reqParam: Parameters = [
            "client_id": "5FA8TZGUDC",
            "client_secret": "eyJraWQiOiJZdXlYb1kiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLnNvZnQtYmVycnkuZXYtaW5mcmEiLCJleHAiOjE2NTU4ODY5NTUsImlhdCI6MTY1NTgwMDU1NSwic3ViIjoiMDAxMjQ3LmJjNWNjZDlkM2U3YzQ3NjE4YjJkNDI3YWJjMDZmMzFhLjA4MzkiLCJjX2hhc2giOiJlS0ZTQ0JkdGRWVXNjN0ZtWDZESW13IiwiZW1haWwiOiJwYXJraGpAc29mdC1iZXJyeS5jb20iLCJlbWFpbF92ZXJpZmllZCI6InRydWUiLCJhdXRoX3RpbWUiOjE2NTU4MDA1NTUsIm5vbmNlX3N1cHBvcnRlZCI6dHJ1ZX0.JoV5zlp7fph6zxvOiz2QGdQtYDhQGlWH8xFnwjJPvjpCrgJnDaqA4YRLr_OQsPN4V6Tj-YYgDY3PceN_L-w-OjBR1Biz5my-sPh1MADoUxW5w4c9-i15Sv2Km5NFZ1V2Q2bFUO55s6_zzifyLQeL-SmiS13See3s4Iu8PDkUw7anSkBvNFYV9QTtwrFji-Ur5K03Hn0hktz7FQbtZ1gnHflQc9bOnL7TPWbiNw_GqjsQXlNa8OfvpZBRegbmuLlUgzTySaJNwPed9B8NHRm9XLvEPiV74SNZcmbtRT2ULsjD2ajJkgz-tmWi1ROYK6BpOPn2PAfXnf3SkLF6n-fF6A",
            "token": "001247.bc5ccd9d3e7c47618b2d427abc06f31a.0839",
            "token_type_hint": "refresh_token"
        ]
        
        let header: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        return NetworkWorker.shared.rxRequest(url: "https://appleid.apple.com/auth/revoke", httpMethod: .post, parameters: reqParam, headers: header)
    }
}

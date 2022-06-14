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
}

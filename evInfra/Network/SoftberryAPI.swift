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
    func getNoticeList() -> Observable<(HTTPURLResponse, Data)>
    func getNoticeDetail(with noticeId: Int) -> Observable<(HTTPURLResponse, Data)>
    func getReportHistoryList(with reportId: Int) -> Observable<(HTTPURLResponse, Data)>
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
    
    // MARK: - 공지사항 리스트
    func getNoticeList() -> Observable<(HTTPURLResponse, Data)> {
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/board/board_notice/list", httpMethod: .get, parameters: nil, headers: nil)
    }
    
    // MARK: - 공지사항 상세
    func getNoticeDetail(with noticeId: Int) -> Observable<(HTTPURLResponse, Data)> {
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/board/board_notice/content?id=\(noticeId)", httpMethod: .get, parameters: nil, headers: nil)
    }
    
    // MARK: - 나의 제보 내역
    func getReportHistoryList(with reportId: Int) -> Observable<(HTTPURLResponse, Data)> {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "report_id": reportId
        ]
        return NetworkWorker.shared.rxRequest(url: "\(Const.EV_PAY_SERVER)/charger/report/my_report", httpMethod: .post, parameters: reqParam, headers: nil)
    }
}

//
//  Server.swift
//  evInfra
//
//  Created by Shin Park on 19/02/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation
import Alamofire

class Server {
    static let VERSION = 1
    static func responseData(response: DataResponse<Any>, completion: @escaping (Bool, Data?) -> Void) {
        switch response.result {
        case .success( _):
            completion(true, response.data)

        case .failure(let error):
            print(error)
            completion(false, response.data)
        }
    }
    
    static func responseJson(response: DataResponse<Any>, completion: @escaping (Bool, Any) -> Void) {
        switch response.result {
        case .success(let value):
            completion(true, value)
            
        case .failure(let error):
            print(error)
            completion(false, error)
        }
    }
    
    // 사용자 - 디바이스 정보 등록
    static func registerUser(version: String, model: String, uid: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "os": "IOS",
            "app_ver": version,
            "model": model,
            "device_id": uid
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/user/register",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 사용자 - FCM token 등록
    static func registerFCM(fcmId: String, uid: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "fcm_id": fcmId,
            "device_id": uid
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/user/registerFcm",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 사용자 - push message 알림 설정
    static func updateNotificationState(state: Bool, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "receive_push": state
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/user/setNotification",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 사용자 - push message 알림 설정
    static func updateJejuNotificationState(state: Bool, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "receive_push": state
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/user/setJejuNotification",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 회원 가입
    static func signUp(user: Login, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "user_id": MemberManager.getUserId(),
            
            "nickname": UserDefault().readString(key: UserDefault.Key.MB_NICKNAME),
            "profile": UserDefault().readString(key: UserDefault.Key.MB_PROFILE_NAME),
            
            "login_type": user.type.rawValue,
            "email": user.email ?? "",
            "email_cert": user.emailVerified,
            "phone_no": user.phoneNo ?? "",
            "age_range": user.ageRange ?? "",
            "gender": user.gender ?? ""
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/member/sign_up",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 로그인
    static func login(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "user_id": MemberManager.getUserId()
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/member/login",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 정보 업데이트
    static func updateMemberInfo(nickName: String, region: String, profile: String, carId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "nickname": nickName,
            "region": region,
            "car_id": carId,
            "profile": profile
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/member/update_info",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 정보 가져오기
    static func getMemberinfo(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId()
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/member/member_info",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 회원카드 정보 가져오기
    static func getInfoMembershipCard(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId()
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/membership_card/info",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 회원 제휴 정보 가져오기
    static func getMemberPartnershipInfo(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId()
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/member_partnership/get_member_info",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 롯데렌터카 회원정보 조회
    static func getLotteRentInfo(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId()
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/member_partnership/get_lotte_member_info",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 롯데렌터카 회원인증
    static func certificateLotteRentaCar(carNo : String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "car_no": carNo
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/member_partnership/certify_lotte",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
        
    // 회원 - 롯데렌터카 회원인증 완료
    static func activateLotteRentaCar(carNo : String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "car_no": carNo
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/member_partnership/activate_lotte_member",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - SK렌터카 회원등록
    static func registerSKMembershipCard(carNo : String, cardNo : String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "car_no": carNo,
            "card_no": cardNo
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/member_partnership/register_skr",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 회원카드 발급 신청
    static func registerMembershipCard(values: [String: Any], completion: @escaping (Bool, Any) -> Void) {
        Alamofire.request(Const.EV_PAY_SERVER + "/member/membership_card/register",
                      method: .post, parameters: values, encoding: JSONEncoding.default)
        .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }

    // 회원 - 회원카드 해지 신청. 서버 구현 해야 함
    static func unregisterMembershipCard(cardNo: String, password: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "mb_pw": password,
            "card_no": cardNo
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/membership_card/unregister",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }

    // 회원 - 회원카드 비밀번호 확인
    static func changeMembershipCardPassword(values: [String: Any], completion: @escaping (Bool, Any) -> Void) {
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/membership_card/change_password",
                      method: .post, parameters: values, encoding: JSONEncoding.default)
        .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 잔여 포인트 가져오기
    static func getPoint(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId()
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/member/member/my_point",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 포인트 이력 조회
    static func getPointHistory(isAllDate: Bool, sDate: String, eDate: String, completion: @escaping (Bool, Data?) -> Void) {
            var reqParam: Parameters = [
                "req_ver": 1,
                "mb_id": MemberManager.getMbId(),
            ]
            if !isAllDate {
                reqParam["s_date"] = sDate
                reqParam["e_date"] = eDate
            }
            
            Alamofire.request(Const.EV_PAY_SERVER + "/member/member/point_history",
                              method: .post, parameters: reqParam, encoding: JSONEncoding.default)
                .validate().responseJSON { response in responseData(response: response, completion: completion) }
    }
    
    // 회원 - 설정 포인트 가져오기
    static func getUsePoint(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId()
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/member/member/get_use_point",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 설정 포인트 변경
    static func setUsePoint(usePoint: Int, useNow: Bool, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "use_now": useNow,
            "point": usePoint
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/member/member/set_use_point",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 즐겨찾기 목록
    static func getFavoriteList(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId()
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/favorite/list",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 충전소 즐겨찾기 등록, 해제
    static func setFavorite(chargerId: String, mode: Bool, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "charger_id": chargerId,
            "mode": mode
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/favorite/update",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 즐겨찾기 등록한 충전소 상태변화 알림 on/off
    static func setFavoriteAlarm(chargerId: String, state: Bool, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "charger_id": chargerId,
            "noti": state
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/favorite/noti",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 공지사항 리스트
    static func getNoticeList(completion: @escaping (Bool, Any) -> Void) {
        Alamofire.request(Const.EV_PAY_SERVER + "/board/board_notice/list")
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 공지사항 내용
    static func getNoticeContent(noticeId: Int, completion: @escaping (Bool, Any) -> Void) {
        Alamofire.request(Const.EV_PAY_SERVER + "/board/board_notice/content?id=\(noticeId)")
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 카테고리별 게시판 가져오기
    static func getBoard(category: String, bmId: Int = -1, page: Int = -1, count: Int = -1, mine: Bool = false, ad: Bool = true, completion: @escaping (Bool, Any) -> Void) {
        var reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "category": category,
            "page": page,
            "page_count": count,
            "mine": mine
        ]
        
        if category.elementsEqual(Board.BOARD_CATEGORY_COMPANY) {
            reqParam.updateValue(bmId, forKey: "bm_id")
            reqParam.updateValue(false, forKey: "ad") // 사업자 게시판 광고 포함하지 않음
        } else {
            reqParam.updateValue(true, forKey: "ad") // true: 게시글에 광고 포함. false: 광고 불포함
        }

        Alamofire.request(Const.EV_PAY_SERVER + "/board/board/contents",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 선택한 충전소 게시판 가져오기
    static func getChargerBoard(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "category": Board.BOARD_CATEGORY_CHARGER,
            "charger_id": chargerId,
            "page": -1,
            "page_count": -1,
            "ad":true
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/board/board/contents",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - board id 에 해당하는 본문, 댓글 가져오기
    static func getBoardContent(category: String, boardId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "category": category,
            "brd_id": boardId,
            "page": -1,
            "page_count": -1,
            "ad":false
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/board/board/contents",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 카테고리별 게시판 본문 작성
    static func postBoard(category: String, bmId: Int, chargerId: String = "", content: String, hasImage: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "category": category,
            "charger_id": chargerId,
            "bm_id": bmId,
            "content": content,
            "has_image": hasImage
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/board/board/create",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 본문 수정
    static func editBoard(category: String, boardId: Int, content: String, editImage: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "category": category,
            "brd_id": boardId,
            "content": content,
            "edit_image": editImage
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/board/board/edit",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 본문 삭제
    static func deleteBoard(category: String, boardId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "category": category,
            "brd_id": boardId
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/board/board/delete",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 댓글 등록
    static func postReply(category: String, boardId: Int, content: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "category": category,
            "brd_id": boardId,
            "content": content
        ]

        Alamofire.request(Const.EV_PAY_SERVER + "/board/reply/create",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 댓글 수정
    static func editReply(category: String, replyId: Int, content: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "category": category,
            "reply_id": replyId,
            "content": content
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/board/reply/edit",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 댓글 삭제
    static func deleteReply(category: String, boardId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "category": category,
            "reply_id": boardId
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/board/reply/delete",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 각 게시판 마지막 글 id 가져오기
    static func getBoardData(completion: @escaping (Bool, Any) -> Void) {
        Alamofire.request(Const.EV_PAY_SERVER + "/board/board_data/info")
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 운영기관 정보
    static func getCompanyInfo(updateDate: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "update_date": updateDate
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/company/v2/company/info",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 충전소 리스트
    static func getStationInfo(updateDate: String, completion: @escaping (Bool, Data?) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "last_update" : updateDate,
            "version" : Server.VERSION
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/v1/station/station",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseData(response: response, completion: completion) }
    }
    
    // Station - 충전소 상태 정보
    static func getStationStatus(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId()
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/v1/station/station_status",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 충전소 리스트 charger info
    static func getChargerInfo(chargerId : String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "charger_id": chargerId
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/v1/station/charger",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
   // Station - 충전소 상태 정보
    static func getChargerStatus(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId()
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/v1/station/status",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 충전소 상태 정보
    static func getChargerDetail(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "charger_id": chargerId
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/v1/station/detail",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 충전소 상세 정보
    static func getStationDetail(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "charger_id": chargerId
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/v1/station/detail",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 본인이 등록한 평점 가져오기
    static func getGrade(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "charger_id": chargerId
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/grade/member",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 평점 등록하기
    static func addGrade(chargerId: String, point: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "charger_id": chargerId,
            "sp": point
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/grade/register",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 평점 삭제하기
    static func deleteGrade(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "charger_id": chargerId
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/grade/unregister",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 지킴이 - 대상 충전소 리스트
    static func getStationListForGuard(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId()
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/guard/list",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 지킴이 - 현장점검표 링크 가져오기
    static func getChecklistLink(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId()
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/guard/checklist",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 전기차 정보 - 전기차 리스트 가져오기
    static func getEvList(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId()
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/ev/ev_models/list",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 전기차 정보 - 전기차 모델 및 차량 정보 가져오기
    static func getEvModelList(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId()
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/ev/ev_models/info",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 제보하기 - 기존에 있는 충전소의 위치정보 수정 요청
    static func modifyReport(info: ReportCharger, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "report_id": info.report_id,
            "type_id": info.type_id!,
            "charger_id": info.charger_id!,
            "lat": info.lat!,
            "lon": info.lon!,
            "snm": info.snm!,
            "adr": info.adr!,
            "adr_dtl": info.adr_dtl!
            ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/report/modify",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 제보하기 - 제보내역 삭제
    static func deleteReport(reportId: Int, typeId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "report_id": reportId,
            "type_id": typeId
            ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/report/delete",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 제보하기 - 제보 정보 가져오기
    static func getReportInfo(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "charger_id": chargerId
            ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/report/info",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 제보하기 - 나의 제보 내역 리스트 가져오기
    static func getReportList(reportId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "report_id": reportId
            ]

        Alamofire.request(Const.EV_PAY_SERVER + "/charger/report/my_report",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseData(response: response, completion: completion) }
    }
    
    // 이벤트 - 리스트 가져오기
    static func getEventList(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "memberId": MemberManager.getMemberId()
            ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/event/Event/getEventList",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 쿠폰 - 리스트 가져오기
    static func getCouponList(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId()
            ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/event/coupon/getCouponList",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 쿠폰 - 쿠폰코드 등록
    static func registerCoupon(couponCode:String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "coupon_code": couponCode
            ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/event/coupon/register_coupon",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 광고 - large image 정보 요청
    static func getAdLargeInfo(type: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "mb_id": MemberManager.getMbId(),
            "type": type
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/ad/ad_large/get_info",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 광고 click event 전송
    static func countAdAction(adId: Int, action: Int) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "mb_id": MemberManager.getMbId(),
            "ad_id": adId,
            "action": action
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/ad/ad_analysis/add_count",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
    }

    static func getUpdateGuide(guide_version: Int, app_version: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "app_version": app_version,
            "guide_version": guide_version,
            "os": "IOS"
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/docs/guide/guide_url",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    /*
     * 결제
     */
    // Payment Regist
    static func getPayRegisterStatus(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "mb_id": MemberManager.getMbId()
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/pay/evPay/checkRegistration",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    static func getPayRegisterInfo (completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "mb_id": MemberManager.getMbId()
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/pay/evPay/registrationInfo",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    static func deletePayMember (completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "mb_id": MemberManager.getMbId()
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/pay/evPay/deletePayMember",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    static func getFailedPayList (completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId()
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/pay/v2/evPay/getFailedPayList",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    static func repayCharge (usePoint: Int, completion: @escaping (Bool, Data?) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "use_point": usePoint
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/pay/v2/evPay/repay",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseData(response: response, completion: completion) }
    }

    // QR 충전
    static func getChargerInfo(cpId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "cp_id": cpId
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/charger_info/info",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 충전 시작 요청
    static func openCharger(cpId: String, connectorId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "cp_id": cpId,
            "connector_id": connectorId
        ]

        Alamofire.request(Const.EV_PAY_SERVER + "/charger/app_charging/open",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 충전 종료 요청
    static func stopCharging(chargingId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "charging_id": chargingId
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/app_charging/stop",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 충전 상태 요청
    static func getChargingStatus(chargingId: String, completion: @escaping (Bool, Any) -> Void) {
        
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "charging_id": chargingId
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/app_charging/status",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 충전 결과 요청
    static func getChargingResult(chargingId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "charging_id": chargingId
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/app_charging/result",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 충전 이력 조회
    static func getCharges(isAllDate: Bool, sDate: String, eDate: String, completion: @escaping (Bool, Data?) -> Void) {
        var reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
        ]
        if !isAllDate {
            reqParam["s_date"] = sDate
            reqParam["e_date"] = eDate
        }
        
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/app_charging/history",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseData(response: response, completion: completion) }
    }
    
    // EV member 충전 가격 조회
    static func getChargePriceForEvInfra(completion: @escaping (Bool, Any) -> Void){
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/charge_price/ev_infra")
        .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // Each Membership 충전 가격 조회
    static func getMembershipCahrgePrice(completion: @escaping (Bool, Any) -> Void){
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId()
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/charge_price/each_company",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseJSON { response in responseData(response: response, completion: completion) }
    }
    
    // 충전 - 포인트 사용
    static func usePoint(point: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "point": point
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/app_charging/use_point",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // charging id 요청
    static func getChargingId(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId()
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/app_charging/getChargingId",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    static func getIntroImage(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId()
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/event/intro_event/intro",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // Closed Beta Test 정보 가져오기
    static func getCBTInfo(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId()
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/event/cbt/info",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // download url file
    static func getData(url: URL, completion: @escaping (Bool, Data?) -> Void) {
        Alamofire.request(url).responseData { (response) in
            if response.error == nil {
                completion(true, response.data)
            }
        }
    }
    
    // image upload To Server
    static func uploadImage(data: Data, filename: String, kind: Int, targetId: String, completion: @escaping (Bool, Any) -> Void){
        let uploadFileName = filename.data(using: .utf8)!
        let uploadTargetId = targetId.data(using: .utf8)!
        let contentsKind = ("\(kind)").data(using: .utf8)!
        let contentsSequence = ("0").data(using: .utf8)!
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(contentsKind, withName: "kind" , mimeType: "text/plain; charset=UTF-8")
            multipartFormData.append(uploadFileName, withName: "file_name" , mimeType: "text/plain; charset=UTF-8")
            multipartFormData.append(uploadTargetId, withName: "target_id" , mimeType: "text/plain; charset=UTF-8")
            multipartFormData.append(contentsSequence ,  withName:"sequence" ,  mimeType: "text/plain; charset=UTF-8" )
            multipartFormData.append(data ,  withName:"file" ,  fileName : filename ,  mimeType :  "image/jpeg" )
        }, to: Const.EV_PAY_SERVER + "/data/image_uploader/upload_image", encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON {response in  // ← JSON 형식으로받을
                    if !response.result.isSuccess  {
                        completion(false, response)
                    } else  {
                        completion(true, response)
                    }
                }
            case .failure(let encodingError):
                completion(false, encodingError)
            }
        })
    }
    
    // admob reward
    static func postRewardVideo( type : String,  amount : Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "type" :type,
            "amount" : amount
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/ad/ad_reward/reward_video",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }

    // get reward point
    static func getRewardPoint(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId()
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/ad/ad_reward/reward_point/mb_id/\(MemberManager.getMbId())" ,
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    
    }
    
    //
    static func postCheckRewardVideoAvailable(completion: @escaping (Bool, Any) -> Void){
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId()
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/ad/ad_reward/reward_video_available" ,
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }

    // find poi from sk open api
    static func getPoiItemList(count : Int, radius : Int, centerLat : Double, centerLon : Double, keyword : String, completion: @escaping (Bool, Any) -> Void) {
        
        var url = "https://apis.openapi.sk.com/tmap/pois";
        url += "?version=1";
        url += "&page=1";
        url += "&count=\(count)";
        url += "&searchKeyword=" + keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!;
        url += "&resCoordType=WGS84GEO";
        url += "&searchType=all";
        url += "&searchtypCd=A"; //url += "&searchtypCd=R";
        url += "&radius=\(radius)";
        url += "&reqCoordType=WGS84GEO";
        url += "&centerLon=\(centerLon)";
        url += "&centerLat=\(centerLat)";
        url += "&multiPoint=N";
        url += "&appKey=b574a171-8ba8-47e8-855d-69b4b7ee5c80";
        
        Alamofire.request(url,
                      method: .get, parameters: nil, encoding: JSONEncoding.default)
        .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
}

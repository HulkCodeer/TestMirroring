//
//  Server.swift
//  evInfra
//
//  Created by Shin Park on 19/02/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation
import Alamofire
import CoreMedia

class Server {
    
    static let VERSION = 1
    static func responseData(response: AFDataResponse<Data>, completion: @escaping (Bool, Data?) -> Void) {
        switch response.result {
        case .success(_):
            completion(true, response.data)

        case .failure(let error):
            print(error)
            completion(false, response.data)
        }
    }
    
    static func responseJson(response: AFDataResponse<Data>, completion: @escaping (Bool, Any) -> Void) {
        switch response.result {
        case .success(let value):
            do {
                let json = try JSONSerialization.jsonObject(with: value)
                printLog(out: "Server ResponseJson: \(json)")
                completion(true, json)
            } catch {
                printLog(out: "Error while decoding response: \(String(decoding: value, as: UTF8.self))")
                completion(false, error)
            }
            
        case .failure(let error):
            print(error)
            completion(false, error)
        }
    }
    
    static func getHeaders() -> HTTPHeaders {
        let headers: HTTPHeaders = [
            "mb_id": "\(MemberManager.shared.mbId)",
            "nick_name": MemberManager.shared.memberNickName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "",
            "profile": "\(MemberManager.shared.profileImage)"
        ]
        printLog(out: "Server getHeaders \(headers.dictionary.description)")
        return headers
    }
    
    // 사용자 - 디바이스 정보 등록
    static func registerUser(version: String, model: String, uid: String, fcmId: String?, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "os": "IOS",
            "app_ver": version,
            "model": model,
            "device_id": uid,
            "fcm_id": fcmId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/member/v2/user/register",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 사용자 - FCM token 등록
    static func registerFCM(fcmId: String, uid: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "fcm_id": fcmId,
            "device_id": uid
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/member/user/registerFcm",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 사용자 - push message 알림 설정
    static func updateNotificationState(state: Bool, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "receive_push": state
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/member/user/setNotification",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 사용자 - 제주지역 push message 알림 설정
    static func updateJejuNotificationState(state: Bool, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "receive_push": state
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/member/user/setJejuNotification",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 사용자 - 마케팅 push message 알림 설정
    static func updateMarketingNotificationState(state: Bool, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "receive_push": state
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/member/user/setMarketingNotification",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 회원 가입
    static func signUp(user: Login, completion: @escaping (Bool, Any) -> Void) {
        let reqParam = user.convertToParams()
        AF.request(Const.EV_PAY_SERVER + "/member/member/sign_up",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 관리자 리스트
    static func getAdminList(completion: @escaping (Bool, Any) -> Void) {
        AF.request(Const.EV_COMMUNITY_SERVER + "/admin_list",
                          method: .post,
                          parameters: nil,
                          encoding: JSONEncoding.default)
            .validate()
            .responseData { response in responseData(response: response, completion: completion) }
    }
    
    // 회원 - 로그인
    static func login(user: Login?, completion: @escaping (Bool, Any) -> Void) {
        var reqParam: Parameters
        if let userInfo = user {
            reqParam = userInfo.convertToParams()
        } else {
            reqParam = [
                "member_id": MemberManager.shared.memberId,
                "user_id": MemberManager.shared.userId
            ]
        }
        
        AF.request(Const.EV_PAY_SERVER + "/member/member/login",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 법인 로그인
    static func loginWithID(id: String, pwd: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "signing_id": id,
            "mb_pw" : pwd
        ]        
        AF.request(Const.EV_PAY_SERVER + "/member/member/login_id",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 정보 업데이트
    static func updateMemberInfo(nickName: String, region: String, profile: String, carId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "nickname": nickName,
            "region": region,
            "car_id": carId,
            "profile": profile
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/member/member/update_info",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 정보 가져오기
    static func getMemberinfo(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/member/member/member_info",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - sk on jwt 토큰 발급
    static func getBatteryJwt(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "batteryDeviceId": MemberManager.shared.deviceId
        ]
        AF.request(Const.EV_PAY_SERVER + "/member/member/get_jwt",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 회원카드 정보 가져오기
    static func getInfoMembershipCard(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId
        ]        
        AF.request(Const.EV_PAY_SERVER + "/member/v2/membership_card/info",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 렌터카 카드 정보 조회
    static func getRetnalCarCardInfo(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/member/v2/member_partnership/get_member_info",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 롯데렌터카 회원정보 조회
    static func getLotteRentInfo(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/member/member_partnership/get_lotte_member_info",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 롯데렌터카 회원인증
    static func certificateLotteRentaCar(carNo : String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "car_no": carNo
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/member/member_partnership/certify_lotte",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
        
    // 회원 - 롯데렌터카 회원인증 완료
    static func activateLotteRentaCar(carNo : String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "car_no": carNo
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/member/member_partnership/activate_lotte_member",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - SK렌터카 회원등록
    static func registerSKMembershipCard(carNo : String, cardNo : String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "car_no": carNo,
            "card_no": cardNo
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/member/member_partnership/register_skr",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 회원카드 발급 신청
    static func registerMembershipCard(values: [String: Any], completion: @escaping (Bool, Any) -> Void) {
        AF.request(Const.EV_PAY_SERVER + "/member/membership_card/register",
                      method: .post, parameters: values, encoding: JSONEncoding.default)
        .validate().responseData { response in responseJson(response: response, completion: completion) }
    }

    // 회원 - 회원카드 해지 신청. 서버 구현 해야 함
    static func unregisterMembershipCard(cardNo: String, password: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "mb_pw": password,
            "card_no": cardNo
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/member/membership_card/unregister",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseData { response in responseJson(response: response, completion: completion) }
    }

    // 회원 - 회원카드 비밀번호 확인
    static func changeMembershipCardPassword(values: [String: Any], completion: @escaping (Bool, Any) -> Void) {
        
        AF.request(Const.EV_PAY_SERVER + "/member/membership_card/change_password",
                      method: .post, parameters: values, encoding: JSONEncoding.default)
        .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 잔여 포인트 가져오기
    static func getPoint(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId
        ]
        AF.request(Const.EV_PAY_SERVER + "/member/member/my_point",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 포인트 이력 조회
    static func getPointHistory(isAllDate: Bool, sDate: String, eDate: String, completion: @escaping (Bool, Data?) -> Void) {
            var reqParam: Parameters = [
                "req_ver": 1,
                "mb_id": MemberManager.shared.mbId,
            ]
            if !isAllDate {
                reqParam["s_date"] = sDate
                reqParam["e_date"] = eDate
            }
            
            AF.request(Const.EV_PAY_SERVER + "/member/member/point_history",
                              method: .post, parameters: reqParam, encoding: JSONEncoding.default)
                .validate().responseData { response in responseData(response: response, completion: completion) }
    }
    
    // 회원 - 설정 포인트 가져오기
    static func getUsePoint(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId
        ]
        AF.request(Const.EV_PAY_SERVER + "/member/member/get_use_point",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 설정 포인트 변경
    static func setUsePoint(usePoint: Int, useNow: Bool, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId,
            "use_now": useNow,
            "point": usePoint
        ]
        AF.request(Const.EV_PAY_SERVER + "/member/member/set_use_point",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 즐겨찾기 목록
    static func getFavoriteList(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/member/favorite/list",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 충전소 즐겨찾기 등록, 해제
    static func setFavorite(chargerId: String, mode: Bool, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "charger_id": chargerId,
            "mode": mode
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/member/favorite/update",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 즐겨찾기 등록한 충전소 상태변화 알림 on/off
    static func setFavoriteAlarm(chargerId: String, state: Bool, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "charger_id": chargerId,
            "noti": state
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/member/favorite/noti",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // MARK: - Coummunity 개선 - 게시판 조회
    static func fetchBoardList(mid: String, page: String, mode: String, sort: String, searchType: String, searchKeyword: String, completion: @escaping (Bool, Data?) -> Void) {
        
        let headers: HTTPHeaders = getHeaders()
        
        let urlString = Const.EV_COMMUNITY_SERVER + "/list/mid/\(mid)/page/\(page)/mode/\(mode)/sort/\(sort)/search_type/\(searchType)/search_keyword/\(searchKeyword)"
        
        if let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
            AF.request(encodedUrl,
                              method: .get,
                              parameters: nil,
                              encoding: JSONEncoding.default,
                              headers: headers).validate().responseData { response in
                responseData(response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Community 개선 - 게시글 등록
    static func postBoardData(mid: String, title: String, content: String, charger_id: String, completion: @escaping (Bool, Any) -> Void) {

        let headers: HTTPHeaders = getHeaders()
        let parameters: Parameters = [
            "title" : title,
            "content" : content,
            "tags" : "{\"charger_id\":\"\(charger_id)\"}"
        ]

        AF.request(Const.EV_COMMUNITY_SERVER + "/write/mid/\(mid)",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
            .validate()
            .responseData { response in
            responseJson(response: response, completion: completion)
        }
    }
    
    // MARK: - Community 개선 - 게시글 수정
    static func updateBoardData(mid: String, documentSRL: String, title: String, content: String, charger_id: String, completion: @escaping (Bool, Any) -> Void) {
        let headers: HTTPHeaders = getHeaders()
        let parameters: Parameters = [
            "title" : title,
            "content" : content,
            "tags" : "{\"charger_id\":\"\(charger_id)\"}"
        ]
        
        AF.request(Const.EV_COMMUNITY_SERVER + "/update/mid/\(mid)/document_srl/\(documentSRL)",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers).validate().responseData { response in
            responseJson(response: response, completion: completion)
        }
    }
    
    // MARK: - Community 개선 - 게시물 파일 삭제
    static func deleteDocumnetFile(documentSRL: String, fileSRL: String, isCover: String, completion: @escaping (Bool, Any) -> Void) {
        let headers: HTTPHeaders = getHeaders()
        
        AF.request(Const.EV_COMMUNITY_SERVER + "/file/document_srl/\(documentSRL)/file_srl/\(fileSRL)/cover/\(isCover)",
                          method: .delete,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers).validate().responseData { response in
            responseJson(response: response, completion: completion)
        }
    }
    
    // MARK: - Community 개선 - 게시글 상세 조회
    static func fetchBoardDetail(mid: String, document_srl: String, completion: @escaping (Any?) -> Void) {
        let headers: HTTPHeaders = getHeaders()
        
        AF.request(Const.EV_COMMUNITY_SERVER + "/view/mid/\(mid)/document_srl/\(document_srl)",
                          method: .get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers).validate().responseData { response in
            switch response.result {
            case .success(_):
                guard let data = response.data else { return }
                let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(BoardDetailResponseData.self, from: data)
                    completion(result)
                } catch {
                    debugPrint("error")
                }
                
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    // MARK: - Community 개선 - 게시글 삭제
    static func deleteBoard(document_srl: String, completion: @escaping (Bool, Any) -> Void) {
        let headers: HTTPHeaders = getHeaders()        
        AF.request(Const.EV_COMMUNITY_SERVER + "/delete/document_srl/\(document_srl)", method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseData { response in
            responseJson(response: response, completion: completion)
        }
    }
    
    // MARK: - Community 개선 - 게시글 좋아요 기능
    static func setLikeCount(srl: String, isComment: Bool, completion: @escaping (Bool, Any) -> Void) {
        let headers: HTTPHeaders = getHeaders()
        
        var url = Const.EV_COMMUNITY_SERVER
        
        if isComment {
            url += "/comment_like/comment_srl/\(srl)"
        } else {
            url += "/like/document_srl/\(srl)"
        }
        
        AF.request(url,
                          method: .get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
            .responseData { response in
                responseJson(response: response, completion: completion)
        }
    }
    
    // MARK: - Community 개선 - 게시글 신고하기 기능
    static func reportBoard(document_srl: String, completion: @escaping (Bool, Any) -> Void) {
        let headers: HTTPHeaders = getHeaders()
        
        AF.request(Const.EV_COMMUNITY_SERVER + "/report/document_srl/\(document_srl)",
                          method: .get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers).responseData { response in
            responseJson(response: response, completion: completion)
        }
    }
    
    // MARK: - Community 개선 - 댓글 신고하기 기능
    static func reportComment(commentSrl: String, completion: @escaping (Bool, Any) -> Void) {
        let headers: HTTPHeaders = getHeaders()
        
        AF.request(Const.EV_COMMUNITY_SERVER + "/comment_report/comment_srl/\(commentSrl)",
                          method: .get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers).responseData { response in
            responseJson(response: response, completion: completion)
        }
    }
    
    // MARK: - Community 개선 - 댓글 작성
    static func postComment(commentParameter: CommentParameter,
                            completion: @escaping (Bool, Any) -> Void) {
        let headers: HTTPHeaders = getHeaders()
        let isRecomment = commentParameter.isRecomment
        
        var parameters: Parameters = [
            "content" : "\(commentParameter.text)"
        ]

        if let comment = commentParameter.comment,
            isRecomment {
            parameters["target_mb_id"] = comment.mb_id
            parameters["target_nick_name"] = comment.nick_name
            parameters["parent_srl"] = comment.comment_srl
            parameters["head"] = comment.head
            parameters["depth"] = "\(Int(comment.depth ?? "0")! + 1)"
        }
        
        AF.request(Const.EV_COMMUNITY_SERVER + "/comment_write/mid/\(commentParameter.mid)/document_srl/\(commentParameter.documentSRL)",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers).responseData { response in
            responseJson(response: response, completion: completion)
        }
    }
    
    // MARK: - Community 개선 - 댓글/대댓글 삭제
    static func deleteBoardComment(documentSRL: String, commentSRL: String, completion: @escaping (Bool, Any) -> Void) {
        let headers: HTTPHeaders = getHeaders()
        
        AF.request(Const.EV_COMMUNITY_SERVER + "/comment_delete/document_srl/\(documentSRL)/comment_srl/\(commentSRL)",
                          method: .delete,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers).responseData { response in
            responseJson(response: response, completion: completion)
        }
    }
    
    // MARK: - Community 개선 - 댓글 수정
    static func modifyBoardComment(commentParameter: CommentParameter,
                                   completion: @escaping (Bool, Any) -> Void) {
        
        let headers: HTTPHeaders = getHeaders()
        
        var parameters: Parameters = [
            "content" : "\(commentParameter.text)",
            "document_srl" : "\(commentParameter.documentSRL)",
            "comment_srl" : "\(commentParameter.comment!.comment_srl ?? "")"
        ]
        
        let isRecomment = commentParameter.isRecomment
        
        if let comment = commentParameter.comment,
            isRecomment {
            parameters["target_mb_id"] = comment.target_mb_id
            parameters["target_nick_name"] = comment.target_nick_name
            parameters["parent_srl"] = comment.parent_srl
            parameters["head"] = comment.head
            parameters["depth"] = comment.depth
        }
        
        let urlString = Const.EV_COMMUNITY_SERVER + "/comment_update/mid/\(commentParameter.mid)/document_srl/\(commentParameter.documentSRL)/comment_srl/\(commentParameter.comment!.comment_srl ?? "")"
        
        if let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
            AF.request(encodedUrl,
                              method: .post,
                              parameters: parameters,
                              encoding: JSONEncoding.default,
                              headers: headers).validate()
                .responseData { response in
                responseJson(response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Community 개선 - 게시글 이미지 업로드
    static func boardImageUpload(mid: String, document_srl: String, image: UIImage, seq: String, completion: @escaping (Bool, Any) -> Void) {
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else { return }
        
        let url = Const.EV_COMMUNITY_SERVER + "/file/mid/\(mid)/document_srl/\(document_srl)/seq/\(seq)"
        
        imageUpload(imageData: imageData, url: url) { (isSuccess, response) in
            if isSuccess {
                completion(true, response)
            } else {
                completion(false, response)
            }
        }
    }
    
    // MARK: - Community 개선 - 댓글 이미지 업로드
    static func commentImageUpload(mid: String, document_srl: String, comment_srl: String, image: UIImage, completion: @escaping(Bool, Any) -> Void) {
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else { return }
        
        let url = Const.EV_COMMUNITY_SERVER + "/comment_file/mid/\(mid)/document_srl/\(document_srl)/comment_srl/\(comment_srl)"
        
        imageUpload(imageData: imageData, url: url) { (isSuccess, response) in
            if isSuccess {
                completion(true, response)
            } else {
                completion(false, response)
            }
        }
    }
    
    // MARK: - Community 개선 - 이미지 업로드 로직 (게시글, 댓글)
    private static func imageUpload(imageData: Data,
                            url: String,
                            completion: @escaping (Bool, Any) -> Void) {
        
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData ,withName: "userfile" ,fileName: "\(DateUtils.currentTimeMillis()).jpg" ,mimeType:  "image/jpeg" )
        }, to: url).response { response in
            guard let statusCode = response.response?.statusCode else { return }
            if statusCode == 200 {
                completion(true, response)
            } else {
                completion(false, response)
            }
        }
    }
    
    // 게시판 - 공지사항 리스트
    static func getNoticeList(completion: @escaping (Bool, Any) -> Void) {
        AF.request(Const.EV_PAY_SERVER + "/board/board_notice/list")
            .responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 공지사항 내용
    static func getNoticeContent(noticeId: Int, completion: @escaping (Bool, Any) -> Void) {
        AF.request(Const.EV_PAY_SERVER + "/board/board_notice/content?id=\(noticeId)")
            .responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 카테고리별 게시판 가져오기
    static func getBoard(category: String, bmId: Int = -1, page: Int = -1, count: Int = -1, mine: Bool = false, ad: Bool = true, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "category": category,
            "page": page,
            "page_count": count,
            "mine": mine
        ]
/*
        if category.elementsEqual(Board.BOARD_CATEGORY_COMPANY) {
            reqParam.updateValue(bmId, forKey: "bm_id")
            reqParam.updateValue(false, forKey: "ad") // 사업자 게시판 광고 포함하지 않음
        } else {
            reqParam.updateValue(true, forKey: "ad") // true: 게시글에 광고 포함. false: 광고 불포함
        }
*/
        AF.request(Const.EV_PAY_SERVER + "/board/board/contents",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 선택한 충전소 게시판 가져오기
    static func getChargerBoard(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "category": Board.BOARD_CATEGORY_CHARGER,
            "charger_id": chargerId,
            "page": -1,
            "page_count": -1,
            "ad":true
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/board/board/contents",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - board id 에 해당하는 본문, 댓글 가져오기
    static func getBoardContent(category: String, boardId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "category": category,
            "brd_id": boardId,
            "page": -1,
            "page_count": -1,
            "ad":false
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/board/board/contents",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 카테고리별 게시판 본문 작성
    static func postBoard(category: String, bmId: Int, chargerId: String = "", content: String, hasImage: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "category": category,
            "charger_id": chargerId,
            "bm_id": bmId,
            "content": content,
            "has_image": hasImage
        ]
        AF.request(Const.EV_PAY_SERVER + "/board/board/create",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 본문 수정
    static func editBoard(category: String, boardId: Int, content: String, editImage: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "category": category,
            "brd_id": boardId,
            "content": content,
            "edit_image": editImage
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/board/board/edit",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 본문 삭제
    static func deleteBoard(category: String, boardId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "category": category,
            "brd_id": boardId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/board/board/delete",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 댓글 등록
    static func postReply(category: String, boardId: Int, content: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "category": category,
            "brd_id": boardId,
            "content": content
        ]

        AF.request(Const.EV_PAY_SERVER + "/board/reply/create",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 댓글 수정
    static func editReply(category: String, replyId: Int, content: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "category": category,
            "reply_id": replyId,
            "content": content
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/board/reply/edit",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 댓글 삭제
    static func deleteReply(category: String, boardId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "category": category,
            "reply_id": boardId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/board/reply/delete",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 각 게시판 마지막 글 id 가져오기
    static func getBoardData(completion: @escaping (Bool, Any) -> Void) {
        AF.request(Const.EV_PAY_SERVER + "/board/board_data/info")
            .responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 운영기관 정보
    static func getCompanyInfo(updateDate: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "update_date": updateDate
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/company/v2/company/info",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 충전소 리스트
    static func getStationInfo(updateDate: String, completion: @escaping (Bool, Data?) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "last_update" : updateDate,
            "version" : Server.VERSION
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/charger/v1/station/station",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseData(response: response, completion: completion) }
    }
    
    // Station - 충전소 상태 정보
    static func getStationStatus(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/charger/v1/station/station_status",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 충전소 리스트 charger info
    static func getChargerInfo(chargerId : String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "charger_id": chargerId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/charger/v1/station/charger",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
   // Station - 충전소 상태 정보
    static func getChargerStatus(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/charger/v1/station/status",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 충전소 상태 정보
    static func getChargerDetail(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "charger_id": chargerId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/charger/v1/station/detail",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 충전소 상세 정보
    static func getStationDetail(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "charger_id": chargerId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/charger/v1/station/detail",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 본인이 등록한 평점 가져오기
    static func getGrade(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "charger_id": chargerId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/charger/grade/member",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 평점 등록하기
    static func addGrade(chargerId: String, point: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "charger_id": chargerId,
            "sp": point
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/charger/grade/register",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 평점 삭제하기
    static func deleteGrade(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "charger_id": chargerId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/charger/grade/unregister",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 전기차 정보 - 전기차 리스트 가져오기
    static func getEvList(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/ev/ev_models/list",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 전기차 정보 - 전기차 모델 및 차량 정보 가져오기
    static func getEvModelList(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/ev/ev_models/info",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 제보하기 - 기존에 있는 충전소의 위치정보 수정 요청
    static func modifyReport(info: ReportCharger, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "report_id": info.report_id,
            "type_id": info.type_id!,
            "charger_id": info.charger_id!,
            "lat": info.lat!,
            "lon": info.lon!,
            "snm": info.snm!,
            "adr": info.adr!,
            "adr_dtl": info.adr_dtl!
            ]
        
        AF.request(Const.EV_PAY_SERVER + "/charger/report/modify",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 제보하기 - 제보내역 삭제
    static func deleteReport(reportId: Int, typeId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "report_id": reportId,
            "type_id": typeId
            ]
        
        AF.request(Const.EV_PAY_SERVER + "/charger/report/delete",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 제보하기 - 제보 정보 가져오기
    static func getReportInfo(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "charger_id": chargerId
            ]
        
        AF.request(Const.EV_PAY_SERVER + "/charger/report/info",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 제보하기 - 나의 제보 내역 리스트 가져오기
    static func getReportList(reportId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "report_id": reportId
            ]

        AF.request(Const.EV_PAY_SERVER + "/charger/report/my_report",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseData(response: response, completion: completion) }
    }
    
    // 이벤트 - 리스트 가져오기
    static func getEventList(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId,
            "memberId": MemberManager.shared.memberId
            ]
        
        AF.request(Const.EV_PAY_SERVER + "/event/Event/getEventList",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // MARK: - AWS 프로모션(광고/이벤트) click/view event 전송
    static func countEventAction(eventId: [String], action: Promotion.Action, page: Promotion.Page, layer: Promotion.Layer) {
        guard !eventId.isEmpty else { return }
        
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "mb_id": MemberManager.shared.mbId,
            "event_ids": eventId,
            "action": action,
            "page": page.rawValue,
            "layer": layer.rawValue
        ]
        _ = AF.request("\(Const.AWS_SERVER)/promotion/log", method: .post, parameters: reqParam, encoding: JSONEncoding.default)
    }
    
    // 쿠폰 - 리스트 가져오기
    static func getCouponList(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId
            ]
        
        AF.request(Const.EV_PAY_SERVER + "/event/coupon/getCouponList",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 쿠폰 - 쿠폰코드 등록
    static func registerCoupon(couponCode:String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "coupon_code": couponCode
            ]
        
        AF.request(Const.EV_PAY_SERVER + "/event/coupon/register_coupon",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // MARK: - 게시판 광고 리스트 조회
    static func getBoardAds(client_id: String, completion: @escaping (Bool, Data?) -> Void) {
        AF.request(Const.EV_PAY_SERVER + "/ad/ad_board/get_list/client_id/\(client_id)",
                          method: .get,
                          parameters: nil,
                          encoding: JSONEncoding.default)
            .validate()
            .responseData { response in responseData(response: response, completion: completion) }
    }
    
    // 광고 - large image 정보 요청
    static func getAdLargeInfo(type: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "mb_id": MemberManager.shared.mbId,
            "type": type
        ]
        AF.request(Const.EV_PAY_SERVER + "/ad/ad_large/get_info",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // MARK: - 기존 서버 프로모션(광고/이벤트) click/view event 전송
    static func countAdAction(eventId: [String], action: Int) {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "mb_id": MemberManager.shared.mbId,
            "event_ids": eventId,
            "action": action
        ]
        AF.request(Const.EV_PAY_SERVER + "/event/Event/add_count",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
    }

    static func getUpdateGuide(guide_version: Int, app_version: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "app_version": app_version,
            "guide_version": guide_version,
            "os": "IOS"
        ]
        AF.request(Const.EV_PAY_SERVER + "/docs/guide/guide_url",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    /*
     * 결제
     */
    // Payment Regist
    static func getPayRegisterStatus(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId
        ]
        AF.request(Const.EV_PAY_SERVER + "/pay/v2/evPay/checkRegistration",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    static func getPayRegisterInfo (completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "mb_id": MemberManager.shared.mbId
        ]
        AF.request(Const.EV_PAY_SERVER + "/pay/evPay/registrationInfo",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    static func deletePayMember (completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "mb_id": MemberManager.shared.mbId
        ]
        AF.request(Const.EV_PAY_SERVER + "/pay/evPay/deletePayMember",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    static func getFailedPayList (completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId
        ]
        AF.request(Const.EV_PAY_SERVER + "/pay/v2/evPay/getFailedPayList",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    static func repayCharge (usePoint: Int, completion: @escaping (Bool, Data?) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "use_point": usePoint
        ]
        AF.request(Const.EV_PAY_SERVER + "/pay/v2/evPay/repay",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseData(response: response, completion: completion) }
    }

    // QR 충전
    static func getChargerInfo(cpId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId,
            "cp_id": cpId
        ]
        AF.request(Const.EV_PAY_SERVER + "/charger/charger_info/info",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 충전 시작 요청
    static func openCharger(cpId: String, connectorId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId,
            "cp_id": cpId,
            "connector_id": connectorId
        ]

        AF.request(Const.EV_PAY_SERVER + "/charger/app_charging/open",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 충전 종료 요청
    static func stopCharging(chargingId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId,
            "charging_id": chargingId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/charger/app_charging/stop",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 충전 상태 요청
    static func getChargingStatus(chargingId: String, completion: @escaping (Bool, Any) -> Void) {
        
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId,
            "charging_id": chargingId
        ]
        AF.request(Const.EV_PAY_SERVER + "/charger/app_charging/status",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 충전 결과 요청
    static func getChargingResult(chargingId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId,
            "charging_id": chargingId
        ]
        AF.request(Const.EV_PAY_SERVER + "/charger/app_charging/result",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // 충전 이력 조회
    static func getCharges(isAllDate: Bool, sDate: String, eDate: String, completion: @escaping (Bool, Data?) -> Void) {
        var reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId,
        ]
        if !isAllDate {
            reqParam["s_date"] = sDate
            reqParam["e_date"] = eDate
        }
        
        AF.request(Const.EV_PAY_SERVER + "/charger/v2/app_charging/history",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseData(response: response, completion: completion) }
    }
    
    // EV member 충전 가격 조회
    static func getChargePriceForEvInfra(completion: @escaping (Bool, Any) -> Void){
        AF.request(Const.EV_PAY_SERVER + "/charger/charge_price/ev_infra")
        .responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // Each Membership 충전 가격 조회
    static func getMembershipCahrgePrice(completion: @escaping (Bool, Any) -> Void){
        let reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId
        ]
        AF.request(Const.EV_PAY_SERVER + "/charger/charge_price/each_company",
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseData { response in responseData(response: response, completion: completion) }
    }
    
    // 충전 - 포인트 사용
    static func usePoint(point: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "point": point
        ]
        AF.request(Const.EV_PAY_SERVER + "/charger/app_charging/use_point",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // charging id 요청
    static func getChargingId(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId
        ]
        AF.request(Const.EV_PAY_SERVER + "/charger/app_charging/getChargingId",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    static func getIntroImage(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId
        ]
        AF.request(Const.EV_PAY_SERVER + "/event/intro_event/intro",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // Closed Beta Test 정보 가져오기
    static func getCBTInfo(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId
        ]
        AF.request(Const.EV_PAY_SERVER + "/event/cbt/info",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // download url file
    static func getData(url: URL, completion: @escaping (Bool, Data?) -> Void) {
        AF.request(url).responseData { (response) in
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
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(contentsKind, withName: "kind" , mimeType: "text/plain; charset=UTF-8")
            multipartFormData.append(uploadFileName, withName: "file_name" , mimeType: "text/plain; charset=UTF-8")
            multipartFormData.append(uploadTargetId, withName: "target_id" , mimeType: "text/plain; charset=UTF-8")
            multipartFormData.append(contentsSequence ,  withName:"sequence" ,  mimeType: "text/plain; charset=UTF-8" )
            multipartFormData.append(data ,  withName:"file" ,  fileName : filename ,  mimeType :  "image/jpeg" )
        }, to: Const.EV_PAY_SERVER + "/data/image_uploader/upload_image").response { response in
            guard let statusCode = response.response?.statusCode else { return }
            if statusCode == 200 {
                completion(true, response)
            } else {
                completion(false, response)
            }
        }
    }
    
    // admob reward
    static func postRewardVideo( type : String,  amount : Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId,
            "type" :type,
            "amount" : amount
        ]
        AF.request(Const.EV_PAY_SERVER + "/ad/ad_reward/reward_video",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }

    // get reward point
    static func getRewardPoint(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId
        ]
        AF.request(Const.EV_PAY_SERVER + "/ad/ad_reward/reward_point/mb_id/\(MemberManager.shared.mbId)" ,
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    
    }
    
    //
    static func postCheckRewardVideoAvailable(completion: @escaping (Bool, Any) -> Void){
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.shared.mbId
        ]
        
        AF.request(Const.EV_PAY_SERVER + "/ad/ad_reward/reward_video_available" ,
                      method: .post, parameters: reqParam, encoding: JSONEncoding.default)
        .validate().responseData { response in responseJson(response: response, completion: completion) }
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
        
        AF.request(url,
                      method: .get, parameters: nil, encoding: JSONEncoding.default)
        .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // MARK: - 비밀번호 확인
    static func getCheckPassword(password: String, cardNo: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.shared.mbId,
            "mb_pw": password,
            "card_no": cardNo
        ]
        
        printLog(out: "getCheckPassword : \(reqParam)")
        
        AF.request(Const.EV_PAY_SERVER + "/member/membership_card/check_password",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
    
    // MARK: - 카드 재발급
    static func postReissueMembershipCard(model: ReissuanceModel, completion: @escaping (Bool, Any) -> Void) {
        printLog(out: "Request JSON : \(model.toParam)")
        AF.request(Const.EV_PAY_SERVER + "/member/membership_card/reissue_membership",
                          method: .post, parameters: model.toParam, encoding: JSONEncoding.default)
            .validate().responseData { response in responseJson(response: response, completion: completion) }
    }
}

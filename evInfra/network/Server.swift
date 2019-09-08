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
    
    // User - 정보 등록
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
    
    // User - FCM 등록
    static func registerFCM(fcmId: String, uid: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "fcm_id": fcmId,
            "device_id": uid
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/user/registerFcm",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // User - push message 알림 설정
    static func updateNotificationState(state: Bool, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "receive_push": Int(truncating: NSNumber(value: state))
        ]
        
        Alamofire.request(Const.EV_PAY_SERVER + "/member/user/setNotification",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 회원 가입
    static func signUp(email: String, emailVerify: Bool, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "user_id": MemberManager.getUserId(),
            "nickname": UserDefault().readString(key: UserDefault.Key.MB_NICKNAME),
            "profile": UserDefault().readString(key: UserDefault.Key.MB_PROFILE_NAME),
            "email": email,
            "email_cert": emailVerify
        ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/member/member/signUp.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 회원 - 로그인
    // public static let urlMemberLogin =
    static func login(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "user_id": MemberManager.getUserId()
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/member/member/login.do",
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
        
        Alamofire.request(Const.EV_SERVER_IP + "/member/member/updateInfo.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 즐겨찾기 - 목록 가져오기
    static func getFavoriteList(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId()
        ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/member/favorite/list.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 즐겨찾기 - 충전소 즐겨찾기 등록, 해제
    static func setFavorite(chargerId: String, mode: Bool, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "charger_id": chargerId,
            "mode": mode
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/member/favorite/updateFavorite.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 즐겨찾기 - 즐겨찾기 등록한 충전소 상태변화 알림 on/off
    static func setFavoriteAlarm(chargerId: String, state: Bool, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "charger_id": chargerId,
            "noti": state
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/member/favorite/setNotification.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 운영기관 정보
    static func getCompanyInfo(updateDate: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": "1",
            "update_date": updateDate
        ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/company/info.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 충전소 리스트
    static func getStationList(completion: @escaping (Bool, Data?) -> Void) {
        Alamofire.request(Const.EV_SERVER_IP + "/charger/stationList.do",
                          method: .post, parameters: ["req_ver":1], encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseData(response: response, completion: completion) }
    }
    
    // Station - 충전소 상태 정보
    static func getStationStatus(completion: @escaping (Bool, Any) -> Void) {
        Alamofire.request(Const.EV_SERVER_IP + "/charger/stationStatus.do",
                          method: .post, parameters: ["req_ver":1], encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 충전소 상세 정보
    static func getStationInfo(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "charger_id": chargerId
        ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/charger/chargerInfo.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // Station - 충전소 이용률 데이터
    static func getStationUsage(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "member_id": MemberManager.getMemberId(),
            "charger_id": chargerId
        ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/charger/stationUsage.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 지킴이 - 대상 충전소 리스트
    static func getStationListForGuard(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "member_id": MemberManager.getMemberId()
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/charger/stationList/guard.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 지킴이 - 현장점검표 링크 가져오기
    static func getChecklistLink(completion: @escaping (Bool, Any) -> Void) {
        Alamofire.request(Const.EV_SERVER_IP + "/guard/checklist", method: .get)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 선택한 충전소의 게시판 가져오기
    static func getChargerBoard(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "member_id": MemberManager.getMemberId(),
            "brd_category": BoardData.BOARD_CATEGORY_CHARGER,
            "charger_id": chargerId,
            "ad" : true
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/board/get.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 카테고리별 게시판 가져오기
    static func getBoard(category: String, companyId: String = "", page: Int = -1, count: Int = -1, mine: Bool = false, ad: Bool = true, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "member_id": MemberManager.getMemberId(),
            "brd_category": category,
            "company_id": companyId,
            "page": page,
            "page_count": count,
            "mine": mine,
            "ad" : true
            ]

        Alamofire.request(Const.EV_SERVER_IP + "/board/get.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - board id 에 해당하는 본문, 댓글 가져오기
    static func getBoardContent(category: String, boardId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "member_id": MemberManager.getMemberId(),
            "brd_category": category,
            "brd_id": boardId
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/board/get.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 카테고리별 게시판 본문 작성
    static func postBoard(category: String, companyId: String = "", chargerId: String = "", content: String, hasImage: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "member_id": MemberManager.getMemberId(),
            "brd_category": category,
            "company_id": companyId,
            "charger_id": chargerId,
            "content": content,
            "has_image": hasImage
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/board/post.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 본문 수정
    static func editBoard(category: String, boardId: Int, content: String, hasImage: Int, editImage: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "member_id": MemberManager.getMemberId(),
            "brd_category": category,
            "board_id": boardId,
            "content": content,
            "filename": "",
            "has_image": hasImage,
            "edit_image": editImage
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/board/edit.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 본문 삭제
    static func deleteBoard(category: String, boardId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "member_id": MemberManager.getMemberId(),
            "brd_category": category,
            "board_id": boardId
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/board/delete.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 댓글 등록
    static func postReply(category: String, boardId: Int, content: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "member_id": MemberManager.getMemberId(),
            "brd_category": category,
            "board_id": boardId,
            "content": content
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/board/setReply.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 댓글 수정
    static func editReply(category: String, replyId: Int, content: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "member_id": MemberManager.getMemberId(),
            "brd_category": category,
            "reply_id": replyId,
            "content": content
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/board/editReply.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 댓글 삭제
    static func deleteReply(category: String, boardId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "member_id": MemberManager.getMemberId(),
            "brd_category": category,
            "board_id": boardId
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/board/delReply.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 게시판 - 각 게시판 마지막 글 id 가져오기
    static func getLastBoardId(completion: @escaping (Bool, Any) -> Void) {
        Alamofire.request(Const.EV_SERVER_IP + "/board/boardData/getLastBoardId.do")
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 제보하기 - 제보 등록
    static func addReport(info: ReportData.ReportChargeInfo, typeId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "pkey": info.pkey!,
            "type_id": typeId,
            "lat": info.lat!,
            "lon": info.lon!,
            "snm": info.snm!,
            "adr": info.adr!,
            "utime": info.utime!,
            "tel": info.tel!,
            "pay": info.pay!,
            "company_id": info.companyID!,
            "clist": info.clist
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/report/addReportCharger.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 제보하기 - 제보내역 수정
    static func modifyReport(info: ReportData.ReportChargeInfo, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "type_id": info.type!,
            "charger_id": info.chargerID!,
            "lat": info.lat!,
            "lon": info.lon!,
            "snm": info.snm!,
            "adr": info.adr!
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/report/replaceReportModfiy.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 제보하기 - 제보내역 삭제
    static func deleteReport(key: Int, typeId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "pkey": key,
            "type": typeId
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/report/reportDelete.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 제보하기 - 제보 정보 가져오기
    static func getReportInfo(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "charger_id": chargerId
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/report/getReportInfo.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 제보하기 - 상세 내역 가져오기
    static func getReportCurInfo(key: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "pkey": key
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/report/getReportCurInfo.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 제보하기 - 나의 제보 내역 리스트 가져오기
    static func getReportList(key: Int, completion: @escaping (Bool, Data?) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "pkey": key
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/report/getReportBoardList.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseData(response: response, completion: completion) }
    }
    
    // 평점 - 점수 가져오기
    static func getGrade(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "charger_id": chargerId
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/grade/chargeGradeGet.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 평점 - 점수 등록하기
    static func addGrade(chargerId: String, point: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "charger_id": chargerId,
            "sp": point
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/grade/chargeGradeAdded.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 평점 - 점수 삭제하기
    static func deleteGrade(chargerId: String, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "mb_id": MemberManager.getMbId(),
            "charger_id": chargerId
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/grade/chargeGradeDelete.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 전기차 정보 - 전기차 리스트 가져오기
    static func getEvList(completion: @escaping (Bool, Any) -> Void) {
        Alamofire.request(Const.EV_SERVER_IP + "/evModel/getEvList.do")
            .responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 전기차 정보 - 전기차 모델 및 차량 정보 가져오기
    static func getEvModelList(completion: @escaping (Bool, Any) -> Void) {
        Alamofire.request(Const.EV_SERVER_IP + "/evModel/getEvModels.do")
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
    
    // 이벤트 - 응모
    static func acceptEvent(eventId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "event_id": eventId
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/event/accept.do",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    // 이벤트 - 참여 가능한 이벤트인지 검증
    static func verifyEvent(eventId: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "event_id": eventId
            ]
        
        Alamofire.request(Const.EV_SERVER_IP + "/event/verify.do",
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
    static func uploadImage(data: Data, filename: String, kind: Int, completion: @escaping (Bool, Any) -> Void){
        let uploadFileName = filename.data(using: .utf8)!
        let contentsKind = ("\(kind)").data(using: .utf8)!
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(contentsKind, withName: "kind" , mimeType: "text/plain; charset=UTF-8")
            multipartFormData.append(uploadFileName, withName: "filename" , mimeType: "text/plain; charset=UTF-8")
            multipartFormData.append(data ,  withName:"file" ,  fileName : "upload.jpg" ,  mimeType :  "image/jpeg" )
        }, to: Const.EV_SERVER_IP + "/imageUploader/imageUpload", encodingCompletion: { encodingResult in
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
    
    static func getPoint(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId()
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/charger_info/info",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
    static func openCharger(cpId: String, connectorId: String, point: Int, completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "mb_id": MemberManager.getMbId(),
            "cp_id": cpId,
            "connector_id": connectorId,
            "point": point
        ]

        Alamofire.request(Const.EV_PAY_SERVER + "/charger/app_charging/open",
                          method: .post, parameters: reqParam, encoding: JSONEncoding.default)
            .validate().responseJSON { response in responseJson(response: response, completion: completion) }
    }
    
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
    
    // 충전가능 충전소
    static func getChargerListForPayment(completion: @escaping (Bool, Any) -> Void) {
        let reqParam: Parameters = [
            "req_ver": 1,
            "member_id": MemberManager.getMemberId()
        ]
        Alamofire.request(Const.EV_PAY_SERVER + "/charger/charger_info/payableChargerList",
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
}

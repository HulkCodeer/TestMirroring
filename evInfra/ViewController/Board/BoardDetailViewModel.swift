//
//  BoardDetailViewModel.swift
//  evInfra
//
//  Created by PKH on 2022/01/24.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

class BoardDetailViewModel {
    
    var listener: ((BoardDetailResponseData?) -> Void)?
    
    private var detailData: BoardDetailResponseData? = nil {
        didSet {
            self.listener?(detailData)
        }
    }
    
    func fetchBoardDetail(mid: String, document_srl: String) {
        Server.fetchBoardDetail(mid: mid, document_srl: document_srl) { responseData in
            guard let responseData = responseData as? BoardDetailResponseData else { return }
            self.detailData = responseData
        }
    }
    
    func deleteBoard(document_srl: String, completion: @escaping (Bool) -> Void) {
        Server.deleteBoard(document_srl: document_srl) { (isSuccess, response) in
            if isSuccess {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func postComment(mid: String, documentSRL: String, recomment: Recomment?, content: String, isRecomment: Bool, image: UIImage?, completion: @escaping (Bool) -> Void) {
        
        Server.postComment(mid: mid,
                           documentSRL: documentSRL,
                           recomment: recomment,
                           content: content,
                           isRecomment: isRecomment) { isSuccess, value in
            if isSuccess {
                if let results = value as? Dictionary<String, String>,
                    let commentSRL = results["comment_srl"] {
                    
                    guard let image = image else {
                        completion(true)
                        return
                    }
                    
                    Server.commentImageUpload(mid: mid, document_srl: documentSRL, comment_srl: commentSRL, image: image) { isSuccess, response in
                        if isSuccess {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    }
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    func isMyBoard(mb_id: String) -> Bool {
        let memberMB_ID = String(MemberManager.getMbId())
        return memberMB_ID.elementsEqual(mb_id)
    }
    
    func counOfComments() -> Int {
        guard let comments = detailData?.comments else { return 0 }
        return comments.count
    }
    
    func getDetailData() -> BoardDetailResponseData? {
        guard let data = detailData else { return nil }
        return data
    }
    
    func getComment(at index: Int) -> Comment {
        guard let comments = detailData?.comments else { return Comment() }
        return comments[index]
    }
    
    func setLikeCount(srl: String, isComment: Bool, completion: @escaping (Bool, Any?) -> Void) {
        Server.setLikeCount(srl: srl, isComment: isComment) { (isSuccess, value) in
            if isSuccess {
                if let response = value as? Dictionary<String, String> {
                    let message = response["error"]
                    completion(true, message)
                } else {
                    completion(true, nil)
                }
            } else {
                completion(false, nil)
            }
        }
    }
    
    func reportBoard(document_srl: String, completion: @escaping (Bool, String) -> Void) {
        Server.reportBoard(document_srl: document_srl) { (isSuccess, value) in
            if isSuccess {
                if let dictionary = value as? Dictionary<String, String> {
                    completion(true, dictionary["error"] ?? "")
                } else {
                    completion(true, "게시글이 신고되었습니다.")
                }
            } else {
                completion(false, "서버와 통신이 원활하지 않습니다. 잠시후 다시 시도해 주세요.")
            }
        }
    }
}

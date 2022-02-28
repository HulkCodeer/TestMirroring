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
    
    func deleteBoardComment(documentSRL: String, commentSRL: String, completion: @escaping (Bool) -> Void) {
        Server.deleteBoardComment(documentSRL: documentSRL, commentSRL: commentSRL) { (isSuccess, response) in
            if isSuccess {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func modifyBoardComment(commentParameter: CommentParameter,
                            completion: @escaping (Bool) -> Void) {
        Server.modifyBoardComment(commentParameter: commentParameter) { isSuccess, value in
            if isSuccess {
                if let results = value as? Dictionary<String, String>,
                    let commentSRL = results["comment_srl"] {
                    
                    guard let image = commentParameter.image else {
                        completion(true)
                        return
                    }
                    
                    if let previousFiles = commentParameter.comment?.files {
                        let file = previousFiles[0]
                        // TODO: 첨부파일 삭제
                        Server.deleteDocumnetFile(documentSRL: commentSRL, fileSRL: file.file_srl!, isCover: file.cover_image!) { isSuccess, response in
                            if isSuccess {
                                if let value = response as? String,
                                    value.contains("success") {
                                    debugPrint("이미지 삭제 완료")
                                } else {
                                    completion(false)
                                }
                            } else {
                                completion(false)
                            }
                        }
                    }
                    
                    Server.commentImageUpload(mid: commentParameter.mid,
                                              document_srl: commentSRL,
                                              comment_srl: commentSRL,
                                              image: image) { isSuccess, response in
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
    
    func postComment(commentParameter: CommentParameter,
                     completion: @escaping (Bool) -> Void) {
        Server.postComment(commentParameter: commentParameter) { isSuccess, value in
            if isSuccess {
                if let results = value as? Dictionary<String, String>,
                    let commentSRL = results["comment_srl"] {
                    
                    guard let image = commentParameter.image else {
                        completion(true)
                        return
                    }
                    
                    Server.commentImageUpload(mid: commentParameter.mid,
                                              document_srl: commentSRL,
                                              comment_srl: commentSRL, image: image) { isSuccess, response in
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

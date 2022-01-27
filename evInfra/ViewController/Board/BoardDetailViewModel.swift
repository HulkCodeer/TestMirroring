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
    
    func setLikeCount(document_srl: String, completion: @escaping (Bool) -> Void) {
        Server.setLikeCount(document_srl: document_srl) { (isSuccess, _) in
            if isSuccess {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}

//
//  BoardListViewModel.swift
//  evInfra
//
//  Created by PKH on 2022/02/28.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

internal final class BoardListViewModel {
    
    var listener: ((BoardResponseData?) -> Void)?
    
    private var boardResponseData: BoardResponseData? = nil {
        didSet {
            self.listener?(boardResponseData)
        }
    }
    
    private var indexOfAd: Int = 0
    private var adList: [BoardListItem] = [BoardListItem]()
    private var categoryType: Board.CommunityType = .FREE
    
    internal init(_ type: Board.CommunityType) {
        let adType: Promotion.Page = Board.CommunityType.convertToEventKey(communityType: type)
        
        EIAdManager.sharedInstance.getAdsList(page: adType, layer: Promotion.Layer.mid) { adsList in
            self.adList = adsList.map { BoardListItem($0) }
        }
    }
    
    func fetchFirstBoard(mid: String, sort: Board.SortType, currentPage: Int, mode: String) {
        Server.fetchBoardList(mid: mid,
                              page: "\(currentPage)",
                              mode: mode,
                              sort: sort.rawValue,
                              searchType: "",
                              searchKeyword: "") { (isSuccess, value) in
            guard isSuccess else { return }
            guard let data = value else { return }
            
            let decoder = JSONDecoder()
            
            do {
                var result = try decoder.decode(BoardResponseData.self, from: data)
                let countOfList = result.list!.count
                var boardIndex = countOfList/2
                
                
                guard countOfList == 20 else {
                    self.boardResponseData = result
                    return
                }
                
                // 광고 게시글 insert
                if !self.adList.isEmpty {
                    for _ in [currentPage, currentPage+1] {
                        result.list?.insert(self.adList[self.indexOfAd], at: boardIndex)
                        boardIndex = boardIndex + 10
                        self.indexOfAd += 1
                        
                        if self.indexOfAd == self.adList.count {
                            self.indexOfAd = 0
                        }
                    }
                }
                
                self.boardResponseData = result
            } catch {
                debugPrint("error")
            }
        }
    }
    
    func fetchNextBoard(mid: String, sort: Board.SortType, currentPage: Int, mode: String) {
        Server.fetchBoardList(mid: mid,
                              page: "\(currentPage)",
                              mode: mode,
                              sort: sort.rawValue,
                              searchType: "",
                              searchKeyword: "") { (isSuccess, value) in
            guard isSuccess else { return }
            guard let data = value else { return }
            
            let decoder = JSONDecoder()
            
            do {
                var result = try decoder.decode(BoardResponseData.self, from: data)
                let countOfList = result.list!.count
                var boardIndex = countOfList/2
                
                guard countOfList == 20 else {
                    self.boardResponseData = result
                    return
                }
                
                // 광고 게시글 insert
                if !self.adList.isEmpty {
                    for _ in [currentPage, currentPage+1] {
                        result.list?.insert(self.adList[self.indexOfAd], at: boardIndex)
                        boardIndex = boardIndex + 10

                        self.indexOfAd += 1
                        if self.indexOfAd == self.adList.count {
                            self.indexOfAd = 0
                        }
                    }
                }

                self.boardResponseData = result
            } catch {
                debugPrint("error")
            }
        }
    }
}

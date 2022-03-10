//
//  BoardListViewModel.swift
//  evInfra
//
//  Created by PKH on 2022/02/28.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

class BoardListViewModel {
    
    var listener: ((BoardResponseData?) -> Void)?
    
    private var boardResponseData: BoardResponseData? = nil {
        didSet {
            self.listener?(boardResponseData)
        }
    }
    
    private var boardAdList: [BoardListItem] = [BoardListItem]()
    
    init() {
        fetchBoardAdsToBoardListItem()
    }
    
    func fetchFirstBoard(mid: String, sort: Board.SortType, currentPage: Int, mode: String) {
        
        Server.fetchBoardList(mid: mid,
                              page: "\(currentPage)",
                              mode: mode,
                              sort: sort.rawValue,
                              searchType: "",
                              searchKeyword: "") { (isSuccess, value) in
            if isSuccess {
                guard let data = value else { return }
                let decoder = JSONDecoder()
                
                do {
                    var result = try decoder.decode(BoardResponseData.self, from: data)
                    let countOfList = result.list!.count
                    var boardIndex = countOfList/2
                    
                    // TODO: 데이터 갯수 20개이하 일 경우, 광고데이터 세팅
                    guard countOfList == 20 else {
                        self.boardResponseData = result
                        return
                    }
                    
                    for index in [currentPage, currentPage+1] {
                        let adIndex = (index-1) % 3
                        
                        result.list?.insert(self.boardAdList[adIndex], at: boardIndex)
                        boardIndex = boardIndex + 10
                    }
                    
                    self.boardResponseData = result
                } catch {
                    debugPrint("error")
                }
            } else {
                
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
            if isSuccess {
                guard let data = value else { return }
                let decoder = JSONDecoder()
                
                do {
                    var result = try decoder.decode(BoardResponseData.self, from: data)
                    let countOfList = result.list!.count
                    var boardIndex = countOfList/2
                    
                    // TODO: 데이터 갯수 20개이하 일 경우, 광고데이터 세팅
                    guard countOfList == 20 else {
                        self.boardResponseData = result
                        return
                    }
                    
                    for index in [currentPage, currentPage+1] {
                        let adIndex = (index-1) % 3
                        
                        result.list?.insert(self.boardAdList[adIndex], at: boardIndex)
                        boardIndex = boardIndex + 10
                    }
                    
                    self.boardResponseData = result
                } catch {
                    debugPrint("error")
                }
            } else {
                
            }
        }
    }
    
    private func fetchBoardAdsToBoardListItem() {
        EIAdManager.sharedInstance.fetchBoardAdsToBoardListItem { adList in
            self.boardAdList = adList
        }
    }
}

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
    
    func fetchFirstBoard(mid: String, sort: Board.SortType, currentPage: Int) {
        
        Server.fetchBoardList(mid: mid,
                              page: "\(currentPage)",
                              mode: Board.ScreenType.FEED.rawValue,
                              sort: sort.rawValue,
                              searchType: "",
                              searchKeyword: "") { (data) in
            guard let data = data as? Data else { return }
            let decoder = JSONDecoder()
            
            do {
                let result = try decoder.decode(BoardResponseData.self, from: data)
                self.boardResponseData = result
            } catch {
                debugPrint("error")
            }
        }
    }
    
    func fetchNextBoard(mid: String, sort: Board.SortType, currentPage: Int) {
        Server.fetchBoardList(mid: mid,
                              page: "\(currentPage)",
                              mode: Board.ScreenType.FEED.rawValue,
                              sort: sort.rawValue,
                              searchType: "",
                              searchKeyword: "") { (data) in
            guard let data = data as? Data else { return }
            let decoder = JSONDecoder()
            
            do {
                let result = try decoder.decode(BoardResponseData.self, from: data)
                self.boardResponseData = result
            } catch {
                debugPrint("error")
            }
        }
    }
}

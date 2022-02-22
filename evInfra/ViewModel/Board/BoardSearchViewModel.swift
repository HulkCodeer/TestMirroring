//
//  BoardSearchViewModel.swift
//  evInfra
//
//  Created by PKH on 2022/02/17.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

final class BoardSearchViewModel {
    
    var reloadTableViewClosure: (([Keyword]) -> Void)?
    let userDefault = UserDefault()
    var keyword: String = ""
    var lastPage: Bool = false
    
    private var recentKeywords: [Keyword] = [] {
        didSet {
            self.reloadTableViewClosure?(recentKeywords)
        }
    }
    
    func countOfKeywords() -> Int {
        return recentKeywords.count
    }
    
    func filteredKeywords(keyword: String, completion: @escaping ([Keyword]) -> Void) {
        completion(recentKeywords.filter { $0.title!.hasPrefix(keyword) })
    }
    
    func keyword(at index: Int) -> Keyword {
        return recentKeywords[index]
    }
    
    func fetchSearchResultList(mid: String, page: String, searchType: String, keyword: String, completion: @escaping ([BoardListItem]) -> Void) {
        Server.fetchBoardList(mid: mid, page: page, mode: "1", sort: "0", searchType: searchType, searchKeyword: keyword) { (data) in
            
            guard let data = data as? Data else { return }
            let decoder = JSONDecoder()
            
            do {
                let result = try decoder.decode(BoardResponseData.self, from: data)

                if let updateList = result.list {
                    if updateList.count < result.size! {
                        self.lastPage = true
                    }
                    completion(updateList)
                }
            } catch {
                completion([])
            }
        }
    }
    
    func fetchKeywords(completion: @escaping ([Keyword]) -> Void) {
        if let data = userDefault.readData(key: UserDefault.Key.RECENT_KEYWORD) {
            do {
                let savedKeywords = try JSONDecoder().decode([Keyword].self, from: data)
                recentKeywords = savedKeywords
            } catch {
                recentKeywords = []
            }
        } else {
            recentKeywords = []
        }
        
        completion(recentKeywords)
    }
    
    func setKeyword(_ keyword: String) {
        self.keyword = keyword
        let keyword = Keyword(title: keyword, date: "\(Date().toYearMonthDayMillis())")

        guard !isContains(with: keyword) else { return }
        
        if let data = userDefault.readData(key: UserDefault.Key.RECENT_KEYWORD) {
            var savedKeywords = try? JSONDecoder().decode([Keyword].self, from: data)
            savedKeywords?.insert(keyword, at: 0)

            guard let encodedKeyword = try? JSONEncoder().encode(savedKeywords) else { return }
            userDefault.saveData(key: UserDefault.Key.RECENT_KEYWORD, val: encodedKeyword)
        } else {
            guard let encodedKeyword = try? JSONEncoder().encode([keyword]) else { return }
            userDefault.saveData(key: UserDefault.Key.RECENT_KEYWORD, val: encodedKeyword)
        }
        
//        fetchKeywords()
    }
    
    private func isContains(with keyword: Keyword) -> Bool {
        return recentKeywords.contains { $0.title!.equals(keyword.title!) }
    }
    
    func removeAllKeywords() {
        userDefault.removeObjectForKey(key: UserDefault.Key.RECENT_KEYWORD)
//        fetchKeywords()
        fetchKeywords { keywords in
            self.recentKeywords = keywords
        }
    }
    
    func removeKeyword(at index: Int) {
        recentKeywords.remove(at: index)
        
        guard let encodedKeyword = try? JSONEncoder().encode(recentKeywords) else { return }
        removeAllKeywords()
        
        userDefault.saveData(key: UserDefault.Key.RECENT_KEYWORD, val: encodedKeyword)
        fetchKeywords { keywords in
            self.recentKeywords = keywords
        }
    }
}

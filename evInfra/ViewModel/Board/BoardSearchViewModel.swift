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
    
    var reloadTableViewClosure: (()->())?
    let userDefault = UserDefault()
    
    private var recentKeywords: [Keyword] = [] {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    func countOfKeywords() -> Int {
        return recentKeywords.count
    }
    
    func filteredKeywords(keyword: String) -> [Keyword] {
        return recentKeywords.filter { $0.title!.hasPrefix(keyword) }
    }
    
    func keyword(at index: Int) -> Keyword {
        return recentKeywords[index]
    }
    
    func fetchKeywords() {
        if let data = userDefault.readData(key: UserDefault.Key.RECENT_KEYWORD) {
            let savedKeywords = try? JSONDecoder().decode([Keyword].self, from: data)
            recentKeywords = savedKeywords ?? []
        } else {
            recentKeywords = []
        }
    }
    
    func setKeyword(_ keyword: String) {
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
        fetchKeywords()
    }
    
    private func isContains(with keyword: Keyword) -> Bool {
        return recentKeywords.contains { $0.title!.equals(keyword.title!) }
    }
    
    func removeAllKeywords() {
        userDefault.removeObjectForKey(key: UserDefault.Key.RECENT_KEYWORD)
        fetchKeywords()
    }
    
    func removeKeyword(at index: Int) {
        recentKeywords.remove(at: index)
        
        guard let encodedKeyword = try? JSONEncoder().encode(recentKeywords) else { return }
        removeAllKeywords()
        
        userDefault.saveData(key: UserDefault.Key.RECENT_KEYWORD, val: encodedKeyword)
        fetchKeywords()
    }
}

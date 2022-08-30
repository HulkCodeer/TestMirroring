//
//  NoticeDetailReactor.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/29.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

import ReactorKit
import RxSwift

internal final class NoticeDetailReactor: ViewModel, Reactor {
    typealias Contents = (title: String, date: String?, html: String)
    enum Action {
        case loadHTML
    }
    
    enum Mutation {
        case setHTML(Contents)
    }
    
    struct State {
        var title: String = "[공지]"
        var date: String? = Date().toStringToMinute(data: "yyyy.MM.dd")
        var html: String = String()
        
        var isNewNoticeType: Bool?
    }
    
    internal var initialState: State
    let noticeID: Int
    
    init(provider: SoftberryAPI, noticeID: Int) {
        self.initialState = State()
        self.noticeID = noticeID
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadHTML:
            return Observable.empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setHTML(let contents):
            newState.title = contents.title
            newState.date = contents.date
            newState.html = contents.html
        }
        
        return newState
    }
    
    private func convertToDataModel(with result: ApiResult<Data, ApiError> ) -> Contents? {
        switch result {
        case .success(let data):
            printLog("data \(data)")
            guard let notice = try? JSONDecoder().decode(Notice.self, from: data) else { return nil }
            guard 1000 == notice.code else { return nil }
            
            printLog(out: "JsonData : \(notice)")
            return (notice.title, notice.date, notice.content) as? Contents
            
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            return nil
        }
    }
}

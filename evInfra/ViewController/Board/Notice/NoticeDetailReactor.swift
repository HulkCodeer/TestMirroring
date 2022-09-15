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
import SwiftyJSON

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
        var date: String? = Date().toYearMonthDay()     // .toString(yyyy.MM.dd)
        var html: String = String()
    }
    
    internal var initialState: State
    
    private let noticeID: Int
    
    init(provider: SoftberryAPI, noticeID: Int) {
        self.initialState = State()
        self.noticeID = noticeID
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadHTML:
            return provider.getNotice(id: noticeID)
                .convertData()
                .compactMap(convertToDataModel)
                .map { .setHTML($0) }
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
            let json = JSON(data)            
            guard 1000 == json["code"].int,
                  let notice = try? JSONDecoder().decode(Notice.self, from: data)
            else {
                let errorMsg = json["msg"].string
                errorHandler(errorMsg: errorMsg)
                return nil
            }
            
            let date = notice.dateTime.toDate()
            let dateStr = date?.toYearMonthDay()    // .toString(yyyy.MM.dd)
                        
            return (notice.title, dateStr, notice.content) as Contents
            
        case .failure(let error):
            printLog(out: "Error Message : \(error)")
            errorHandler(errorMsg: error.errorMessage)
            return nil
        }
    }

    private func errorHandler(errorMsg: String? = nil) {
        let message = errorMsg ?? "해당 공지를 찾을 수 없습니다."
        
        let errorAction = UIAlertAction(title: "OK", style: .default) { _ in
            NotificationCenter.default.post(name: NewNoticeViewController.notiReloadName, object: nil)
            GlobalDefine.shared.mainNavi?.pop()
        }
        
        UIAlertController.showAlert(title: nil, message: message, actions: [errorAction])
    }
}

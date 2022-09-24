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
    typealias Contents = (title: String, date: String, html: String)
    internal weak var delegate: NoticeReactorDelegate?

    enum Action {
        case loadHTML
    }
    
    enum Mutation {
        case setHTML(Contents)
    }
    
    struct State {
        var title: String = "[공지]"
        var date: String = String()
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
                let errorMsg = json["msg"].string ?? "데이터를 불러올 수 없습니다. 잠시 후 다시 시도해주세요."
                errorHandler(errorMsg: errorMsg)
                return nil
            }
            
            return (notice.title, notice.dateTime, notice.content) as Contents
            
        case .failure(let error):
            printLog(out: "Error Message : \(error)")
            errorHandler(errorMsg: "오류가 발생했습니다. 잠시 후 다시 시도해주세요. \n\(error.errorMessage)")
            return nil
        }
    }

    private func errorHandler(errorMsg: String) {
        Snackbar().show(message: errorMsg)
        
        delegate?.unkownDetailData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            GlobalDefine.shared.mainNavi?.pop()
        }
    }
}

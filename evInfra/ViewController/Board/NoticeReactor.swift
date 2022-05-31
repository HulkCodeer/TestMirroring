//
//  NoticeReactor.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/05/26.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import SwiftyJSON

internal final class NoticeReactor: ViewModel, Reactor {
    enum Action {
        case loadData
    }
    
    enum Mutation {
        case setNoticeList([NoticeListDataModel.Notice])
        case none
    }
    
    struct State {
        var sections = [NoticeListSectionModel]()
    }
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData:
            return self.provider
                .getNoticeList()
                .convertData()
                .compactMap(convertToDataModel)
                .map { noticeInfo in
                    .setNoticeList(noticeInfo.list) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.sections = []
        
        switch mutation {
        case .setNoticeList(let noticeList):
            newState.sections = [NoticeListSectionModel(items: noticeList)]
        case .none: break
        }
        
        return newState
    }
    
    private func convertToDataModel(with result: ApiResult<Data, ApiErrorMessage>) -> NoticeInfo? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            return NoticeInfo(jsonData)
        case .failure(let error):
            printLog(error.errorMessage)
            return nil
        }
    }
}

struct NoticeInfo {
    let code: Int
    let list: [NoticeListDataModel.Notice]
    
    init(_ json: JSON) {
        self.code = json["code"].intValue
        self.list = json["list"].arrayValue.map {
            NoticeListDataModel.Notice($0)
        }
    }
}

struct NoticeListDataModel {
    struct Notice: Codable {
        let id: String
        let title: String
        let datetime: String
        
        init(_ json: JSON) {
            self.id = json["id"].stringValue
            self.title = json["title"].stringValue
            self.datetime = Date().toStringToMinute(data: json["datetime"].stringValue)
        }
    }
}



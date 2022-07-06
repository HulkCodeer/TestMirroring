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
        case setNoticeList([NoticeListItem])
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
                .map { .setNoticeList(self.convertToItem(models: $0)) }
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
    
    private func convertToDataModel(with result: ApiResult<Data, ApiErrorMessage>) -> [NoticeListDataModel.NoticeInfo]? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            return NoticeListDataModel(jsonData).list
        case .failure(let error):
            printLog(error.errorMessage)
            return nil
        }
    }
    
    private func convertToItem(models: [NoticeListDataModel.NoticeInfo]) -> [NoticeListItem] {
        var items = [NoticeListItem]()
        for data in models {
            let reactor = NoticeCellReactor(model: data)
            items.append(.noticeListItem(reactor: reactor))
        }
        return items
    }
}

struct NoticeListDataModel {
    let code: Int
    let list: [NoticeInfo]
    
    init(_ json: JSON) {
        self.code = json["code"].intValue
        self.list = json["list"].arrayValue.map {
            NoticeInfo($0)
        }
    }
    
    struct NoticeInfo: Codable, Equatable {
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

struct NoticeDataModel {
    let code: Int
    let title: String
    let content: String
    
    init(_ code: Int, _ title: String, _ content: String) {
        self.code = code
        self.title = title
        self.content = content
    }
    
    init(_ json: JSON) {
        self.code = json["code"].intValue
        self.title = json["title"].stringValue
        self.content = json["content"].stringValue
    }
}



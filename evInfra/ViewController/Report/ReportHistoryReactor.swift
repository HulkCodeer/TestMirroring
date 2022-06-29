//
//  ReportHistoryReactor.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/06/29.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import SwiftyJSON

internal final class ReportHistoryReactor: ViewModel, Reactor {
    enum Action {
        case loadData
    }
    
    enum Mutation {
        case setReportHistoryList([ReportHistoryListItem])
        case none
    }
    
    struct State {
        var sections = [ReportHistoryListSectionModel]()
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
                .getReportHistoryList(with: 0)
                .convertData()
                .compactMap(convertToDataModel)
                .map { .setReportHistoryList(self.convertToItem(models: $0)) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.sections = []
        
        switch mutation {
        case .setReportHistoryList(let reportHistoryList):
            newState.sections = [ReportHistoryListSectionModel(items: reportHistoryList)]
        case .none: break
        }
        
        return newState
    }
    
    private func convertToDataModel(with result: ApiResult<Data, ApiErrorMessage>) -> [ReportHistoryListDataModel.ReportHistoryInfo]? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            return ReportHistoryListDataModel(jsonData).list
        case .failure(let error):
            printLog(error.errorMessage)
            return nil
        }
    }
    
    private func convertToItem(models: [ReportHistoryListDataModel.ReportHistoryInfo]) -> [ReportHistoryListItem] {
        var items = [ReportHistoryListItem]()
        for data in models {
            let reactor = ReportHistoryCellReactor(model: data)
            items.append(.reportHistoryItem(reactor: reactor))
        }
        return items
    }
}

struct ReportHistoryListDataModel {
    let code: Int
    let list: [ReportHistoryInfo]
    
    init(_ json: JSON) {
        self.code = json["code"].intValue
        self.list = json["list"].arrayValue.map {
            ReportHistoryInfo($0)
        }
    }
    
    struct ReportHistoryInfo: Codable, Equatable {
        enum ReportType: String {
            case user_mode = "4"
            case user_mode_delete = "5"
        }
        
        enum ReportStatus: String {
            case finish = "1"
            case confirm = "2"
            case reject = "3"
        }
        
        let report_id: String
        let status_id: String
        let charger_id: String
        let admin_cmt: String?
        let snm: String
        let status: String
        let type: String
        let reg_date: String
        
        init(_ json: JSON) {
            self.report_id = json["report_id"].stringValue
            self.status_id = json["status_id"].stringValue
            self.charger_id = json["charger_id"].stringValue
            self.admin_cmt = json["admin_cmt"].stringValue
            self.snm = json["snm"].stringValue
            self.status = json["status"].stringValue
            self.type = json["type"].stringValue
            self.reg_date = json["reg_date"].stringValue
        }
    }
}

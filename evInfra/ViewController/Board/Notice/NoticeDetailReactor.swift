//
//  NoticeDetailReactor.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/06/27.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import SwiftyJSON

internal final class NoticeDetailReactor: ViewModel, Reactor {
    enum Action {
        case loadData(Int)
    }
    
    enum Mutation {
        case setDetailData(NoticeDataModel)
    }
    
    struct State {
        var data: NoticeDataModel?
    }
    
    internal var initialState: State
    internal var boardId: Int = -1
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData(let boardId):
            return self.provider.getNoticeDetail(with: boardId)
                .convertData()
                .compactMap(convertToDataModel)
                .map { .setDetailData($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.data = nil
        
        switch mutation {
        case .setDetailData(let detailData):
            newState.data = detailData
        }
        return newState
    }
    
    private func convertToDataModel(with result: ApiResult<Data, ApiErrorMessage>) -> NoticeDataModel? {
        switch result {
        case .success(let data):
            let json = JSON(data)
            return NoticeDataModel(json)
        case .failure(let error):
            printLog(error.errorMessage)
            return nil
        }
    }
}

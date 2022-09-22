//
//  EventReactor.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/09/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class EventReactor: ViewModel, Reactor {
    enum Action {
        case getEventList
    }
    
    enum Mutation {
        case setEventList([EventListItem])
    }
    
    struct State {
        var sections = [EventListSectionModel]()
    }
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .getEventList:
            return self.provider.getAdsList(page: .event, layer: .list)
                            .convertData()
                            .compactMap(convertToData)
                            .map(convertToEventListItem)
                            .map { eventList in
                                return .setEventList(eventList)
                            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
                        
        switch mutation {
        case .setEventList(let items):
            newState.sections = [EventListSectionModel(items: items)]
                                                    
        }
        return newState
    }
    
    private func convertToData(with result: ApiResult<Data, ApiError> ) -> [AdsInfo]? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)            
            printLog(out: "JsonData : \(jsonData)")
            
            let code = jsonData["code"].stringValue
                            
            guard "1000".equals(code) else { return nil}
            return jsonData["data"].arrayValue.map { AdsInfo($0) }
                                                                                         
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
            return nil
        }
    }
    
    private func convertToEventListItem(with model: [AdsInfo]) -> [EventListItem] {
        var items = [EventListItem]()
                
        guard !model.isEmpty else {
            return items
        }
        
        for eventItem in model {
            let reactor = EventDetailReactor(model: eventItem)
            items.append(.eventItem(reactor: reactor))
        }
                                                
        return items
    }
}


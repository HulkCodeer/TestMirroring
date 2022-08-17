//
//  PointViewReactor.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/05.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import SwiftyJSON

internal class PointHistoryReactor: ViewModel, Reactor {
    
    enum Action {
        case loadTotalPoints
        case loadPointHistory(type: EvPoint.PointType, startDate: Date, endDate: Date)
    }
    
    enum Mutation {
        case setEvPoint(EvPoint.PointType, [EvPoint])
        case setTotalPoints(totalPoint: String, expirePoint: String)
    }
    
    struct State {
        var totalPoint: String?
        var expirePoint: String?
        
        var evPointsViewItems: [EvPointViewItem]?
    }
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadTotalPoints:
            return provider.postPointHistory()
                .convertData()
                .compactMap(convertToPointHistory)
                .map { return .setTotalPoints(totalPoint: $0.totalPoint, expirePoint: $0.expirePoint) }
            
        case let .loadPointHistory(type, startDate, endDate):
            let startDateStr = startDate.toString(dateFormat: Constants.date.yearMonthDayHyphen)
            let endDateStr = endDate.toString(dateFormat: Constants.date.yearMonthDayHyphen)
            
            return provider.postPointHistory(startDate: startDateStr, endDate: endDateStr)
                .convertData()
                .compactMap { [weak self] apiResult in
                    let pointHistory = self?.convertToPointHistory(with: apiResult)
                    return pointHistory?.list
                }
                .map { pointList in return .setEvPoint(type, pointList) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setEvPoint(type, evPoints):
            newState.evPointsViewItems = convertToEvPointViewItems(type: type, evPoints: evPoints)
            
        case let .setTotalPoints(totalPoint, expirePoint):
            newState.totalPoint = totalPoint
            newState.expirePoint = expirePoint
        }
        
        return newState
    }
    
    private func convertToEvPointViewItems(type: EvPoint.PointType, evPoints: [EvPoint]) -> [EvPointViewItem] {
        var viewItems = [EvPointViewItem]()
        var evPoints = evPoints
        
        switch type {
        case .savePoint:
            evPoints = evPoints.filter { $0.loadPointType() == .savePoint }
        case .usePoint:
            evPoints = evPoints.filter { $0.loadPointType() == .usePoint}
        default:
            break
        }
        
        for (index, point) in evPoints.enumerated() {
            let previousDate = (index > 0) ? evPoints[index - 1].date : nil
            let viewItem = EvPointViewItem(evPoint: point, previousItemDate: previousDate)
            viewItems.append(viewItem)
        }
        
        return viewItems
    }
    
    private func convertToPointHistory(with result: ApiResult<Data, ApiErrorMessage>) -> PointHistory? {
        switch result {
        case .success(let data):
            let pointHistory = try? JSONDecoder().decode(PointHistory.self, from: data)
            guard 1000 == pointHistory?.code else { return nil }
            
            printLog(out: "data: \(pointHistory)")
            return pointHistory
        case .failure(let errrorMSG):
            printLog(out: "Error Message : \(errrorMSG)")
            return nil
        }
    }
    
    // MARK: Object
    
    struct EvPointViewItem {
        let evPoint: EvPoint
        let previousItemDate: String?

    }
}

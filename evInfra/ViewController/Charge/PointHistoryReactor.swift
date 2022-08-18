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
        case loadPointInfo      
        case loadPointHistory(type: EvPoint.PointType, startDate: Date, endDate: Date)
    }
    
    enum Mutation {
        case setPointInfo(totalPoint: String, expirePoint: String, point: [EvPoint])
        case setPoints(EvPoint.PointType, [EvPoint])
    }
    
    struct State {
        var totalPoint: String?
        var expirePoint: String?
        
        var evPointsViewItems: [PointViewItem] = []
        var evPointsCount: Int = 0
    }
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadPointInfo:
            let todayDate = Date().toString(dateFormat: Constants.date.yearMonthDayHyphen)

            return provider.postPointHistory(startDate: todayDate, endDate: todayDate)
            .convertData()
            .compactMap(convertToPointHistory)
            .map { return .setPointInfo(totalPoint: $0.totalPoint, expirePoint: $0.expirePoint, point: $0.list ?? []) }
            
        case let .loadPointHistory(type, startDate, endDate):
            let startDateStr = startDate.toString(dateFormat: Constants.date.yearMonthDayHyphen)
            let endDateStr = endDate.toString(dateFormat: Constants.date.yearMonthDayHyphen)
            
            return provider.postPointHistory(startDate: startDateStr, endDate: endDateStr)
                .convertData()
                .compactMap { [weak self] apiResult in
                    let pointHistory = self?.convertToPointHistory(with: apiResult)
                    return pointHistory?.list
                }
                .map { pointList in return .setPoints(type, pointList) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setPoints(type, points):
            let evPointViewItems = convertToPointViewItems(type: type, points: points)
            newState.evPointsViewItems = evPointViewItems
            newState.evPointsCount = evPointViewItems.count
            
        case let.setPointInfo(totalPoint, expirePoint, points):
            let evPointViewItems = convertToPointViewItems(type: .all, points: points)
            newState.evPointsViewItems = evPointViewItems
            newState.evPointsCount = evPointViewItems.count
            newState.totalPoint = totalPoint
            newState.expirePoint = expirePoint
        }
        
        return newState
    }
    
    private func convertToPointViewItems(type: EvPoint.PointType, points: [EvPoint]) -> [PointViewItem] {
        var pointList = points
        var viewItems = [PointViewItem]()

        switch type {
        case .savePoint:
            pointList = pointList.filter { $0.loadPointType() == .savePoint }
        case .usePoint:
            pointList = pointList.filter { $0.loadPointType() == .usePoint}
        default:
            break
        }
        
        for (index, point) in pointList.enumerated() {
            let previousDate = (index > 0) ? pointList[index - 1].date : nil
            let viewItem = PointViewItem(evPoint: point, previousItemDate: previousDate)
            viewItems.append(viewItem)
        }
        
        return viewItems
    }
    
    private func convertToPointHistory(with result: ApiResult<Data, ApiErrorMessage>) -> PointHistory? {
        switch result {
        case .success(let data):
            let pointHistory = try? JSONDecoder().decode(PointHistory.self, from: data)
            guard 1000 == pointHistory?.code else { return nil }
            
            printLog(out: "data: \(String(describing: pointHistory))")
            return pointHistory
        case .failure(let errrorMSG):
            printLog(out: "Error Message : \(errrorMSG)")
            return nil
        }
    }
    
    // MARK: Object
    
    struct PointViewItem {
        let evPoint: EvPoint
        let previousItemDate: String?

    }
}

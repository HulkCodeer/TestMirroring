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
    typealias PointType = (totalPoint: String, expirePoint: String, points: [EvPoint])
    
    enum Action {
        case loadPointInfo      
        case loadPointHistory(type: EvPoint.PointType, startDate: Date, endDate: Date)
        case setPointType(EvPoint.PointType)
    }
    
    enum Mutation {
        case setPointInfo(PointType)
        case setPoints(EvPoint.PointType, [EvPoint])
        case setPointType(EvPoint.PointType)
        case setChangePointType(Bool)
    }
    
    struct State {
        var totalPoint: String?
        var expirePoint: String?
        var pointType: EvPoint.PointType? = .all
        var isChangePointType: Bool?
        
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
            let todayDate = Date().toString(dateFormat: Constants.date.yearMonthDayKo)

            return provider.postPointHistory(startDate: todayDate, endDate: todayDate)
            .convertData()
            .compactMap(convertToPointHistory)
            .map { return .setPointInfo($0) }
            
        case let .loadPointHistory(type, startDate, endDate):
            let startDateStr = startDate.toString(dateFormat: Constants.date.yearMonthDayKo)
            let endDateStr = endDate.toString(dateFormat: Constants.date.yearMonthDayKo)
            
            return provider.postPointHistory(startDate: startDateStr, endDate: endDateStr)
                .convertData()
                .compactMap(convertToPointHistory)
                .map { return .setPoints(type, $0.points) }
            
        case let .setPointType(pointType):
            return .concat(.just(.setPointType(pointType)),
                .just(.setChangePointType(true)))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.totalPoint = nil
        newState.expirePoint = nil
        newState.pointType = nil
        newState.isChangePointType = nil
        
        switch mutation {
        case let .setPoints(type, points):
            let evPointViewItems = convertToPointViewItems(type: type, points: points)
            newState.evPointsViewItems = evPointViewItems
            newState.evPointsCount = evPointViewItems.count
            
        case let.setPointInfo(pointHistory):
            let evPointViewItems = convertToPointViewItems(type: .all, points: pointHistory.points)
            newState.evPointsViewItems = evPointViewItems
            newState.evPointsCount = evPointViewItems.count
            newState.totalPoint = pointHistory.totalPoint
            newState.expirePoint = pointHistory.expirePoint
            newState.pointType = state.pointType
        case let.setPointType(pointType):
            newState.pointType = pointType
            
        case let.setChangePointType(isChangePointType):
            newState.isChangePointType = isChangePointType
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
    
    private func convertToPointHistory(with result: ApiResult<Data, ApiErrorMessage>) -> PointType? {
        switch result {
        case .success(let data):
            let pointHistory = try? JSONDecoder().decode(PointHistory.self, from: data)
            guard 1000 == pointHistory?.code, let pointHistory = pointHistory else { return nil }
            printLog(out: "data: \(String(describing: pointHistory))")
            
            return (pointHistory.totalPoint, pointHistory.expirePoint, pointHistory.list) as? PointHistoryReactor.PointType
            
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

//
//  CarRegistrationCompleteReactor.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/30.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class CarRegistrationCompleteReactor: ViewModel, Reactor {
    enum Action {
        case deleteCarInfo
    }
    
    enum Mutation {
        case setDeleteCarComplete(Bool)
    }
    
    struct State {
        var carInfoModel: CarInfoModel        
        var isDeleteComplete: Bool?
    }
        
    internal var initialState: State
    internal var fromViewType: FromViewType = .signup
    
    init(model: CarInfoModel) {
        self.initialState = State(carInfoModel: model)
        super.init(provider: RestApi())
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .deleteCarInfo:
            return self.provider.postDeleteCarInfo(carNum: currentState.carInfoModel.carNum)
                .convertData()
                .compactMap(convertToData)
                .map {
                    GlobalDefine.shared.isChangeMainCar = true
                    GlobalDefine.shared.mainNavi?.pop()
                    return .setDeleteCarComplete($0)
                }
                   
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.isDeleteComplete = nil
                                                
        switch mutation {
        case .setDeleteCarComplete(let isComplete):
            newState.isDeleteComplete = isComplete
                    
        }
        return newState
    }
    
    private func convertToData(with result: ApiResult<Data, ApiErrorMessage> ) -> Bool? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            let carInfoModel = CarInfoModel(jsonData)
            
            let code = carInfoModel.code
                
            switch code {
            case 200:
                return true
                
            case 404:
                Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
                GlobalDefine.shared.mainNavi?.pop()
                return nil
                                                        
            default:
                Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
                return nil
            }
                                                             
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
            return nil
        }
    }
}

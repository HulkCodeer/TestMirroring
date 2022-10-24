//
//  IntroReactor.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/10/14.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON
import RealmSwift

internal final class IntroReactor: ViewModel, Reactor {
    enum Action {
        case chargerCompanyInfoList
    }
    
    enum Mutation {
        case setComplete(Bool)
    }
    
    struct State {
        var isComplete: Bool?
    }
    
    internal var initialState: State
            
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .chargerCompanyInfoList:
            var updateDate: String = ""
            let companyInfoList = softberryDBWorker.readCompanyInfoListBySortAsc()
            if companyInfoList.count > 0 {
                updateDate = softberryDBWorker.readCompanyUpdateLastDate()
            }
            
            return self.provider.getCompanyInfo(updateDate: updateDate)
                            .convertData()
                            .compactMap(convertToData)
                            .map { isComplete in
                                return .setComplete(isComplete)
                            }
                  
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.isComplete = nil
        
        switch mutation {
        case .setComplete(let isComplete):
            newState.isComplete = isComplete
                                                    
        }
        return newState
    }
    
    private func convertToData(with result: ApiResult<Data, ApiError> ) -> Bool? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            
            let code = jsonData["code"].stringValue
            
            guard code.equals("1000") else {
                Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
                return nil
            }
                                    
            softberryDBWorker.writeCompanyInfoList(list: jsonData["list"].arrayValue.map { CompanyInfoDB($0) })
            softberryDBWorker.writeLastUpdateInfo(lastDate: jsonData["last"].stringValue)
            
            return true
                                                             
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
            return nil
        }
    }
    
    private func convertToAppleData(with result: ApiResult<Data, ApiError> ) -> Bool? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            
            return true
            
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
            return nil
        }
    }
}

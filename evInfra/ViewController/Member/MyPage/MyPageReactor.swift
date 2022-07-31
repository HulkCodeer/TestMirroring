//
//  MyPageReactor.swift
//  evInfra
//
//  Created by 박현진 on 2022/07/21.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class MyPageReactor: ViewModel, Reactor {
    enum Action {
        case getMyCarList
        case changeMainCar(String)
    }
    
    enum Mutation {
        case setMyCarList([MyCarListItem])
        case setChangeMainCarComplete(Bool)
    }
    
    struct State {
        var sections = [MyCarListSectionModel]()
        
        var isChangeMainCar: Bool?
    }
    
    struct ChangeMainCarInfoParamModel: Codable {
        var memId = MemberManager.shared.mbId
        var carNum = ""
        var mainCar: Bool = false
        
        init (carNum: String, mainCar: Bool) {
            self.carNum = carNum
            self.mainCar = mainCar
        }
        
        internal func toDict() -> [String: Any] {
            if let paramData = try? JSONEncoder().encode(self) {
                if let json = try? JSONSerialization.jsonObject(with: paramData, options: []) as? [String: Any] {
                    return json ?? [:]
                } else {
                    return [:]
                }
            } else {
                return [:]
            }
        }
    }
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .getMyCarList:
            return self.provider.getMyCarList()
                .convertData()
                .compactMap(convertToData)
                .map(convertCarInfoItem)
                .map { carInfoModelList in
                    return .setMyCarList(carInfoModelList)
                }
            
        case .changeMainCar(let carNum):
            
            return self.provider.patchChangeMainCar(mainCarInfo: ChangeMainCarInfoParamModel(carNum: carNum, mainCar: true))
                .convertData()
                .compactMap(convertToChangeMainCar)
                .map { isChangeMainCar in
                    return .setChangeMainCarComplete(isChangeMainCar)
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.isChangeMainCar = nil
                                
        switch mutation {
        case .setMyCarList(let items):
            newState.sections = [MyCarListSectionModel(items: items)]
            
        case .setChangeMainCarComplete(let isChangeMainCar):
            newState.isChangeMainCar = isChangeMainCar
                                                                                        
        }
        return newState
    }
    
    private func convertToData(with result: ApiResult<Data, ApiErrorMessage> ) -> CarInfoListModel? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            let carInfoListModel = CarInfoListModel(jsonData)
            
            switch carInfoListModel.code {
            case 200: // 응답 성공
                return carInfoListModel
                                            
            default:
                return nil
            }
                                                             
        case .failure(let errorMessage):            
            let serverResult = ServerResult(JSON(parseJSON: errorMessage.errorMessage))
            switch serverResult.code {
            case 404:
                return CarInfoListModel(JSON.null)
            
            default:
                printLog(out: "Error Message : \(errorMessage)")
                Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
                return nil
            }
        }
    }
    
    private func convertToChangeMainCar(with result: ApiResult<Data, ApiErrorMessage> ) -> Bool? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            
            switch jsonData["code"] {
            case 1000: // 응답 성공
                return true
                                            
            default:
                return nil
            }
                                                             
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
            return nil
        }
    }
    
    private func convertCarInfoItem(with model: CarInfoListModel) -> [MyCarListItem] {
        var items = [MyCarListItem]()
                
        guard !model.body.isEmpty else {
            let reactor = MyPageCarListReactor(model: CarInfoModel(JSON.null))
            items.append(.myCarEmptyItem(reactor: reactor))
            return items
        }
        
        for carInfoModel in model.body {
            items.append(self.createMyCarInfoItem(carInfoModel))
        }
                
        let reactor = MyPageCarListReactor(model: CarInfoModel(JSON.null))
        items.append(.addMyCarItem(reactor: reactor))
                        
        return items
    }
    
    private func createMyCarInfoItem(_ model: CarInfoModel) -> MyCarListItem {
        let reactor = MyPageCarListReactor(model: model)

        reactor.state.compactMap { $0.isChangeMainCar }
            .map { _ in MyPageReactor.Action.changeMainCar(model.carNum) }
            .bind(to: self.action)
            .disposed(by: self.disposeBag)
        
        return .myCarInfoItem(reactor: reactor)
    }
    
//    private func createMyCarEmptyItem() -> MyCarListItem {
//        let reactor = MyPageCarListReactor(model: CarInfoModel(JSON.null))
//
//        reactor.state.compactMap { $0.isMove }
//            .asDriver(onErrorJustReturn: true)
//            .drive(onNext: { _ in
//                let reactor = CarRegistrationReactor(provider: RestApi())
//                reactor.fromViewType = .mypage
//                let viewcon = CarRegistrationViewController()
//                viewcon.reactor = reactor
//                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
//            })
//            .disposed(by: self.disposeBag)
//
//        return .myCarEmptyItem(reactor: reactor)
//    }
}

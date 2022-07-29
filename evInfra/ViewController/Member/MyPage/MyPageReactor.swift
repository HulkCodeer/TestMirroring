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
    }
    
    enum Mutation {
        case setMyCarList([MyCarListItem])
    }
    
    struct State {
        var sections = [MyCarListSectionModel]()
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
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
                                
        switch mutation {
        case .setMyCarList(let items):
            newState.sections = [MyCarListSectionModel(items: items)]
                                                                                        
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
    
    private func convertCarInfoItem(with model: CarInfoListModel) -> [MyCarListItem] {
        var items = [MyCarListItem]()
                
        guard !model.body.isEmpty else {
            items.append(self.createMyCarEmptyItem())
            return items
        }
        for carInfoModel in model.body {
            let reactor = MyPageCarListReactor(model: carInfoModel)
            items.append(.myCarInfoItem(reactor: reactor))
        }
                
        items.append(self.createAddMyCarItem())
                        
        return items
    }
    
    private func createAddMyCarItem() -> MyCarListItem {
        let reactor = MyPageCarListReactor(model: CarInfoModel(JSON.null))
        
        reactor.state.compactMap { $0.isMove }
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { _ in
                let reactor = CarRegistrationReactor(provider: RestApi())
                reactor.fromViewType = .mypage
                let viewcon = CarRegistrationViewController()
                viewcon.reactor = reactor
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
            })
            .disposed(by: self.disposeBag)
        
        return .addMyCarItem(reactor: reactor)
    }
    
    private func createMyCarEmptyItem() -> MyCarListItem {
        let reactor = MyPageCarListReactor(model: CarInfoModel(JSON.null))
        
        reactor.state.compactMap { $0.isMove }
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { _ in                
                let reactor = CarRegistrationReactor(provider: RestApi())
                reactor.fromViewType = .mypage
                let viewcon = CarRegistrationViewController()
                viewcon.reactor = reactor
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
            })
            .disposed(by: self.disposeBag)
        
        return .myCarEmptyItem(reactor: reactor)
    }
}

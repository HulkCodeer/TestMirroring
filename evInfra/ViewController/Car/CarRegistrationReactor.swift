//
//  CarRegistrationReactor.swift
//  evInfra
//
//  Created by 박현진 on 2022/07/14.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class CarRegistrationReactor: ViewModel, Reactor {
    enum ViewType {
        case carRegister
        case carOwner
        case carInquery
        case carInqueryComplete
        case none
        
        func hasNextViewType() -> ViewType {
            switch self {
            case .carRegister:
                return .carOwner
                
            case .carOwner:
                return .carInquery
                
            case .carInquery:
                return .carInqueryComplete
                
            case .carInqueryComplete:
                return .none
                                                                        
            default: return .none
            }
        }
    }
    
    enum Action {
        case moveNextView
        case registerCarInfo
        case setMoveNextView(ViewType)
        case setCarNumber(String)
        case setCarOwnerName(String)
    }
    
    enum Mutation {
        case setMoveNextView(ViewType)
        case setRegisterCarResult(CarInfoModel)
    }
    
    struct State {
        var nextViewType: ViewType = .carRegister
        var carInfoModel: CarInfoModel?
        
        var isRegisterCarComplete: Bool?
    }
    
    struct RegisterCarParamModel: Codable {
        var memId: String = String(MemberManager.shared.mbId)
        var carOwner: String = ""
        var carNum: String = ""
        
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
    internal var paramModel = RegisterCarParamModel()
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .moveNextView:            
            return .just(.setMoveNextView(currentState.nextViewType.hasNextViewType()))
            
        case .registerCarInfo:
            return self.provider.postRegisterCar(model: paramModel)
                .convertData()
                .compactMap(convertToData)
                .map { carInfoModel in
                    return .setRegisterCarResult(carInfoModel)
                }
                
        case .setMoveNextView(let viewType):
            return .just(.setMoveNextView(viewType))
            
        case .setCarNumber(let carNumber):
            self.paramModel.carNum = carNumber
            return .empty()
            
        case .setCarOwnerName(let carOwnerName):
            self.paramModel.carOwner = carOwnerName
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.carInfoModel = nil
        newState.isRegisterCarComplete = nil
                                
        switch mutation {
        case .setMoveNextView(let viewType):
            newState.nextViewType = viewType
                   
        case .setRegisterCarResult(let carInfoModel):
            newState.carInfoModel = carInfoModel
            newState.isRegisterCarComplete = carInfoModel.carNum.isEmpty
                    
        }
        return newState
    }
    
    private func convertToData(with result: ApiResult<Data, ApiErrorMessage> ) -> CarInfoModel? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            let carInfoModel = CarInfoModel(jsonData)
            
            let code = carInfoModel.code
            
            switch code {
            case 200:
                return carInfoModel
                
            case 401:
                Observable.just(CarRegistrationReactor.Action.setMoveNextView(.carOwner))
                    .bind(to: self.action)
                    .disposed(by: self.disposeBag)
                
                Snackbar().show(message: "\(carInfoModel.msg)")
                return nil
                
            case 403:
                Observable.just(CarRegistrationReactor.Action.setMoveNextView(.carOwner))
                    .bind(to: self.action)
                    .disposed(by: self.disposeBag)
                
                let popupModel = PopupModel(title: "이미 등록된 차량이에요.",
                                            message: "중복 차량은 추가 등록할 수 없어요.",
                                            confirmBtnTitle: "다시 입력")

                let popup = ConfirmPopupViewController(model: popupModel)
                                            
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                })
                return nil
                
            case 405:
                Observable.just(CarRegistrationReactor.Action.setMoveNextView(.carOwner))
                    .bind(to: self.action)
                    .disposed(by: self.disposeBag)
                
                Snackbar().show(message: "\(carInfoModel.msg)")
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

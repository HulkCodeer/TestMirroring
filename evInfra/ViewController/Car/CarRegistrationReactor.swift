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
        case getTermsAgreeList
    }
    
    enum Mutation {
        case setMoveNextView(ViewType)
        case setPrivacyAgree(Bool)
        case none
    }
    
    struct State {
        var nextViewType: ViewType = .carRegister
        
        var carInfoModel: CarInfoModel?
        var isRegisterCarComplete: Bool?
        var isPrivacyAgree: Bool?
    }
    
    struct RegisterCarParamModel {
        var memId: String = String(MemberManager.shared.mbId)
        var carOwner: String = ""
        var carNum: String = ""
        
        var toParam: [String: Any] {
            [
                "memId": self.memId,
                "carOwner": self.carOwner,
                "carNum": self.carNum
            ]
        }
    }
    
    internal var initialState: State
    internal var paramModel = RegisterCarParamModel()
    internal var fromViewType: FromViewType = .signup
    internal var registerCarArray: [String] = []
    
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
                .retry(1)
                .convertData()
                .compactMap(convertToData)
                .map { [weak self] carInfoModel in
                    guard let self = self else { return .none }
                    let reactor = CarRegistrationCompleteReactor(model: carInfoModel)
                    reactor.fromViewType = self.fromViewType                    
                    let viewcon = CarRegistrationCompleteViewController()
                    viewcon.reactor = reactor
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                    
                    return .setMoveNextView(.none)
                }
                
        case .setMoveNextView(let viewType):
            return .just(.setMoveNextView(viewType))
            
        case .setCarNumber(let carNumber):
            self.paramModel.carNum = carNumber
            return .empty()
            
        case .setCarOwnerName(let carOwnerName):
            self.paramModel.carOwner = carOwnerName
            return .empty()
            
        case .getTermsAgreeList:
            return self.provider.postGetTermsAgreeList()                
                .convertData()
                .compactMap(convertToTermsAgreeListData)
                .map { isPrivacyAgree in
                    return .setPrivacyAgree(isPrivacyAgree)
                }
        
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.carInfoModel = nil
        newState.isRegisterCarComplete = nil
        newState.isPrivacyAgree = nil
                                
        switch mutation {
        case .setMoveNextView(let viewType):
            newState.nextViewType = viewType
            
        case .setPrivacyAgree(let isPrivacyAgree):
            newState.isPrivacyAgree = isPrivacyAgree
            
        case .none: break
                    
        }
        return newState
    }
    
    private func convertToData(with result: ApiResult<Data, ApiErrorMessage> ) -> CarInfoModel? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            let carInfoModel = CarInfoModel(jsonData["body"])
            let code = jsonData["code"].intValue
            
            let popupBtnText = fromViewType == .signup ? "건너뛰고 가입하기":"개인정보 관리로 이동"
                
            switch code {
            case 200:
                return carInfoModel
                
            case 401:
                Observable.just(CarRegistrationReactor.Action.setMoveNextView(.carOwner))
                    .bind(to: self.action)
                    .disposed(by: self.disposeBag)
                
                let popupModel = PopupModel(title: "해당하는 정보가 없어요.",
                                            message: "번호 : \(self.paramModel.carNum), 소유주 : \(self.paramModel.carOwner)\n입력하신 차량 번호, 소유주에 해당하는 차량이 조회되지 않아요. 다시 한번 정보를 확인해 본 뒤 등록해주세요.",
                                            confirmBtnTitle: "다시 입력")

                let popup = ConfirmPopupViewController(model: popupModel)
                                            
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                })
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
                
                let popupModel = PopupModel(title: "전기차만 등록할 수 있어요!",
                                            message: "아쉽지만, EV Infra는 전기차만 등록 가능해요. 다른 차량은 등록할 수 없어요.",
                                            confirmBtnTitle: "\(popupBtnText)")

                let popup = ConfirmPopupViewController(model: popupModel)
                                            
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                })
                return nil
                            
            default:
                Observable.just(CarRegistrationReactor.Action.setMoveNextView(.carOwner))
                    .bind(to: self.action)
                    .disposed(by: self.disposeBag)
                
                let popupModel = PopupModel(title: "차량 등록 서버 오류",
                                            message: "현재 차량 등록에 대한 정보 서버가 오류 났어요. 죄송하지만, 내일 중으로 다시 시도하면 잘 등록될거에요!",
                                            confirmBtnTitle: "\(popupBtnText)")

                let popup = ConfirmPopupViewController(model: popupModel)
                                            
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                })
                return nil
            }
                                                             
        case .failure(let errorMessage):            
            printLog(out: "Error Message : \(errorMessage)")
            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
            return nil
        }
    }
    
    private func convertToTermsAgreeListData(with result: ApiResult<Data, ApiErrorMessage> ) -> Bool? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            
            
            
            let termsAgreeList = TermsAgreeListModel(jsonData)
                                                    
            switch termsAgreeList.code {
            case 1000:
                return termsAgreeList.list.filter { "privacy_agree_v2".equals($0.termsId) && $0.agree }.count == 1
                
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

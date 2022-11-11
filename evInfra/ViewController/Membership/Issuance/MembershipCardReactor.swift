//
//  MembershipCardReactor.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/11/03.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class MembershipCardReactor: ViewModel, Reactor {
    enum Action {
        case membershipCardInfo
        case loadPaymentStatus
        case confirmDelivery
    }
    
    enum Mutation {
        case setMembershipCardInfo(MembershipCardInfo)
        case setIsConfirmDelivery(Bool)
        case empty
    }
    
    struct State {
        var membershipCardInfo: MembershipCardInfo?
        var isConfirmDelivery: Bool?
    }
    
    internal var initialState: State
            
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadPaymentStatus:
            return self.provider.postPaymentStatus()
                .convertData()
                .compactMap(convertValidFineUser)
                .compactMap { isPaymentFineUser in
                    return .empty
                }
            
        case .membershipCardInfo:
            return self.provider.postMembershipCardInfo()
                            .convertData()
                            .compactMap(convertToData)
                            .map { model in
                                return .setMembershipCardInfo(model)
                            }
            
        case .confirmDelivery:
            return self.provider.putMembershipCardDeliveryConfirm()
                            .convertData()
                            .compactMap(convertIsDeliveryConfirm)
                            .compactMap { isConfirm in
                                return .setIsConfirmDelivery(isConfirm)
                            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.membershipCardInfo = nil
        newState.isConfirmDelivery = nil
        
        switch mutation {
        case .setMembershipCardInfo(let model):
            newState.membershipCardInfo = model
            
        case .setIsConfirmDelivery(let isConfirmDelivery):
            newState.isConfirmDelivery = isConfirmDelivery
            
        case .empty: break
                                                    
        }
        return newState
    }
    
    private func convertToData(with result: ApiResult<Data, ApiError>) -> MembershipCardInfo? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            
            guard jsonData["code"] == 1000 else { return nil }
            
            let membershipCardInfo = MembershipCardInfo(jsonData["data"])
            
            return membershipCardInfo
                                                                         
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
            return nil
        }
    }
    
    private func convertValidFineUser(with result: ApiResult<Data, ApiError>) -> Bool? {
        switch result {
        case .success(let data):
            let json = JSON(data)
            printLog(out: "json data : \(json)")
                                    
            switch PaymentStatus(rawValue: json["pay_code"].intValue) {
            case .PAY_NO_CARD_USER, // 카드등록 아니된 멤버
                    .PAY_NO_VERIFY_USER, // 인증 되지 않은 멤버 *헤커 의심
                    .PAY_DELETE_FAIL_USER, // 비정상적인 삭제 멤버
                    .PAY_NO_USER :  // 유저체크
                
                let popupModel = PopupModel(title: "결제카드 오류 안내",
                                            message: "현재 고객님의 결제 카드에 오류가 발생했어요. 오류 발생 시 원활한 서비스 이용을 할 수 없으니 다른 카드로 변경해주세요.",
                                            confirmBtnTitle: "결제카드 변경하기",
                                            confirmBtnAction: {
                    let memberStoryboard = UIStoryboard(name : "Member", bundle: nil)
                    let myPayInfoVC = memberStoryboard.instantiateViewController(ofType: MyPayinfoViewController.self)
                    GlobalDefine.shared.mainNavi?.push(viewController: myPayInfoVC)
                })

                let popup = ConfirmPopupViewController(model: popupModel)
                                                                            
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                })
                
                return nil
                                    
            case .PAY_DEBTOR_USER: // 돈안낸 유저
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    let paymentVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(ofType: RepayListViewController.self)
                    GlobalDefine.shared.mainNavi?.push(viewController: paymentVC)
                })
                
                return nil
                                    
            default: return nil
            }
                                    
        case .failure(let errorMessage):
            printLog(out: "error: \(errorMessage)")
            Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            return nil
        }
    }
    
    private func convertIsDeliveryConfirm(with result: ApiResult<Data, ApiError>) -> Bool? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            
            guard jsonData["code"] == 1000 else {
                Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
                return nil
            }
            Snackbar().show(message: "EV Pay 카드 수령이 확정되었어요.")
            return true
                                                                         
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
            return nil
        }
    }
}

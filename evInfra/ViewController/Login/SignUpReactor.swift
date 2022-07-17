//
//  AcceptTermsReactor.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/13.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class SignUpReactor: ViewModel, Reactor {
    enum Action {
        case validFieldStepOne(String, String, String)
        case setGenderType(Login.Gender)
    }
    
    enum Mutation {
        case setValidNickName(Bool)
        case setValidEmail(Bool)
        case setValidPhone(Bool)
        case setGenderType(Login.Gender)
    }
    
    struct State {
        var isValidNickName: Bool?
        var isValidEmail: Bool?
        var isValidPhone: Bool?
        var signUpUserData: Login
        var genderType: Login.Gender?
    }
    
    internal var initialState: State    
    
    init(provider: SoftberryAPI, signUpUserData: Login) {
        self.initialState = State(signUpUserData: signUpUserData)
        super.init(provider: provider)
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .validFieldStepOne(let nickName, let email, let phone):
            return .concat([ .just(.setValidNickName(nickName.isEmpty)) ,
                             .just(.setValidEmail(StringUtils.isValidEmail(email))),
                             .just(.setValidPhone(StringUtils.isValidPhoneNum(phone)))
            ])
                  
        case .setGenderType(let genderType):
            return .just(.setGenderType(genderType))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
                
        newState.isValidNickName = nil
        newState.isValidEmail = nil
        newState.isValidPhone = nil
        newState.genderType = nil
        
        switch mutation {
        case .setValidNickName(let isValid):
            newState.isValidNickName = isValid
            
        case .setValidEmail(let isValid):
            newState.isValidEmail = isValid
        
        case .setValidPhone(let isValid):
            newState.isValidPhone = isValid
            
        case .setGenderType(let genderType):
            newState.genderType = genderType
                                                                                        
        }
        return newState
    }
    
    private func convertToData(with result: ApiResult<Data, ApiErrorMessage> ) -> Bool? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            
            let code = jsonData["code"].stringValue
            
            switch code {
            case "9000":
                LoginHelper.shared.logout(completion: { _ in
                    Snackbar().show(message: "회원 정보가 만료되어 로그아웃 되었습니다. 회원탈퇴를 위해서는 다시 로그인이 필요합니다.")
                    GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
                })
                
                return nil
                
            case "1000":
                return true
                
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
    
    private func convertToAppleData(with result: ApiResult<Data, ApiErrorMessage> ) -> Bool? {
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

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
    typealias UserInfoStepValidation = (isValidNickName: Bool, isValidEmail: Bool, isValidPhoneNo: Bool)
    
    enum Action {
        case validUserInfoStep
        case setGenderType(Login.Gender)
        case setNickname(String)
        case setEmail(String)
        case setPhone(String)
        case getSignUpUserData
    }
    
    enum Mutation {
        case setValidUserInfoStep(UserInfoStepValidation)
        case setGenderType(Login.Gender)
        case setNickname(String)
        case setEmail(String)
        case setPhone(String)
        case setSignUpUserData(Login)
    }
    
    struct State {
        var isValidUserInfo: UserInfoStepValidation?
        var genderType: Login.Gender?        
        var signUpUserData: Login
    }
    
    internal var initialState: State
    internal var signUpUserData: Login
    
    init(provider: SoftberryAPI, signUpUserData: Login) {
        self.initialState = State(signUpUserData: signUpUserData)
        self.signUpUserData = signUpUserData
        super.init(provider: provider)
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .validUserInfoStep:
            return .just(.setValidUserInfoStep((isValidNickName: !self.currentState.signUpUserData.name.isEmpty,
                                                isValidEmail: StringUtils.isValidEmail(self.currentState.signUpUserData.email),
                                                isValidPhoneNo: StringUtils.isValidPhoneNum(self.currentState.signUpUserData.phoneNo))))
                                          
        case .setGenderType(let genderType):
            return .just(.setGenderType(genderType))
            
        case .getSignUpUserData:
            return .just(.setSignUpUserData(self.signUpUserData))
            
        case .setNickname(let nickName):
            return .just(.setNickname(nickName))
            
        case .setEmail(let email):
            return .just(.setEmail(email))
            
        case .setPhone(let phone):            
            return .just(.setPhone(phone))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
                
        newState.isValidUserInfo = nil
        newState.genderType = nil
        
        switch mutation {
        case .setValidUserInfoStep(let validResult):
            newState.isValidUserInfo = validResult
                    
        case .setGenderType(let genderType):
            newState.genderType = genderType
            
        case .setSignUpUserData(let signUpUserData):
            newState.signUpUserData = signUpUserData
            
        case .setNickname(let nickName):
            newState.signUpUserData.name = nickName
            
        case .setEmail(let email):
            newState.signUpUserData.email = email
            
        case .setPhone(let phone):
            newState.signUpUserData.phoneNo = phone
            
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

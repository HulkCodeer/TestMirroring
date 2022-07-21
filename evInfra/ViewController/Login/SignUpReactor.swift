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
        case validUserMoreInfoStep
        case validUserInfoStep
        case setGenderType(Login.Gender)
        case setNickname(String)
        case setEmail(String)
        case setPhone(String)
        case setGender(String)
        case setAge(String)
        case getSignUpUserData
        case signUp
    }
    
    enum Mutation {
        case setValidUserMoreInfoStep(Bool)
        case setValidUserInfoStep(UserInfoStepValidation)
        case setGenderType(Login.Gender)
        case setNickname(String)
        case setEmail(String)
        case setPhone(String)
        case setGender(String)
        case setAge(String)
        case setSignUpUserData(Login)
        case none
    }
    
    struct State {
        var isValidUserInfo: UserInfoStepValidation?
        var isValidUserInforMore: Bool?
        var genderType: Login.Gender?
        var isSignUpComplete: Bool?
        
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
        case .validUserMoreInfoStep:
            return .just(.setValidUserMoreInfoStep(!self.currentState.signUpUserData.gender.isEmpty))
            
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
            
        case .setGender(let gender):
            return .just(.setGender(gender))
            
        case .setAge(let age):
            return .just(.setAge(age))
            
        case .signUp:                        
            return self.provider.signUp(user: self.currentState.signUpUserData)
                .convertData()
                .compactMap(convertToData)
                .map { jsonData in
                    let mbId = jsonData["mb_id"].stringValue
                    guard !mbId.isEmpty else {
                        Snackbar().show(message: "서비스 연결상태가 좋지 않습니다.\n잠시 후 다시 시도해 주세요.")
                        return .none
                    }
                        
                    let reactor = CarRegistrationReactor(provider: RestApi())
                    let viewcon = CarRegistrationViewController()
                    viewcon.reactor = reactor
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon)                    
                    MemberManager.shared.setData(data: jsonData)
                                        
                    return .none
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
                
        newState.isValidUserInfo = nil
        newState.isValidUserInforMore = nil
        newState.genderType = nil
                        
        switch mutation {
        case .setValidUserMoreInfoStep(let isValid):
            newState.isValidUserInforMore = isValid
            
        case .setValidUserInfoStep(let isValid):
            newState.isValidUserInfo = isValid
                    
        case .setGenderType(let genderType):
            newState.genderType = genderType
            newState.signUpUserData.gender = genderType.value
            newState.signUpUserData.displayGender = genderType.value
            
        case .setSignUpUserData(let signUpUserData):
            newState.signUpUserData = signUpUserData
            
        case .setNickname(let nickName):
            newState.signUpUserData.name = nickName
            
        case .setEmail(let email):
            newState.signUpUserData.email = email
            
        case .setPhone(let phone):
            newState.signUpUserData.phoneNo = phone
            
        case .setGender(let gender):
            newState.signUpUserData.gender = gender
            newState.signUpUserData.displayGender = gender
            
        case .setAge(let age):
            newState.signUpUserData.ageRange = age
            newState.signUpUserData.displayAgeRang = age
            
        case .none: break
        }
        return newState
    }
    
    private func convertToData(with result: ApiResult<Data, ApiErrorMessage> ) -> JSON? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            return jsonData
            
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
            return nil
        }
    }
}

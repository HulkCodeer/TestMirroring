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
        case updateTerms(String)
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
        case setSignUpUserData
        case setSignUpComplete(String)
        case none
    }
    
    struct State {
        var isValidUserInfo: UserInfoStepValidation?
        var isValidUserInforMore: Bool?
        var genderType: Login.Gender?
        var isSignUpComplete: String?        
        
        var signUpUserData: Login
    }
    
    struct UpdateTermsInfoParamModel: Encodable {
        var mbId: Int = MemberManager.shared.mbId
        var list: [TermsInfo] = [TermsInfo].init(repeating: TermsInfo(termsId: "", agree: false), count: 8)
        
        enum CodingKeys: String, CodingKey {
            case mbId = "mb_id"
            case list
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.mbId, forKey: .mbId)
            try container.encode(self.list, forKey: .list)
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
    internal var terms: UpdateTermsInfoParamModel = UpdateTermsInfoParamModel()
    
    init(provider: SoftberryAPI, signUpUserData: Login) {
        self.initialState = State(signUpUserData: signUpUserData)
        super.init(provider: provider)
    }
    
    override init(provider: SoftberryAPI) {
        self.initialState = State(signUpUserData: Login(.none))
        super.init(provider: provider)
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .validUserMoreInfoStep:
            return .just(.setValidUserMoreInfoStep(!self.currentState.signUpUserData.gender.isEmpty))
            
        case .validUserInfoStep:
            return .just(.setValidUserInfoStep((isValidNickName: !self.currentState.signUpUserData.name.isEmpty,
                                                isValidEmail: StringUtils.isValidEmail(self.currentState.signUpUserData.email),
                                                isValidPhoneNo: StringUtils.isValidPhoneNum(self.currentState.signUpUserData.displayPhoneNumber))))
                                          
        case .setGenderType(let genderType):
            return .just(.setGenderType(genderType))
            
        case .getSignUpUserData:
            return .just(.setSignUpUserData)
            
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
            return self.provider.postSignUp(user: self.currentState.signUpUserData)
                .convertData()
                .compactMap(convertToData)
                .map { jsonData in
                    let mbId = jsonData["mb_id"].stringValue
                    guard !mbId.isEmpty else {
                        Snackbar().show(message: "서비스 연결상태가 좋지 않습니다.\n잠시 후 다시 시도해 주세요.")
                        return .none
                    }
                                        
                    if let _profileImgURL = self.currentState.signUpUserData.profile_image_url {
                        // 카카오 프로파일 이미지 다운로드                        
                        DispatchQueue.global(qos: .background).async {
                            Server.getData(url: _profileImgURL) { (isSuccess, responseData) in
                                if isSuccess {
                                    if let data = responseData {
                                        Server.uploadImage(data: data, filename: self.currentState.signUpUserData.profile_image, kind: Const.CONTENTS_THUMBNAIL, targetId: "\(MemberManager.shared.mbId)", completion: { (isSuccess, value) in
                                            let json = JSON(value)
                                            if !isSuccess {
                                                printLog(out: "upload image Error : \(json)")
                                            }
                                        })
                                    }
                                }
                            }
                        }
                    }
                    
                    MemberManager.shared.setData(data: jsonData)
                    return .setSignUpComplete(mbId)
                }
            
        case .updateTerms(let mbId):
            self.terms.mbId = Int(mbId) ?? 0
            return self.provider.postTermsInfo(terms: self.terms)
                .convertData()
                .compactMap(convertToData)
                .map { jsonData in
                    
                    let reactor = CarRegistrationReactor(provider: RestApi())
                    reactor.fromViewType = .signup
                    let viewcon = CarRegistrationViewController()
                    viewcon.reactor = reactor
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                                        
                    return .none
                }
            
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
                
        newState.isValidUserInfo = nil
        newState.isValidUserInforMore = nil
        newState.genderType = nil
        newState.isSignUpComplete = nil
                        
        switch mutation {
        case .setValidUserMoreInfoStep(let isValid):
            newState.isValidUserInforMore = isValid
            
        case .setValidUserInfoStep(let isValid):
            newState.isValidUserInfo = isValid
                    
        case .setGenderType(let genderType):
            newState.genderType = genderType
            newState.signUpUserData.gender = genderType.value
            newState.signUpUserData.displayGender = genderType.value
            
        case .setSignUpUserData:
            newState.signUpUserData = initialState.signUpUserData
            
        case .setNickname(let nickName):
            newState.signUpUserData.name = nickName
            
        case .setEmail(let email):
            newState.signUpUserData.email = email
            
        case .setPhone(let phone):
            newState.signUpUserData.phoneNo = phone
            newState.signUpUserData.displayPhoneNumber = phone
            
        case .setGender(let gender):
            newState.signUpUserData.gender = gender
            newState.signUpUserData.displayGender = gender
            
        case .setAge(let age):
            newState.signUpUserData.ageRange = age
            newState.signUpUserData.displayAgeRang = age
            
        case .setSignUpComplete(let isSignUpComplete):
            newState.isSignUpComplete = isSignUpComplete
            
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

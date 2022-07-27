//
//  ModifyMyPageReactor.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/27.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON
import UIKit

internal final class ModifyMyPageReactor: ViewModel, Reactor {
    typealias CheckChangeMemberInfo = (nickname: Bool, gender: Bool, ageRange: Bool)
    
    enum Action {
        case updateMemberInfo
        case setGenderType(Login.Gender)
        case setNickname(String)
        case setGender(String)
        case setAge(String)
        case setProfileImg(Data)        
    }
    
    enum Mutation {
        case setGenderType(Login.Gender)
        case setNickname(String)
        case setGender(String)
        case setAge(String)
        case setCheckChangeMemberInfo(CheckChangeMemberInfo)
        case none
    }
    
    struct State {
        var genderType: Login.Gender?
        var isModify: CheckChangeMemberInfo?
        
        var checkChangeMemberInfo: CheckChangeMemberInfo = (false, false, false)        
        var memberInfo: UpdateMemberInfoParamModel = UpdateMemberInfoParamModel()
    }
    
    struct UpdateMemberInfoParamModel: Encodable {
        var memId: Int = MemberManager.shared.mbId
        var nickname: String = MemberManager.shared.memberNickName
        var ageRange: String = MemberManager.shared.ageRange
        var gender: String = MemberManager.shared.gender
        var profileName: String = MemberManager.shared.profileImage
        
        enum CodingKeys: String, CodingKey {
            case memId = "mb_id"
            case nickname
            case ageRange = "age_range"
            case gender
            case profileName = "profile"
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.memId, forKey: .memId)
            try container.encode(self.nickname, forKey: .nickname)
            try container.encode(self.ageRange, forKey: .ageRange)
            try container.encode(self.gender, forKey: .gender)
            try container.encode(self.profileName, forKey: .profileName)
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
    private var profileImgData: Data = Data()
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateMemberInfo:
            return self.provider.postUpdateMemberInfo(model: currentState.memberInfo)
                .convertData()
                .compactMap(convertToData)
                .map { [weak self] reasonList in
                    guard let self = self else { return .none}
                    MemberManager.shared.memberNickName = self.currentState.memberInfo.nickname
                    MemberManager.shared.gender = self.currentState.memberInfo.gender
                    MemberManager.shared.ageRange = self.currentState.memberInfo.ageRange
                    
                    Snackbar().show(message: "수정사항이 저장되었습니다.")
                    
                    DispatchQueue.global(qos: .background).async { [weak self] in
                        guard let self = self else { return }
                        
                        let memberId = MemberManager.shared.memberId
                        let curTime = Int64(NSDate().timeIntervalSince1970 * 1000)
                        let profileName = memberId + "_" + "\(curTime).jpg"
                        
                        Server.uploadImage(data: self.profileImgData, filename: profileName, kind: Const.CONTENTS_THUMBNAIL, targetId: "\(MemberManager.shared.mbId)", completion: { (isSuccess, value) in
                            let json = JSON(value)
                            if isSuccess {
                                MemberManager.shared.profileImage = profileName
                            }
                        })
                    }
                    
                    GlobalDefine.shared.mainNavi?.pop()
                    
                    return .none
                }
            
        case .setGenderType(let genderType):
            return .just(.setGenderType(genderType))
                                
        case .setNickname(let nickName):
            return .concat([.just(.setNickname(nickName)),
                            .just(.setCheckChangeMemberInfo((nickname: initialState.memberInfo.nickname == nickName,
                                                             gender: currentState.checkChangeMemberInfo.gender,
                                                             ageRange: currentState.checkChangeMemberInfo.ageRange)))])
                                
        case .setGender(let gender):
            return .just(.setGender(gender))
            
        case .setAge(let age):
            return .just(.setAge(age))
            
        case .setProfileImg(let profileImgData):
            self.profileImgData = profileImgData
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
                                
        newState.genderType = nil
        newState.isModify = nil
                        
        switch mutation {
        case .setGenderType(let genderType):
            newState.genderType = genderType
            
        case .setNickname(let nickName):
            newState.memberInfo.nickname = nickName
                                
        case .setGender(let gender):
            newState.memberInfo.gender = gender
            
        case .setAge(let age):
            newState.memberInfo.ageRange = age
            
        case .setCheckChangeMemberInfo(let isModify):
            newState.isModify = isModify
                                
        case .none: break
        
        }
        return newState
    }
    
    private func convertToData(with result: ApiResult<Data, ApiErrorMessage> ) -> Bool? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            
            switch jsonData["code"].intValue {
            case 1000: return true
            default: return false
            }
            
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
            return nil
        }
    }
}

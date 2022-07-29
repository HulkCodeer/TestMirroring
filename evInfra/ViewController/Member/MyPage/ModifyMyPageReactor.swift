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
    enum Action {
        case updateMemberInfo
        case setGenderType(Login.Gender)
        case setNickname(String)
        case setGender(String)
        case setAge(String)
        case setProfileImgData(Data)
        case setProfileImg(UIImage)
    }
    
    enum Mutation {
        case setGenderType(Login.Gender)
        case setNickname(String)
        case setGender(String)
        case setAge(String)
        case setCheckChangeMemberInfo(Bool)
        case setProfileName(String)
        case setProfileImgData(Data)
        case setProfileImg(UIImage)
        case none
    }
    
    struct State {
        var genderType: Login.Gender?
        var isModify: Bool?
        var profileImgData: Data?
        var profileImg: UIImage?
        
        var memberInfo: UpdateMemberInfoParamModel = UpdateMemberInfoParamModel()
    }
    
    struct UpdateMemberInfoParamModel {
        var mbId: Int = MemberManager.shared.mbId
        var nickname: String = MemberManager.shared.memberNickName
        var ageRange: String = MemberManager.shared.ageRange
        var gender: String = MemberManager.shared.gender
        var profileName: String = MemberManager.shared.profileImage
        
        internal func toDict() -> [String: Any] {
            var dict = [String: Any]()
            dict["mb_id"] = self.mbId
            dict["nickname"] = self.nickname
            dict["age_range"] = self.ageRange
            dict["gender"] = self.gender
            dict["profile"] = self.profileName
            return dict
        }
    }
            
    internal var initialState: State
    
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
                        printLog(out: "\(self.currentState.memberInfo.profileName)")
                        Server.uploadImage(data: self.currentState.profileImgData ?? Data(), filename: self.currentState.memberInfo.profileName, kind: Const.CONTENTS_THUMBNAIL, targetId: "\(MemberManager.shared.mbId)", completion: { (isSuccess, value) in
                            printLog(out: "PARK TEST : \(JSON(value))")
                            if isSuccess {
                                MemberManager.shared.profileImage = self.currentState.memberInfo.profileName
                            }
                        })
                    }
                    
                    GlobalDefine.shared.mainNavi?.pop()
                    
                    return .none
                }
            
        case .setGenderType(let genderType):
            return .concat([.just(.setGenderType(genderType)),
                            .just(.setCheckChangeMemberInfo(true))])
                                
        case .setNickname(let nickName):
            return .concat([.just(.setNickname(nickName)),
                            .just(.setCheckChangeMemberInfo(true))])
                                
        case .setGender(let gender):
            return .just(.setGender(gender))
            
        case .setAge(let age):
            return .concat([.just(.setAge(age)),
                            .just(.setCheckChangeMemberInfo(true))])
            
        case .setProfileImgData(let profileImgData):
            let memberId = MemberManager.shared.memberId
            let curTime = Int64(NSDate().timeIntervalSince1970 * 1000)
            let profileName = memberId + "_" + "\(curTime).jpg"
            return .concat([.just(.setProfileImgData(profileImgData)),
                            .just(.setProfileName(profileName)),
                            .just(.setCheckChangeMemberInfo(true))])
            
        case .setProfileImg(let profileImg):
            return .just(.setProfileImg(profileImg))
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
            
        case .setProfileName(let profileName):
            newState.memberInfo.profileName = profileName
            
        case .setProfileImg(let profileImg):
            newState.profileImg = profileImg
            
        case .setProfileImgData(let profileImgData):
            newState.profileImgData = profileImgData
                                
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

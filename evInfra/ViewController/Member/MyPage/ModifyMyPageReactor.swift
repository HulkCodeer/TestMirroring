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
        case setProfileImgData(Data, UIImage)
    }
    
    enum Mutation {
        case setGenderType(Login.Gender)
        case setNickname(String)
        case setGender(String)
        case setAge(String)
        case setCheckChangeMemberInfo(Bool)
        case setProfileName(String)
        case setProfileImgData(Data, UIImage)
        case setChangeMyPageInfo(UpdateMemberInfoParamModel)
        case none
    }
    
    struct State {
        var myPageInfo: UpdateMemberInfoParamModel?
        
        var isModify: Bool = false
        var memberInfo: UpdateMemberInfoParamModel = UpdateMemberInfoParamModel()
    }
    
    struct UpdateMemberInfoParamModel {
        var mbId: Int = MemberManager.shared.mbId
        var nickname: String = MemberManager.shared.memberNickName
        var ageRange: String = MemberManager.shared.ageRange
        var gender: String = MemberManager.shared.gender
        var profileName: String = MemberManager.shared.profileImage
        var profileImgData: Data?
        var profileImg: UIImage?
        
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
                        guard let self = self, let _profileImgData = self.currentState.memberInfo.profileImgData else { return }
                        Server.uploadImage(data: _profileImgData, filename: self.currentState.memberInfo.profileName, kind: Const.CONTENTS_THUMBNAIL, targetId: "\(MemberManager.shared.mbId)", completion: { (isSuccess, value) in
                            if isSuccess {
                                MemberManager.shared.profileImage = self.currentState.memberInfo.profileName
                            }
                        })
                    }
                                                            
                    GlobalDefine.shared.mainNavi?.pop()
                    
                    return .setChangeMyPageInfo(self.currentState.memberInfo)
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
            
        case .setProfileImgData(let profileImgData, let profileImg):
            let memberId = MemberManager.shared.memberId
            let curTime = Int64(NSDate().timeIntervalSince1970 * 1000)
            let profileName = memberId + "_" + "\(curTime).jpg"
            return .concat([.just(.setProfileImgData(profileImgData, profileImg)),
                            .just(.setProfileName(profileName)),
                            .just(.setCheckChangeMemberInfo(true))])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
                                        
        switch mutation {
        case .setGenderType(let genderType):
            newState.memberInfo.gender = genderType.value
            
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
                                
        case .setProfileImgData(let profileImgData, let profileImg):
            newState.memberInfo.profileImgData = profileImgData
            newState.memberInfo.profileImg = profileImg
                                
        case .setChangeMyPageInfo(let myPageInfo):
            newState.myPageInfo = myPageInfo
            
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

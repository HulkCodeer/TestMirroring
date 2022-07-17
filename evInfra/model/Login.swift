//
//  Login.swift
//  evInfra
//
//  Created by Shin Park on 2020/09/01.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import AuthenticationServices // apple login

struct Login {

    enum LoginType: String {
        case apple
        case kakao
        case evinfra
        case none
        
        internal var value: String {
            switch self {
            case .apple:
                return "애플"
                
            case .kakao:
                return "카카오"
                
            default: return ""
            }
        }
    }
    
    enum AgeType: CaseIterable {
        case twenty
        case thirty
        case forty
        case fiftyOver
        case none
        
        init(value: String) {
            switch value {
            case "20대": self = .twenty
            case "30대": self = .thirty
            case "40대": self = .forty
            case "50대 이상": self = .fiftyOver
            case "선택안함": self = .none
            default: self = .none
            }
        }
        
        internal var value: String {
            switch self {
            case .twenty: return "20대"
            case .thirty: return "30대"
            case .forty: return "40대"
            case .fiftyOver: return "50대 이상"
            case .none: return "선택안함"
            }
        }
    }
    
    enum Gender: String, CaseIterable {
        case man = "남성"
        case women = "여성"
        case etc = "기타"
        
        init(value: String) {
            switch value {
            case "남성": self = .man
            case "여성": self = .women
            case "기타": self = .etc
            default: self = .man
            }
        }
        
        internal var value: String {
            switch self {
            case .man: return "남성"
            case .women: return "여성"
            case .etc: return "기타"
            }
        }
    }
    
    var loginType: LoginType
    
    var userId: String = ""
    var name: String = ""
    var email: String = ""
    var emailVerified = false
    var profile_image: String?
    
    var gender: String = "남성"
    var displayGender: String = ""
    var ageRange: String = "20대"
    var displayAgeRang: String = ""
    var phoneNo: String = ""
    var displayPhoneNumber: String = ""
    
    var otherInfo: MemberOtherInfo?
    var appleAuthorizationCode: Data?
    
    init(_ type: LoginType) {
        self.loginType = type
    }
    
    @available(iOS 13.0, *)
    init(appleUserData:  ASAuthorizationAppleIDCredential) {
        self.loginType = .apple
        self.userId = appleUserData.user
        self.name = appleUserData.fullName?.givenName ?? ""
        self.email = appleUserData.email ?? ""
        self.emailVerified = true
        self.appleAuthorizationCode = appleUserData.authorizationCode
    }
    
    
    init(kakaoUserData: KOUserMe) {
        self.loginType = .kakao
        self.userId = kakaoUserData.id ?? ""
        self.name = kakaoUserData.nickname ?? ""
        
        if let userAccount = kakaoUserData.account {
            self.email = userAccount.email ?? ""
            self.emailVerified = (userAccount.isEmailVerified == KOOptionalBoolean.true)
            
            // 추가 정보
            if userAccount.hasPhoneNumber == KOOptionalBoolean.true {
                self.phoneNo = userAccount.phoneNumber ?? ""
                if !self.phoneNo.isEmpty, self.phoneNo.starts(with: "+82") {
                    self.displayPhoneNumber = self.phoneNo.replaceAll(of: "^[^1]*1", with: "01")
                }
            }
            
            if userAccount.hasAgeRange == KOOptionalBoolean.true {
                self.ageRange = getRange(ageRange: userAccount.ageRange)
                self.displayAgeRang = AgeType(value: self.ageRange).value
            }
            
            if userAccount.hasGender == KOOptionalBoolean.true {
                self.gender = getGender(gender: userAccount.gender)
                self.displayGender = Gender(value: self.gender).value
            }
            
            self.otherInfo = MemberOtherInfo(me: kakaoUserData)
        }
    }
    
    internal func convertToParams() -> Parameters {
        var reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "user_id": userId,
            "nickname": name,
            "profile": profile_image ?? "",
            "login_type": loginType.rawValue,
            "email": email,
            "email_cert": emailVerified,
            "phone_no": phoneNo,
            "age_range": ageRange,
            "gender": gender,
        ]
        if let other = otherInfo {
            reqParam["other"] = other.toDictionary()
        }
        return reqParam
    }
    
    
        
    private func getGender(gender: KOUserGender) -> String {
        switch gender {
        case KOUserGender.null:
            return "기타"
        case KOUserGender.male:
            return "남성"
        case KOUserGender.female:
            return "여성"
        default:
            return "기타"
        }
    }
    
    private func getRange(ageRange: KOUserAgeRange) -> String {
        switch ageRange {
        case KOUserAgeRange.null:
            return "선택안함"
        case KOUserAgeRange.type15:
            return "10대"
        case KOUserAgeRange.type20:
            return "20대"
        case KOUserAgeRange.type30:
            return "30대"
        case KOUserAgeRange.type40:
            return "40대"
        case KOUserAgeRange.type50:
            return "50대 이상"
        case KOUserAgeRange.type60:
            return "50대 이상"
        case KOUserAgeRange.type70:
            return "50대 이상"
        case KOUserAgeRange.type80:
            return "50대 이상"
        case KOUserAgeRange.type90:
            return "50대 이상"
        default:
            return "선택안함"
        }
    }
    
}

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
    
    var loginType: LoginType
    
    var userId: String?
    var name: String?
    var email: String?
    var emailVerified = false
    var profile_image: String?
    
    var gender: String?
    var ageRange: String?
    var phoneNo: String?
    
    var otherInfo: MemberOtherInfo?
    var appleAuthorizationCode: Data?
    
    init(_ type: LoginType) {
        self.loginType = type
    }
    
    @available(iOS 13.0, *)
    static func apple(_ user: ASAuthorizationAppleIDCredential) -> Login {
        var login = Login(.apple)
        login.userId = user.user
        login.name = user.fullName?.givenName
        login.email = user.email                
        login.emailVerified = true
        login.appleAuthorizationCode = user.authorizationCode

        return login
    }
    
    static func kakao(_ user: KOUserMe) -> Login {
        var login = Login(.kakao)
        
        login.userId = user.id
        login.name = user.nickname
        
        if let userAccount = user.account {
            login.email = userAccount.email ?? ""
            login.emailVerified = (userAccount.isEmailVerified == KOOptionalBoolean.true)
            
            // 추가 정보
            if userAccount.hasPhoneNumber == KOOptionalBoolean.true {
                login.phoneNo = userAccount.phoneNumber
            }
            
            if userAccount.hasAgeRange == KOOptionalBoolean.true {
                login.ageRange = getRange(ageRange: userAccount.ageRange)
            }
            
            if userAccount.hasGender == KOOptionalBoolean.true {
                login.gender = getGender(gender: userAccount.gender)
            }
            
            login.otherInfo = MemberOtherInfo(me:user)
        }

        return login
    }
    
    public func convertToParams() -> Parameters {
        var reqParam: Parameters = [
            "member_id": MemberManager.shared.memberId,
            "user_id": userId ?? "",
            "nickname": name ?? "",
            "profile": profile_image ?? "",
            "login_type": loginType.rawValue,
            "email": email ?? "",
            "email_cert": emailVerified,
            "phone_no": phoneNo ?? "",
            "age_range": ageRange ?? "",
            "gender": gender ?? "",
        ]
        if let other = otherInfo {
            reqParam["other"] = other.toDictionary()
        }
        return reqParam
    }
    
    static func getKOGender(gender: KOUserGender) -> String {
        switch gender {
        case KOUserGender.null:
            return "other"
        case KOUserGender.male:
            return "male"
        case KOUserGender.female:
            return "female"
        default:
            return "other"
        }
    }
    
    
    static func getKORange(ageRange: KOUserAgeRange) -> String {
        switch ageRange {
        case KOUserAgeRange.null:
            return "N/A"
        case KOUserAgeRange.type15:
            return "15~19"
        case KOUserAgeRange.type20:
            return "20~29"
        case KOUserAgeRange.type30:
            return "30~39"
        case KOUserAgeRange.type40:
            return "40~49"
        case KOUserAgeRange.type50:
            return "50~59"
        case KOUserAgeRange.type60:
            return "60~69"
        case KOUserAgeRange.type70:
            return "70~79"
        case KOUserAgeRange.type80:
            return "80~89"
        case KOUserAgeRange.type90:
            return "90~"
        default:
            return "N/A"
        }
    }
    
    static func getGender(gender: KOUserGender) -> String {
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
    
    static func getRange(ageRange: KOUserAgeRange) -> String {
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

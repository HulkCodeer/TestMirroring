//
//  Login.swift
//  evInfra
//
//  Created by Shin Park on 2020/09/01.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
import AuthenticationServices // apple login

struct Login {

    enum LoginType: String {
        case apple
        case kakao
    }
    
    var type: LoginType
    
    var userId: String?
    var name: String?
    var email: String?
    var emailVerified = false
    var profileURL: URL?
    
    var gender: String?
    var ageRange: String?
    var phoneNo: String?
    
    init(_ type: LoginType) {
        self.type = type
    }
    
    @available(iOS 13.0, *)
    static func apple(_ user: ASAuthorizationAppleIDCredential) -> Login {
        var login = Login(.apple)
        
        login.userId = user.user
        login.name = user.fullName?.givenName
        login.email = user.email
        login.emailVerified = true

        return login
    }
    
    static func kakao(_ user: KOUserMe) -> Login {
        var login = Login(.kakao)
        
        login.userId = user.id
        login.name = user.nickname
        login.profileURL = user.profileImageURL
        
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
        }

        return login
    }
    
    static func getGender(gender: KOUserGender) -> String {
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
    
    static func getRange(ageRange: KOUserAgeRange) -> String {
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
}

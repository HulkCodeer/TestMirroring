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
        login.email = user.account?.email ?? ""
        login.emailVerified = (user.account?.isEmailVerified == KOOptionalBoolean.true)
        login.profileURL = user.profileImageURL
        
        return login
    }
}

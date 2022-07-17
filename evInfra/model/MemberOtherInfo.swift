//
//  MemberOtherInfo.swift
//  evInfra
//
//  Created by SH on 2022/01/11.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

struct MemberOtherInfo: Codable {
    var mType: String = "kakao"
    
    var user_id: String = ""
    var nickname: String = ""
    var profile_image: URL?
    var has_email: Bool = false
    var email_needs_agreement: Bool = false
    var is_email_verified: Bool = false
    var email: String = ""
    var has_phone_number: Bool = false
    var phone_number_needs_agreement: Bool = false
    var phone_number: String = ""
    var has_age_range: Bool = false
    var age_range_needs_agreement: Bool = false
    var age_range: String = ""
    var has_birthday: Bool = false
    var birthday_needs_agreement: Bool = false
    var birthday: String = ""
    var has_gender: Bool = false
    var gender: String = ""

    init(me: KOUserMe){
        mType = "kakao"
        
        user_id = me.id!
        nickname = me.nickname ?? ""
        if let profile = me.profileImageURL {
            profile_image = profile
        }
        
        if let userAccount = me.account {
            has_email = userAccount.hasEmail == KOOptionalBoolean.true ? true : false
            email_needs_agreement = userAccount.needsScopeAccountEmail()
            is_email_verified = userAccount.isEmailVerified == KOOptionalBoolean.true ? true : false
            email = userAccount.email ?? ""
            
            has_phone_number = userAccount.hasPhoneNumber == KOOptionalBoolean.true ? true : false
            phone_number_needs_agreement = userAccount.needsScopePhoneNumber()
            phone_number = userAccount.phoneNumber ?? ""
            
            has_age_range = userAccount.hasGender == KOOptionalBoolean.true ? true : false
            age_range_needs_agreement = userAccount.needsScopeAgeRange()
            age_range = self.getKORange(ageRange: userAccount.ageRange)
            
            has_gender = userAccount.hasGender == KOOptionalBoolean.true ? true : false
            gender = self.getKOGender(gender: userAccount.gender)
        }
    }
    
    private func getKORange(ageRange: KOUserAgeRange) -> String {
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
    
    private func getKOGender(gender: KOUserGender) -> String {
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
    
    func toDictionary() -> [String:Any] {
        var profile_path = ""
        if let profile = profile_image {
            profile_path = "\(profile)"
        }
        let dict = [
            "user_id": user_id as Any,
            "nickname": nickname as Any,
            "profile_image": profile_path as Any,
            "has_email": has_email as Any,
            "email_needs_agreement": email_needs_agreement as Any,
            "is_email_verified": is_email_verified as Any,
            "email": email as Any,
            "has_phone_number": has_phone_number as Any,
            "phone_number_needs_agreement": phone_number_needs_agreement as Any,
            "phone_number": phone_number as Any,
            "has_age_range": has_age_range as Any,
            "age_range_needs_agreement": age_range_needs_agreement as Any,
            "age_range": age_range as Any,
            "has_birthday": has_birthday as Any,
            "birthday_needs_agreement": birthday_needs_agreement as Any,
            "birthday": birthday as Any,
            "has_gender": has_gender as Any,
            "gender": gender as Any
        ]
        return dict
    }
}

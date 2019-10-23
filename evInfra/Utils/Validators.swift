//
//  Validators.swift
//  evInfra
//
//  Created by bulacode on 17/10/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

class ValidationError: Error {
    var message: String
    
    init(_ message: String) {
        self.message = message
    }
}

protocol ValidatorConvertible {
    func validated(_ value: String) throws -> String
}

enum ValidatorType {
    case membername
    case password
    case repassword(password: String)
    case phonenumber
    case carnumber
    case zipcode
    case address
}

enum VaildatorFactory {
    static func validatorFor(type: ValidatorType) -> ValidatorConvertible {
        switch type {
            case .membername: return MemberNameValidator()
            case .password: return PasswordValidator()
            case .repassword(let password): return RePasswordValidator(password)
            case .phonenumber: return PhoneNoValidator()
            case .carnumber: return CarNoValidator()
            case .zipcode: return ZipCodeValidator()
            case .address: return AddressValidator()
        }
    }
}


class MemberNameValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value.count > 0 else {throw ValidationError("본인 이름을 입력해 주세요.")}
        return value
    }
}

class PasswordValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {throw ValidationError("비밀번호를 입력해주세요.")}
        guard value.count == 4 else {throw ValidationError("비밀번호는 4자를 입력해주세요.")}
        do {
            if try NSRegularExpression(pattern: "^[0-9]*$",  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("비밀번호는 숫자만 사용해 주세요1.")
            }
        } catch {
            throw ValidationError("비밀번호는 숫자만 사용해 주세요.")
        }
        return value
    }
}

class RePasswordValidator: ValidatorConvertible {
    private let password: String
    
    init(_ pwd: String) {
        password = pwd
    }
    
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {throw ValidationError("비밀번호확인을 입력해주세요.")}
        guard value.elementsEqual(password) else {
            throw ValidationError("비밀번호와 확인번호가 일치하지 않습니다.")
        }
        return value
    }
}

class PhoneNoValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        let regex = "^01([0|1|6|7|8|9]?)-?([0-9]{3,4})-?([0-9]{4})$"
        guard !value.isEmpty else {throw ValidationError("전화번호를 입력해주세요.")}
        do {
            if try NSRegularExpression(pattern: regex,  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("전화번호 형식이 올바르지 않습니다.")
            }
        } catch {
            throw ValidationError("전화번호 형식이 올바르지 않습니다.")
        }
        return value
    }
}

class CarNoValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        let region = "[서울|부산|대구|인천|대전|광주|울산|제주|경기|강원|충남|전남|전북|경남|경북|세종]";
        let symbol = "[가|나|다|라|마|거|너|더|러|머|버|서|어|저|고|노|도|로|모|보|소|오|조|구|누|두|루|무|부|수|우|주|바|사|아|자|허|배|호|하|임\\x20]";
        var regex = "^\\d{2}" + symbol + "[\\s]?\\d{4}/*$"
        guard !value.isEmpty else {throw ValidationError("차량번호를 입력해주세요.")}
        do {
            if try NSRegularExpression(pattern: regex,  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                regex = "^\\d{3}" + symbol + "[\\s]?\\d{4}/*$";
                if try NSRegularExpression(pattern: regex,  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                    regex = "^" + region + "{2}[\\s]?\\d{2}[\\s]?" + symbol + "[\\s]?\\d{4}$";
                    if try NSRegularExpression(pattern: regex,  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                        throw ValidationError("차량번호 형식이 잘못되었습니다.")
                    }
                }
            }
        } catch {
            throw ValidationError("차량번호 형식이 잘못되었습니다.")
        }
        
        return value
    }
}

struct ZipCodeValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {throw ValidationError("우편번호를 검색해 주세요.")}
        return value
    }
}

struct AddressValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {throw ValidationError("상세주소를 입력해 주세요.")}
        return value
    }
}

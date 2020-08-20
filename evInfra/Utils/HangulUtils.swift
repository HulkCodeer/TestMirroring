//
//  HangulUtil.swift
//  evInfra
//
//  Created by Michael Lee on 2020/06/09.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
extension CharacterSet{
    static var modernHangul: CharacterSet{
        return CharacterSet(charactersIn: ("가".unicodeScalars.first!)...("힣".unicodeScalars.first!))
    }
}

public class HangulUtils {
    
    // UTF-8 기준
    static let INDEX_HANGUL_START:UInt32 = 44032  // "가"
    static let INDEX_HANGUL_END:UInt32 = 55199    // "힣"
    
    static let CYCLE_CHO :UInt32 = 588
    static let CYCLE_JUNG :UInt32 = 28
    
    static let CHO = [
        "ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ",
        "ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
    ]
    
    static let JUNG = [
        "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ","ㅕ", "ㅖ", "ㅗ", "ㅘ",
        "ㅙ", "ㅚ","ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ",
        "ㅣ"
    ]
    
    static let JONG = [
        "","ㄱ","ㄲ","ㄳ","ㄴ","ㄵ","ㄶ","ㄷ","ㄹ","ㄺ",
        "ㄻ","ㄼ","ㄽ","ㄾ","ㄿ","ㅀ","ㅁ","ㅂ","ㅄ","ㅅ",
        "ㅆ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
    ]
    
    static let JONG_DOUBLE = [
        "ㄳ":"ㄱㅅ","ㄵ":"ㄴㅈ","ㄶ":"ㄴㅎ","ㄺ":"ㄹㄱ","ㄻ":"ㄹㅁ",
        "ㄼ":"ㄹㅂ","ㄽ":"ㄹㅅ","ㄾ":"ㄹㅌ","ㄿ":"ㄹㅍ","ㅀ":"ㄹㅎ",
        "ㅄ":"ㅂㅅ"
    ]
    
    static func getChosung(_ word : String) -> String
    {
        var cho = ""
        for scalar in word.unicodeScalars{
            cho += getChoFromOneSyllable(scalar) ?? ""
        }
        return cho
    }
    static func getJungsung(_ word : String) -> String
    {
        var jung = ""
        for scalar in word.unicodeScalars{
            jung += getJungFromOneSyllable(scalar) ?? ""
        }
        return jung
    }
    static func getJongsung(_ word : String) -> String
    {
        var jong = ""
        for scalar in word.unicodeScalars{
            jong += getJongFromOneSyllable(scalar) ?? ""
        }
        return jong
    }
    
    // 주어진 "단어"를 자모음으로 분해해서 리턴하는 함수
    class func getJamo(_ word: String) -> String {
        var jamo = ""
        for scalar in word.unicodeScalars{
            jamo += getJamoFromOneSyllable(scalar) ?? ""
        }
        return jamo
    }
    
    // 주어진 "코드의 음절"을 자모음으로 분해해서 리턴하는 함수
    private class func getChoFromOneSyllable(_ n: UnicodeScalar) -> String?{
        if CharacterSet.modernHangul.contains(n){
            let index = n.value - INDEX_HANGUL_START
            let cho = CHO[Int(index / CYCLE_CHO)]
            return cho
        }else{
            return String(UnicodeScalar(n))
        }
    }
    
    private class func getJungFromOneSyllable(_ n: UnicodeScalar) -> String?{
        if CharacterSet.modernHangul.contains(n){
            let index = n.value - INDEX_HANGUL_START
            let jung = JUNG[Int((index % CYCLE_CHO) / CYCLE_JUNG)]
            return jung
        }else{
            return String(UnicodeScalar(n))
        }
    }
    
    private class func getJongFromOneSyllable(_ n: UnicodeScalar) -> String?{
        if CharacterSet.modernHangul.contains(n){
            let index = n.value - INDEX_HANGUL_START
            var jong = JONG[Int(index % CYCLE_JUNG)]
            if let disassembledJong = JONG_DOUBLE[jong] {
                jong = disassembledJong
            }
            return jong
        }else{
            return String(UnicodeScalar(n))
        }
    }
    
    private class func getJamoFromOneSyllable(_ n: UnicodeScalar) -> String?{
        if CharacterSet.modernHangul.contains(n){
            let index = n.value - INDEX_HANGUL_START
            let cho = CHO[Int(index / CYCLE_CHO)]
            let jung = JUNG[Int((index % CYCLE_CHO) / CYCLE_JUNG)]
            var jong = JONG[Int(index % CYCLE_JUNG)]
            if let disassembledJong = JONG_DOUBLE[jong] {
                jong = disassembledJong
            }
            return cho + jung + jong
        }else{
            return String(UnicodeScalar(n))
        }
    }
}

//
//  KoreanTextMatcher.swift
//  evInfra
//
//  Created by Shin Park on 2018. 5. 10..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation

class KoreanTextMatcher {
    
    init() {
    }
    
    public func isMatch(text: String, pattern: String) -> Bool {
        return match(text: text, pattern: pattern)
    }
    
    public func match(text: String, pattern: String) -> Bool {
        let length = text.count
        let patternLength = pattern.count
        
        if length < patternLength {
            return false
        }
        if length == 0 {
            return true
        }
        if patternLength == 0 {
            return true
        }
        
        return compareString(text: text, pattern: pattern);
    }
    
    private func compareString(text: String, pattern: String) -> Bool {
        for i in stride(from: 0, to: text.count - pattern.count + 1, by: 1) {
            for j in stride(from: 0, to: pattern.count, by: 1) {
                let textIndex = text.index(text.startIndex, offsetBy: i + j)
                let patternIndex = pattern.index(pattern.startIndex, offsetBy: j)
                if !choseongMatches(a: text[textIndex], b: pattern[patternIndex]) {
                    break
                }
                
                if j == pattern.count - 1 {
                    return true
                }
            }
        }
        return false
    }
    
    private func choseongMatches(a: Character, b: Character) -> Bool {
        if KoreanChar.isCompatChoseong(c: a) || KoreanChar.isChoseong(c: a) {
            return a == b;
        }
    
        var c: Character
        if KoreanChar.isCompatChoseong(c: b) {
            c = KoreanChar.getCompatChoseong(value: a)
        } else if KoreanChar.isChoseong(c: b) {
            c = KoreanChar.getChoseong(value: a)
        } else {
            c = a
        }
        return c == b
    }
}

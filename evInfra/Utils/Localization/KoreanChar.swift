//
//  KoreanChar.swift
//  evInfra
//
//  Created by Shin Park on 2018. 5. 10..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

class KoreanChar {
    private static let CHOSEONG_COUNT = 19
    private static let JUNGSEONG_COUNT = 21
    private static let JONGSEONG_COUNT = 28
    private static let HANGUL_SYLLABLE_COUNT = CHOSEONG_COUNT * JUNGSEONG_COUNT * JONGSEONG_COUNT
    private static let HANGUL_SYLLABLES_BASE = 0xAC00
    private static let HANGUL_SYLLABLES_END = HANGUL_SYLLABLES_BASE + HANGUL_SYLLABLE_COUNT
    
    private static let COMPAT_CHOSEONG_MAP = [
        0x3131, 0x3132, 0x3134, 0x3137, 0x3138, 0x3139, 0x3141, 0x3142, 0x3143, 0x3145,
        0x3146, 0x3147, 0x3148, 0x3149, 0x314A, 0x314B, 0x314C, 0x314D, 0x314E
    ]
    
    public static func isChoseong(c: Character) -> Bool {
        let unicode = c.unicode()
        return 0x1100 <= unicode && unicode <= 0x1112
    }
    
    public static func isCompatChoseong(c: Character) -> Bool {
        let unicode = c.unicode()
        return 0x3131 <= unicode && unicode <= 0x314E;
    }
    
    public static func isSyllable(c: Character) -> Bool {
        let unicode = c.unicode()
        return HANGUL_SYLLABLES_BASE <= unicode && unicode < HANGUL_SYLLABLES_END;
    }
    
    public static func getChoseong(value: Character) -> Character {
        if !isSyllable(c: value) {
            return "\0";
        }
        
        let choseongIndex = getChoseongIndex(syllable: value);
        let choseongCode = 0x1100 + choseongIndex
        return Character(UnicodeScalar(choseongCode)!)
    }
    
    public static func getCompatChoseong(value: Character) -> Character {
        if !isSyllable(c: value) {
            return "\0"
        }
        
        let choseongIndex = getChoseongIndex(syllable: value)
        return Character(UnicodeScalar(COMPAT_CHOSEONG_MAP[choseongIndex])!)
    }
    
    private static func getChoseongIndex(syllable: Character) -> Int {
        let syllableIndex = Int(syllable.unicode()) - HANGUL_SYLLABLES_BASE;
        let choseongIndex = syllableIndex / (JUNGSEONG_COUNT * JONGSEONG_COUNT);
        return choseongIndex;
    }
}

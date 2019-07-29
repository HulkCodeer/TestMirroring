//
//  Character.swift
//  evInfra
//
//  Created by Shin Park on 2018. 5. 10..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

extension Character {
    func unicode() -> UInt32 {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return scalars[scalars.startIndex].value
    }
}

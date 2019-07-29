//
//  String.swift
//  evInfra
//
//  Created by Shin Park on 2018. 5. 13..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

extension String {
    func size(OfFont font: UIFont) -> CGSize {
        let fontAttribute = [NSAttributedStringKey.font: font]
        return self.size(withAttributes: fontAttribute)  // for Single Line
    }
    
    func parseDouble() -> Double? {
        let str = self.filter { "01234567890.".contains($0)}
        return Double(str)
    }
    
    func currency() -> String {
        guard let doubleValue = Double(self) else {
            return self
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: doubleValue)) ?? self
    }
}

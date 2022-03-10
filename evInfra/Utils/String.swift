//
//  String.swift
//  evInfra
//
//  Created by Shin Park on 2018. 5. 13..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

extension String {
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
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
    
    func htmlToAttributedString() -> NSAttributedString? {
      
      guard let data = self.data(using: .utf8) else {
        return NSAttributedString()
      }
        
      do {
        return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
      } catch {
        return NSAttributedString()
      }
    }
    
    func urlToImage() -> UIImage? {
        let url = URL(string: self)
        let data = try? Data(contentsOf: url!)
        return UIImage(data: data!)
    }
    
    func isContainsHtmlTag() -> Bool {
        let pattern = "[<][a-zA-Z]*[>]"
        
        guard let range = self.range(of: pattern, options: .regularExpression) else { return false }
        
        return true
    }
}

//
//  String+Extension.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/13.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

extension String {
    
    var urlEncodedUTF8: String {
        self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? self
    }
    
    func toDate(dateFormat: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date: Date? = dateFormatter.date(from: self)
        return date
    }
    
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
        
        guard let _ = self.range(of: pattern, options: .regularExpression) else { return false }
        
        return true
    }
    
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

extension NSMutableAttributedString {
    func tagStyle(with nickNameTag: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor(named: "gr-5")!,
            .baselineOffset: 0
        ]
        
        self.append(NSAttributedString(string: nickNameTag + " ", attributes: attributes))
        return self
    }
    
    func defaultStyle(with string: String) -> NSMutableAttributedString {
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor(named: "nt-9")!,
            .baselineOffset: 0
        ]
        
        self.append(NSAttributedString(string: string, attributes: defaultAttributes))
        return self
    }
    
    func defaultStyleWithoutTag(targetString: String, fullText: String) -> NSMutableAttributedString {
        let range = (fullText as NSString).range(of: targetString)
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.foregroundColor, value: UIColor(named: "gr-5")!, range: range)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: range)
        
        return attributedString
    }
}

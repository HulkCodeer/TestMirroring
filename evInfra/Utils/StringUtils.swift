//
//  StringUtils.swift
//  evInfra
//
//  Created by Michael Lee on 2020/06/09.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
extension String {
    
    public func replaceFirst(of pattern:String,
                             with replacement:String) -> String {
        if let range = self.range(of: pattern){
            return self.replacingCharacters(in: range, with: replacement)
        }else{
            return self
        }
    }
    
    public func replaceLast(of pattern:String,
                            with replacement:String,
                            caseInsensitive: Bool = true) -> String
    {
        let options: String.CompareOptions
        if caseInsensitive {
            options = [.backwards, .caseInsensitive]
        } else {
            options = [.backwards]
        }
        
        if let range = self.range(of: pattern,
                                  options: options,
                                  range: nil,
                                  locale: nil) {
            
            return self.replacingCharacters(in: range, with: replacement)
        }
        return self
    }
    
    public func replaceAll(of pattern:String,
                           with replacement:String,
                           options: NSRegularExpression.Options = []) -> String{
        do{
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(0..<self.utf16.count)
        return regex.stringByReplacingMatches(in: self, options: [],
                                                  range: range, withTemplate: replacement)
        }catch{
            NSLog("replaceAll error: \(error)")
            return self
        }
    }
    
    func replace(of: String, with: String) -> String {
        return self.replacingOccurrences(of: of, with: with, options: NSString.CompareOptions.literal, range: nil)
    }

    
    public func equalsIgnoreCase(compare : String) -> Bool{
        if(self.caseInsensitiveCompare(compare) == ComparisonResult.orderedSame){
            return true
        }else{
            return false
        }
    }
    
    public func equals(_ compare : String) -> Bool{
        let compval  = compare
        if(self.compare(compval) == ComparisonResult.orderedSame){
            return true
        }else{
            return false
        }
    }
    
    func startsWith(_ text: String) -> Bool {
        return self.hasPrefix(text)
    }
    
    func endsWith(_ text: String) -> Bool {
        return self.hasSuffix(text)
    }
    
    func substring(_ beginIndex: Int) -> String {
        return String(self[self.index(self.startIndex, offsetBy: beginIndex)...])
    }
    
    func substring(from: Int, to: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: from)
        let end = self.index(start, offsetBy: to - from)
        return String(self[start ..< end])
    }
    
    func indexOf(_ input: String, options: String.CompareOptions = .literal) -> String.Index? {
        return self.range(of: input, options: options)?.lowerBound
    }
    
    func lastIndexOf(_ input: String) -> String.Index? {
        return indexOf(input, options: .backwards)
    }

    func trim() -> String
    {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    func charAt(_ at: Int) -> Character {
        let charIndex = self.index(self.startIndex, offsetBy: at)
        return self[charIndex]
    }

    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
        
    func localizedWithComment(comment: String) -> String {
        return NSLocalizedString(self, comment:comment)
    }
    
    mutating func addString(_ str: String) {
        self = self + str
    }
    
    func capturedGroups(withRegex pattern: String) -> [String] {
        var results = [String]()
        
        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return results
        }
        
        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count))
        
        for match in matches {
            let lastRangeIndex = match.numberOfRanges - 1
            guard lastRangeIndex >= 1 else { return results }
            
            for i in 1...lastRangeIndex {
                let capturedGroupIndex = match.range(at: i)
                let matchedString = (self as NSString).substring(with: capturedGroupIndex)
                results.append(matchedString)
            }
        }
        return results
    }
    

        func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
            let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
            let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
            
            return ceil(boundingBox.height)
        }
        
        func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
            let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
            let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
            
            return ceil(boundingBox.width)
        }
    
}

class StringUtils {
    public static func isNullOrEmpty(_ s : String?) -> Bool {
        return ((s == nil) || (s! == "") || (s!.trimmingCharacters(in: NSCharacterSet.whitespaces) == ""));
    }

    public static func getPatternString( regex : String,  content : String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: .caseInsensitive)
            let results = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))

            return results.map {
                String(content[Range($0.range, in: content)!])
            }
        } catch let error {
            Log.e(tag: "StringUtils", msg: "invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    public static func getThousandNumber(_ number: Int64) -> String {
        var strNumber = String(number)
        strNumber = strNumber.replaceAll(of: "(?<=[0-9])(?=([0-9][0-9][0-9])+(?![0-9]))", with: ",")
        return strNumber
    }
    
    public static func removeHtmlTag(_ src : String) ->String {
        var striped = "";
        let regex2 = "<(/)?([a-zA-Z]*)(\\s[a-zA-Z]*=[^>]*)?(\\s)*(/)?>";
        striped = src.replaceAll(of: regex2, with: "");
        return striped;
    }
    
    public static func isNumber(_ string: String) -> Bool {
        
        if let _ = Int(string) {
            return true
        }
        return false
    }
    
    public static func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            Log.e(tag: "StringUtils", msg: "invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    public static func convertDistanceString(distance : Double) -> String{
        let km = Int(distance / 1000);
        if (km > 0) {
            return String(format: "%.2fkm", distance / 1000)
        } else {
            return String(format: "%.0fm", distance)
        }
    }
}

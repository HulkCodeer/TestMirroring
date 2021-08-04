//
//  UILabel.swift
//  evInfra
//
//  Created by SH on 2021/08/04.
//  Copyright © 2021 soft-berry. All rights reserved.
//

extension UILabel {
    
    func textSize(font: UIFont, text: String) -> CGRect {
        let myText = text as NSString
        
        let rect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return labelSize
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        
        let label:UILabel = PaddingLabel()
        label.frame = CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
}

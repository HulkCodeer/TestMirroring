//
//  UILabel.swift
//  evInfra
//
//  Created by SH on 2021/08/04.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit

class PaddingLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 3.0
    @IBInspectable var bottomInset: CGFloat = 3.0
    @IBInspectable var leftInset: CGFloat = 5.0
    @IBInspectable var rightInset: CGFloat = 5.0
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: topInset, dy: topInset))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
}


extension UILabel {        
    func setUnderline(underLineText: String) {
        guard let _text = self.text else { return }
        let attributedString = NSMutableAttributedString(string: _text)
        attributedString.addAttribute(.underlineStyle,
                                      value: NSUnderlineStyle.styleSingle.rawValue,
                                      range: (attributedString.string as NSString).range(of: underLineText)
        )    
        self.attributedText = attributedString
    }
    
    func setUnderline() {
        guard let _text = self.text else { return }
        let attributedString = NSMutableAttributedString(string: _text)
        attributedString.addAttribute(.underlineStyle,
                                      value: NSUnderlineStyle.styleSingle.rawValue,
                                      range: NSRange(location: 0, length: _text.count)
        )
        self.attributedText = attributedString
    }
    
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
    
    func tagLabel(target: String) {
        let tagAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor(named: "gr-5")!,
            .baselineOffset: 0
        ]
        let fullText = self.text ?? ""
        let range = (fullText as NSString).range(of: target)
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttributes(tagAttributes, range: range)
        self.attributedText = attributedString
    }
}

//
//  UIButton.swift
//  evInfra
//
//  Created by bulacode on 20/06/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit

extension UIButton {

    func alignTextUnderImage(spacing: CGFloat = 6.0) {
        if let image = self.imageView?.image {
            let imageSize: CGSize = image.size
            self.titleEdgeInsets = UIEdgeInsets(top: spacing, left: -imageSize.width, bottom: -(imageSize.height) + spacing, right: 0.0)
            
            let labelString = NSString(string: self.titleLabel!.text!)
            let titleSize = labelString.size(withAttributes: [NSAttributedString.Key.font: self.titleLabel!.font])
            self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: -titleSize.width)
            
            self.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -spacing, right: 0.0)
        }
    }

    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(backgroundImage, for: state)
    }
    
    // change button color according to state
    func setBgColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
         
        self.setBackgroundImage(backgroundImage, for: state)
    }
    
    // custom button (border, radius)
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        self.clipsToBounds = true
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        self.layer.mask = mask
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = mask.frame
        borderLayer.name = "borderLayer"
        
        // remove unused layer
        if let layers = layer.sublayers {
            for layer in layers{
                if let name = layer.name{
                    if name.elementsEqual("borderLayer"){
                        layer.removeFromSuperlayer()
                    }
                }
            }
            layer.addSublayer(borderLayer)
        }
    }
    
    func setRoundGradient(startColor: CGColor, endColor:CGColor) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [startColor, endColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y:1.0)
        gradient.locations = [0.0, 1.0]
        gradient.cornerRadius = 20
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func setDefaultBackground(cornerRadius: CGFloat) {
        let startColor = UIColor.init(hex: "#49D2C4")
        let endColor = UIColor.init(hex: "#3AB2D3")
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y:1.0)
        gradient.locations = [0.0, 1.0]
        gradient.cornerRadius = cornerRadius
        self.layer.insertSublayer(gradient, at: 0)
    }
}

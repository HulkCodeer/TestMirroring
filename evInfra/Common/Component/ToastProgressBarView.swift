//
//  CircularProgressBarView.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/10/23.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

internal final class ToastProgressBarView: UIView {
    
    // MARK: UI
    
    private var circleLayer = CAShapeLayer()
    
    // MARK: VARIABLE
        
    // MARK: SYSTEM FUNC
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createCircularPath()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.createCircularPath()
    }
    
    func createCircularPath() {
        let center = CGPoint(x: frame.width/2, y: frame.height/2)
        let path = UIBezierPath(arcCenter: center,
                                radius: frame.width/2,
                                startAngle: -CGFloat.pi/2,
                                endAngle: 2*CGFloat.pi-CGFloat.pi/2,
                                clockwise: true)
        
        var circleBackLayer = CAShapeLayer()
        circleBackLayer.frame = bounds
        circleBackLayer.path = path.cgPath
        circleBackLayer.fillColor = UIColor.clear.cgColor
        circleBackLayer.lineCap = CAShapeLayerLineCap(rawValue: "round")
        circleBackLayer.strokeColor = Colors.backgroundSecondary.color.cgColor
        circleBackLayer.lineWidth = 2
        self.layer.addSublayer(circleBackLayer)
                                    
        circleLayer.frame = bounds
        circleLayer.path = path.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = CAShapeLayerLineCap(rawValue: "round")
        circleLayer.strokeColor = Colors.backgroundPositive.color.cgColor
        circleLayer.lineWidth = 2
        self.layer.addSublayer(circleLayer)
        
    }
    
    func animation(duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = duration
        animation.fillMode = CAMediaTimingFillMode(rawValue: "forwards")
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        circleLayer.add(animation, forKey: "circle")
    }
}

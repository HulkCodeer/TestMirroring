//
//  CircularProgressBarView.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/15.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

internal final class CircularProgressBarView: UIView {
    
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
                                    
        circleLayer.frame = bounds
        circleLayer.path = path.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = "round"
        circleLayer.strokeColor = Colors.backgroundPositive.color.cgColor
        circleLayer.lineWidth = 3
        self.layer.addSublayer(circleLayer)
        
    }
    
    func progressAnimation(duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 5
        animation.fillMode = "forwards"
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        circleLayer.add(animation, forKey: "circle")
    }
}

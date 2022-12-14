//
//  CircularProgressBar.swift
//  evInfra
//
//  Created by bulacode on 05/07/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit

class CircularProgressBar: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
//        label.text = "-"
    }
    
    
    //MARK: Public
    
    public var lineWidth:CGFloat = 12 {
        didSet{
            foregroundLayer.lineWidth = lineWidth
            backgroundLayer.lineWidth = lineWidth
        }
    }
    
    public var labelSize: CGFloat = 20 {
        didSet {
//            label.font = UIFont.systemFont(ofSize: labelSize)
//            label.sizeToFit()
//            configLabel()
        }
    }
    
    public var safePercent: Int = 100 {
        didSet{
            setForegroundLayerColorForSafePercent()
        }
    }
    
    public func setRateProgress(progress: Double) {
        foregroundLayer.strokeEnd = CGFloat(progress * 0.01)
        self.value = Int(progress)
//        self.label.text = "\(self.value)%"
        self.setForegroundLayerColorForSafePercent()
//        self.configLabel()
        
    }
    
//    public func setProgress(to progressConstant: Double, withAnimation: Bool) {
//
//
//        foregroundLayer.strokeEnd = CGFloat(progress)
//
//        if withAnimation {
//            let animation = CABasicAnimation(keyPath: "strokeEnd")
//            animation.fromValue = 0
//            animation.toValue = progress
//            animation.duration = 2
//            foregroundLayer.add(animation, forKey: "foregroundAnimation")
//
//        }
//
//        var currentTime:Double = 0
//        let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { (timer) in
//            if currentTime >= 2{
//                timer.invalidate()
//            } else {
//                currentTime += 0.05
//                let percent = currentTime/2 * 100
//                self.value = Int(progress * percent)
//                self.label.text = "\(self.value)%"
//                self.setForegroundLayerColorForSafePercent()
//                self.configLabel()
//            }
//        }
//        timer.fire()
//
//    }
    
    
    
    
    //MARK: Private
    private var label = UILabel()
    private let foregroundLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private let fgradientLayer = CAGradientLayer()
    private var value = 0
    private var radius: CGFloat {
        get{
            if self.frame.width < self.frame.height { return (self.frame.width - lineWidth)/2 }
            else { return (self.frame.height - lineWidth)/2 }
        }
    }
    
    private var pathCenter: CGPoint{ get{ return self.convert(self.center, from:self.superview) } }
    private func makeBar(){
        self.layer.sublayers = nil
        drawBackgroundLayer()
        drawForegroundLayer()
    }
    
    private func drawBackgroundLayer(){
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        self.backgroundLayer.path = path.cgPath
        self.backgroundLayer.strokeColor = UIColor(rgb: 0xeeeeee).cgColor
        self.backgroundLayer.lineWidth = lineWidth
        self.backgroundLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(backgroundLayer)
        
    }
    
    private func drawForegroundLayer(){
        
        let startAngle = (-CGFloat.pi/2)
        let endAngle = 2 * CGFloat.pi + startAngle
        
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        foregroundLayer.path = path.cgPath
        foregroundLayer.lineWidth = lineWidth
        foregroundLayer.fillColor = UIColor.clear.cgColor
        
        foregroundLayer.strokeEnd = 0
        
//        if self.value < 25 {
//            foregroundLayer.strokeColor = UIColor(rgb: 0xe57373).cgColor
//        }else if self.value < 50{
//            foregroundLayer.strokeColor = UIColor(rgb: 0xfff176).cgColor
//        }else if self.value < 75{
//            foregroundLayer.strokeColor = UIColor(rgb: 0x64b5f6).cgColor
//        }else{
//            foregroundLayer.strokeColor = UIColor(rgb: 0x2286c3).cgColor
//        }
        foregroundLayer.strokeColor = UIColor(named:"content-positive")?.cgColor
        self.layer.addSublayer(foregroundLayer)
        
    }
    
    private func makeLabel(withText text: String) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.text = text
        label.font = UIFont.systemFont(ofSize: labelSize)
        label.sizeToFit()
        label.center = pathCenter
        return label
    }
    
    private func configLabel(){
        label.sizeToFit()
        label.center = pathCenter
    }
    
    private func setForegroundLayerColorForSafePercent(){
        foregroundLayer.strokeColor = UIColor(named:"content-positive")?.cgColor
//        if self.value < 25 {
//            foregroundLayer.strokeColor = UIColor(rgb: 0xe57373).cgColor
//        }else if self.value < 50{
//            foregroundLayer.strokeColor = UIColor(rgb: 0xfff176).cgColor
//        }else if self.value < 75{
//            foregroundLayer.strokeColor = UIColor(rgb: 0x64b5f6).cgColor
//        }else{
//            foregroundLayer.strokeColor = UIColor(rgb: 0x2286c3).cgColor
//        }
        
//        if Int(label.text!)! >= self.safePercent {
//            self.foregroundLayer.strokeColor = UIColor.green.cgColor
//        } else {
//            self.foregroundLayer.strokeColor = UIColor.red.cgColor
//        }
    }
    
    private func setupView() {
        makeBar()
        self.addSubview(label)
    }
    
    
    
    //Layout Sublayers
    private var layoutDone = false
    override func layoutSublayers(of layer: CALayer) {
        if !layoutDone {
//            let tempText = label.text
            setupView()
//            label.text = tempText
            layoutDone = true
        }
    }
}

//
//  SoftBerryTooltipView.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/10/19.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

internal final class TooltipView: UIView {
    enum Consts {
        static let tipWidth: CGFloat = 12
        static let tipHeight: CGFloat = 10
        static let tipTopMargin: CGFloat = 8
    }
    
    enum TipDirection {
        case top
        case bottom
        case left
        case right
    }
    
    // MARK: VARIABLE
    
    internal struct Configure {
        
        fileprivate var tipLeftMargin: CGFloat
        fileprivate var tipDirection: TipDirection
        fileprivate var color: UIColor
        fileprivate var maxWidth: CGFloat
        fileprivate var leadingMargin: CGFloat
        fileprivate var topMargin: CGFloat
        fileprivate var font: UIFont
        
        fileprivate var animating: Animating = Animating()
        
        struct Animating {
            fileprivate var dismissTransform     = CGAffineTransform(scaleX: 0.1, y: 0.1)
            fileprivate var dismissFinalAlpha    = CGFloat(0)
            fileprivate var dismissDuration      = 0.7
            fileprivate var springDamping        = CGFloat(0.7)
            fileprivate var springVelocity       = CGFloat(0.7)
        }
                
        internal init(tipLeftMargin: CGFloat, maxWidth: CGFloat, leadingMargin: CGFloat,
                      topMargin: CGFloat, font: UIFont, tipDirection: TipDirection, color: UIColor) {
            self.tipLeftMargin = tipLeftMargin
            self.tipDirection = tipDirection
            self.color = color
            self.maxWidth = maxWidth
            self.leadingMargin = leadingMargin
            self.topMargin = topMargin
            self.font = font
        }
    }
    
    private var configure: Configure
    
    // MARK: SYSTEM FUNC
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(configure: Configure) {
        self.configure = configure
        
        super.init(frame: .zero)
        
        self.backgroundColor = configure.color
    }
                
    // MARK: FUNC
    
    internal func show(message: String) {
        self.makeTootip(message: message)
    }
    
    internal func show(message: String, forView: UIView) {
        self.makeTootip(message: message, targetView: forView)
    }
    
    private func makeTootip(message: String, targetView: UIView? = nil) {
        let path = CGMutablePath()
        let tipCenterPoint = Consts.tipWidth / 2.0
        let tipEndPoint = self.configure.tipLeftMargin + Consts.tipWidth
                
        let messageSize = message.toSizeRect(of: self.configure.font, maxWidth: self.configure.maxWidth)
        let totalWidth = messageSize.width + 16
        let totalheight = messageSize.height + 16
        
        // Default Top
        var frameX: CGFloat = self.configure.leadingMargin
        var frameY: CGFloat = self.configure.topMargin + Consts.tipHeight
        var frameWidth: CGFloat = totalWidth
        var frameHeight: CGFloat = totalheight + Consts.tipHeight
                                                                
        switch self.configure.tipDirection {
        case .top:
            path.move(to: CGPoint(x: self.configure.tipLeftMargin, y: 0))
            path.addLine(to: CGPoint(x: self.configure.tipLeftMargin + tipCenterPoint, y: -Consts.tipHeight))
            path.addLine(to: CGPoint(x: tipEndPoint, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))
            
        case .bottom:
            path.move(to: CGPoint(x: self.configure.tipLeftMargin, y: totalheight))
            path.addLine(to: CGPoint(x: self.configure.tipLeftMargin + tipCenterPoint, y: totalheight + Consts.tipHeight))
            path.addLine(to: CGPoint(x: tipEndPoint, y: totalheight))
            path.addLine(to: CGPoint(x: self.configure.tipLeftMargin, y: totalheight))
                        
            frameY = self.configure.topMargin + Consts.tipHeight
            frameWidth = totalWidth
            frameHeight = totalheight + Consts.tipHeight
            
        case .left:
            path.move(to: CGPoint(x: 0, y: self.configure.tipLeftMargin))
            path.addLine(to: CGPoint(x: -Consts.tipHeight, y: self.configure.tipLeftMargin + tipCenterPoint))
            path.addLine(to: CGPoint(x: 0, y: tipEndPoint))
            path.addLine(to: CGPoint(x: 0, y: 0))
                       
            frameX = self.configure.leadingMargin + Consts.tipHeight
            frameY = self.configure.topMargin
            frameWidth = totalWidth + Consts.tipHeight
            frameHeight = totalheight
            
        case .right:
            path.move(to: CGPoint(x: totalWidth, y: self.configure.tipLeftMargin))
            path.addLine(to: CGPoint(x: totalWidth + Consts.tipHeight, y: self.configure.tipLeftMargin + tipCenterPoint))
            path.addLine(to: CGPoint(x: totalWidth, y: self.configure.tipLeftMargin + tipEndPoint))
            path.addLine(to: CGPoint(x: totalWidth, y: self.configure.tipLeftMargin))
            
            frameX = self.configure.leadingMargin + Consts.tipHeight
            frameY = self.configure.topMargin
            frameWidth = totalWidth + Consts.tipHeight
            frameHeight = totalheight
        }
        
        // TEST CODE
        // MainViewcontroller filterbarView.evPay
//        (x 56.0, y 81.0, width 91.0, height 30.0)
                                
        if let _targetView = targetView {
            let globalFrame = _targetView.globalFrame
            switch self.configure.tipDirection {
            case .top:
                frameX = globalFrame.origin.x + (globalFrame.bounds.width / 2) - self.configure.tipLeftMargin - tipCenterPoint
                frameY = -(globalFrame.origin.y + (globalFrame.bounds.height) + 8)                
                
            case .bottom:
                frameX = globalFrame.origin.x + (globalFrame.bounds.width / 2) - self.configure.tipLeftMargin - tipCenterPoint
                frameY = globalFrame.origin.y - 8
                
            case .right, .left:
                frameX = globalFrame.origin.x + (globalFrame.bounds.width / 2)
                
            }
        } else {
            
        }
                                        
        self.frame = CGRect(x: frameX, y: frameY, width: frameWidth, height: frameHeight)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tap)
        
        let shape = CAShapeLayer()
        shape.path = path
        shape.fillColor = self.configure.color.cgColor
                
        self.layer.insertSublayer(shape, at: 0)
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 8
                
        let messageLbl = UILabel()
        messageLbl.textColor = .white
        messageLbl.text = "\(message)"
        messageLbl.numberOfLines = 0
        messageLbl.font = .systemFont(ofSize: 16, weight: .regular)
        messageLbl.lineBreakMode = .byWordWrapping
        
        self.addSubview(messageLbl)
        messageLbl.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
    }

    @objc func handleTap() {
        self.dismiss()
    }
    
    func dismiss(withCompletion completion: (() -> ())? = nil){
        UIView.animate(withDuration: self.configure.animating.dismissDuration, delay: 0, usingSpringWithDamping: self.configure.animating.springDamping, initialSpringVelocity: self.configure.animating.springVelocity , options: [.curveEaseInOut], animations: {
            self.transform = self.configure.animating.dismissTransform
            self.alpha = self.configure.animating.dismissFinalAlpha
        }) { (finished) -> Void in
            self.removeFromSuperview()
            self.transform = CGAffineTransform.identity
        }
    }
}

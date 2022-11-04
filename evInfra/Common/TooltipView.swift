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
        static let tipHeight: CGFloat = 8
        static let tipTopMargin: CGFloat = 8
        static var totalHeight: CGFloat = 44
        static var totalViewRadius: CGFloat = 5
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
        fileprivate var maxWidth: CGFloat
        fileprivate var font: UIFont = .systemFont(ofSize: 14, weight: .regular)
        fileprivate var animating: Animating = Animating()
        fileprivate var leftImg: UIImage?
        
        struct Animating {
            fileprivate var dismissTransform     = CGAffineTransform(scaleX: 0.1, y: 0.1)
            fileprivate var dismissFinalAlpha    = CGFloat(0)
            fileprivate var dismissDuration      = 0.7
            fileprivate var springDamping        = CGFloat(0.7)
            fileprivate var springVelocity       = CGFloat(0.7)
        }
                
        internal init(tipLeftMargin: CGFloat, tipDirection: TipDirection, maxWidth: CGFloat, leftImg: UIImage? = nil) {
            self.tipLeftMargin = tipLeftMargin
            self.tipDirection = tipDirection
            self.maxWidth = maxWidth
            self.leftImg = leftImg
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
    }
                        
    // MARK: FUNC
    
    internal func show(message: String) {
        self.makeTooltip(message: message)
    }
    
    internal func show(message: String, attrString: String) {
        self.makeTooltip(message: message, attrString: attrString)
    }
    
    private func makeTooltip(message: String, attrString: String) {
        let path = CGMutablePath()
        let tipCenterPoint = Consts.tipWidth / 2.0
        let tipEndPoint = self.configure.tipLeftMargin + Consts.tipWidth
                
        let messageSize = message.toSizeRect(of: self.configure.font, maxWidth: self.configure.maxWidth)
        let totalWidth = messageSize.width
                                                                        
        switch self.configure.tipDirection {
        case .top:
            path.move(to: CGPoint(x: self.configure.tipLeftMargin, y: 0))
            path.addLine(to: CGPoint(x: self.configure.tipLeftMargin + tipCenterPoint, y: -Consts.tipHeight))
            path.addLine(to: CGPoint(x: tipEndPoint, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))
            
        case .bottom:
            path.move(to: CGPoint(x: self.configure.tipLeftMargin, y: Consts.totalHeight))
            path.addLine(to: CGPoint(x: self.configure.tipLeftMargin + tipCenterPoint, y: Consts.totalHeight + Consts.tipHeight))
            path.addLine(to: CGPoint(x: tipEndPoint, y: Consts.totalHeight))
            path.addLine(to: CGPoint(x: self.configure.tipLeftMargin, y: Consts.totalHeight))
                                    
        case .left:
            path.move(to: CGPoint(x: 0, y: self.configure.tipLeftMargin))
            path.addLine(to: CGPoint(x: -Consts.tipHeight, y: self.configure.tipLeftMargin + tipCenterPoint))
            path.addLine(to: CGPoint(x: 0, y: tipEndPoint))
            path.addLine(to: CGPoint(x: 0, y: 0))
                                   
        case .right:
            path.move(to: CGPoint(x: totalWidth, y: self.configure.tipLeftMargin))
            path.addLine(to: CGPoint(x: totalWidth + Consts.tipHeight, y: self.configure.tipLeftMargin + tipCenterPoint))
            path.addLine(to: CGPoint(x: totalWidth, y: self.configure.tipLeftMargin + tipEndPoint))
            path.addLine(to: CGPoint(x: totalWidth, y: self.configure.tipLeftMargin))
        }
                                                        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tap)
        
        let shape = CAShapeLayer()
        shape.path = path
        shape.fillColor = Colors.contentPrimary.color.cgColor
                
        self.layer.insertSublayer(shape, at: 0)
        self.layer.masksToBounds = false
         
        let totalView = UIView().then {
            $0.backgroundColor = Colors.contentPrimary.color
            $0.IBcornerRadius = Consts.totalViewRadius
        }
        
        self.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(Consts.totalHeight)
        }
        
        let leftImgView = UIImageView().then {
            $0.image = self.configure.leftImg
            $0.tintColor = Colors.contentPositive.color
        }
        
        totalView.addSubview(leftImgView)
        leftImgView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().offset(-12)
            let isImg = self.configure.leftImg != nil
            $0.width.height.equalTo(isImg ? 20 : 3)
        }
        
        let attributeText = NSMutableAttributedString(string: message)
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: Colors.nt0.color

        attributeText.setAttributes(attributes, range: NSRange(location: 0, length: message.count))
        
        _ = message.getArrayAfterRegex(regex: "\(attrString)")
            .map { NSRange($0, in: message) }
            .map {
                attributeText.setAttributes(
                    [.font: UIFont.systemFont(ofSize: 14, weight: .bold),
                        .foregroundColor: Colors.contentPositive.color],
                    range: $0)
            }
                
        let messageLbl = UILabel().then {
            $0.textColor = .white
            $0.attributedText = attributeText
            $0.numberOfLines = 0
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.lineBreakMode = .byWordWrapping
        }
                
        totalView.addSubview(messageLbl)
        messageLbl.snp.makeConstraints {
            $0.leading.equalTo(leftImgView.snp.trailing).offset(5)
            $0.top.trailing.bottom.equalToSuperview().inset(8)
        }
    }
        
    private func makeTooltip(message: String, targetView: UIView? = nil) {
        let path = CGMutablePath()
        let tipCenterPoint = Consts.tipWidth / 2.0
        let tipEndPoint = self.configure.tipLeftMargin + Consts.tipWidth
                
        let messageSize = message.toSizeRect(of: self.configure.font, maxWidth: self.configure.maxWidth)
        let totalWidth = messageSize.width
                                                                        
        switch self.configure.tipDirection {
        case .top:
            path.move(to: CGPoint(x: self.configure.tipLeftMargin, y: 0))
            path.addLine(to: CGPoint(x: self.configure.tipLeftMargin + tipCenterPoint, y: -Consts.tipHeight))
            path.addLine(to: CGPoint(x: tipEndPoint, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))
            
        case .bottom:
            path.move(to: CGPoint(x: self.configure.tipLeftMargin, y: Consts.totalHeight))
            path.addLine(to: CGPoint(x: self.configure.tipLeftMargin + tipCenterPoint, y: Consts.totalHeight + Consts.tipHeight))
            path.addLine(to: CGPoint(x: tipEndPoint, y: Consts.totalHeight))
            path.addLine(to: CGPoint(x: self.configure.tipLeftMargin, y: Consts.totalHeight))
                                    
        case .left:
            path.move(to: CGPoint(x: 0, y: self.configure.tipLeftMargin))
            path.addLine(to: CGPoint(x: -Consts.tipHeight, y: self.configure.tipLeftMargin + tipCenterPoint))
            path.addLine(to: CGPoint(x: 0, y: tipEndPoint))
            path.addLine(to: CGPoint(x: 0, y: 0))
                                   
        case .right:
            path.move(to: CGPoint(x: totalWidth, y: self.configure.tipLeftMargin))
            path.addLine(to: CGPoint(x: totalWidth + Consts.tipHeight, y: self.configure.tipLeftMargin + tipCenterPoint))
            path.addLine(to: CGPoint(x: totalWidth, y: self.configure.tipLeftMargin + tipEndPoint))
            path.addLine(to: CGPoint(x: totalWidth, y: self.configure.tipLeftMargin))
        }
                                                        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tap)
        
        let shape = CAShapeLayer()
        shape.path = path
        shape.fillColor = Colors.contentPrimary.color.cgColor
                
        self.layer.insertSublayer(shape, at: 0)
        self.layer.masksToBounds = false
         
        let totalView = UIView().then {
            $0.backgroundColor = Colors.contentPrimary.color
            $0.IBcornerRadius = Consts.totalViewRadius
        }
        
        self.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(Consts.totalHeight)
        }
        
        let leftImgView = UIImageView().then {
            $0.image = self.configure.leftImg
            $0.tintColor = Colors.contentPositive.color
        }
        
        totalView.addSubview(leftImgView)
        leftImgView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().offset(-12)
            let isImg = self.configure.leftImg != nil
            $0.width.height.equalTo(isImg ? 20 : 0)
        }
                
        let messageLbl = UILabel().then {
            $0.textColor = Colors.contentOnColor.color
            $0.text = "\(message)"
            $0.numberOfLines = 0
            $0.font = self.configure.font
        }                        
                
        totalView.addSubview(messageLbl)
        messageLbl.snp.makeConstraints {
            $0.leading.equalTo(leftImgView.snp.trailing)
            $0.top.bottom.equalToSuperview().inset(10)
            $0.trailing.equalToSuperview().inset(12)
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

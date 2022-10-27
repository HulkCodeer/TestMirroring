//
//  ShipmentStepView.swift
//  evInfra
//
//  Created by 박현진 on 2022/10/24.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RxSwift
import RxCocoa

internal final class ShipmentStepView: UIView {
    
    enum ShipmentStatusType: Int, CaseIterable {
        case sendReady = 0
        case sending = 1
        case sendComplete = 2
        
        internal var toString: String {
            switch self {
            case .sendReady: return "발송 준비중"
            case .sending: return "발송중"
            case .sendComplete: return "우편함 확인"
            }
        }
    }
    
    // MARK: UI
    
    
    
    
    // MARK: VARIABLE
    
    private var disposebag = DisposeBag()
    
    // MARK: SYSTEM FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
            
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    // MARK: FUNC
    
    func makeUI() {
        
    }
    
    internal func bind(model: MembershipCardInfo) {
        
    }
    
    private func makeStepView() {
        
    }
    
    private func makeDotView() -> CAShapeLayer {
        let center = CGPoint(x: frame.width/2, y: frame.height/2)
        let path = UIBezierPath(arcCenter: center,
                                radius: frame.width/2,
                                startAngle: -CGFloat.pi/2,
                                endAngle: 2*CGFloat.pi-CGFloat.pi/2,
                                clockwise: true)
        
        let circleLayer = CAShapeLayer()
        circleLayer.frame = bounds
        circleLayer.path = path.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = CAShapeLayerLineCap(rawValue: "round")
        circleLayer.strokeColor = Colors.backgroundSecondary.color.cgColor
        circleLayer.lineWidth = 2
        return circleLayer
    }
}

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
    
    private lazy var shipmentStatusGuideLbl = UILabel().then {
        $0.text = "EV Pay 카드 발송 현황"
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = .black
        $0.textAlignment = .natural
    }
    
    private lazy var totalStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .fill
        $0.spacing = 0
    }
            
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
        self.addSubview(shipmentStatusGuideLbl)
        shipmentStatusGuideLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview()
        }
        
        self.addSubview(totalStackView)
        totalStackView.snp.makeConstraints {
            $0.top.equalTo(shipmentStatusGuideLbl.snp.bottom).offset(9)
            $0.leading.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-39)
        }
    }
    
    internal func bind(model: MembershipCardInfo) {
        for type in ShipmentStatusType.allCases {
            let view = self.makeStepView(type: type)
            totalStackView.addArrangedSubview(view)
        }
    }
    
    private func makeStepView(type: ShipmentStatusType) -> UIView {
        
        let totalView = UIView()
        
        let dotView = UIView()
        dotView.layer.addSublayer(self.makeDotView(type: type))
        
        totalView.addSubview(dotView)
        dotView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(22)
            $0.top.equalToSuperview()
            $0.width.height.equalTo(12)
        }
        
        return totalView
    }
    
    private func makeDotView(type: ShipmentStatusType) -> CAShapeLayer {
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

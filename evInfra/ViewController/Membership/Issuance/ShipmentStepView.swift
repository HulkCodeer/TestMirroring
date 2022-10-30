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
    enum DotConstant {
        static let size: CGFloat = 12
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
        
        let lineView = self.createLineView()
        self.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.height.equalTo(4)
            $0.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    internal func bind(model: MembershipCardInfo) {
        for convertStatus in model.convertStatusArr {
            let view = self.makeStepView(statusInfo: convertStatus)
            totalStackView.addArrangedSubview(view)
        }
    }
    
    private func makeStepView(statusInfo: MembershipCardInfo.ConvertStatus) -> UIView {
        
        let totalView = UIView()
        
        let dotView = UIView()
        dotView.layer.addSublayer(self.makeDotView(statusInfo: statusInfo))
        
        totalView.addSubview(dotView)
        dotView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(22)
            $0.top.equalToSuperview()
            $0.width.height.equalTo(DotConstant.size)
        }
        
        return totalView
    }
    
    private func makeDotView(statusInfo: MembershipCardInfo.ConvertStatus) -> CAShapeLayer {
        let center = CGPoint(x: DotConstant.size/2, y: DotConstant.size/2)
        let path = UIBezierPath(arcCenter: center,
                                radius: DotConstant.size/2,
                                startAngle: -CGFloat.pi/2,
                                endAngle: 2*CGFloat.pi-CGFloat.pi/2,
                                clockwise: true)
        
        let circleLayer = CAShapeLayer()
        circleLayer.frame = bounds
        circleLayer.path = path.cgPath
        circleLayer.fillColor = statusInfo.passType == .current ? UIColor.clear.cgColor : Colors.contentPrimary.color.cgColor
        circleLayer.lineCap = CAShapeLayerLineCap(rawValue: "round")
        circleLayer.strokeColor = Colors.contentPrimary.color.cgColor
        circleLayer.lineWidth = 2
        return circleLayer
    }
    
    internal func createLineView(color: UIColor? = Colors.backgroundSecondary.color) -> UIView {
        return UIView().then {
            $0.backgroundColor = color
        }
    }
}

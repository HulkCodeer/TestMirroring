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
        
        let lineView = self.createLineView(color: Colors.contentDisabled.color)
        totalView.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.top.equalTo(dotView.snp.bottom)
            $0.center.equalTo(dotView)
            $0.width.equalTo(2)
            $0.bottom.equalToSuperview()
        }
        
        let statusDescTotalView = UIView().then {
            $0.IBcornerRadius = 15
            $0.backgroundColor = Colors.backgroundSecondary.color
        }
        
        totalView.addSubview(statusDescTotalView)
        statusDescTotalView.snp.makeConstraints {
            $0.leading.equalTo(lineView.snp.trailing).offset(26)
            $0.top.equalTo(dotView.snp.bottom).offset(14)
            $0.height.equalTo(120)
        }
        
        let statusDescLbl = UILabel().then {
            $0.text = "신청 내용을 확인중입니다.\n영업일 기준 2~3일내로 발송 예정입니다."
            $0.textAlignment = .natural
            $0.textColor = Colors.contentPrimary.color
            $0.font = .systemFont(ofSize: 14, weight: .regular)
        }
        
        statusDescTotalView.addSubview(statusDescLbl)
        statusDescLbl.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        let moveChargingHelpGuideTotalView = UIView().then {
            $0.backgroundColor = .white
            $0.IBcornerRadius = 18
        }
        
        statusDescTotalView.addSubview(moveChargingHelpGuideTotalView)
        moveChargingHelpGuideTotalView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(statusDescLbl.snp.bottom).offset(8)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        let moveChargingHelpGuideLbl = UILabel().then {
            $0.text = "카드 받기 전 충전 방법"
            $0.textAlignment = .center
            $0.textColor = Colors.contentPrimary.color
            $0.font = .systemFont(ofSize: 14, weight: .regular)
        }
        
        moveChargingHelpGuideTotalView.addSubview(moveChargingHelpGuideLbl)
        moveChargingHelpGuideLbl.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        let arrowImgView = ChevronArrow.init(.size16(.right))
        
        moveChargingHelpGuideTotalView.addSubview(arrowImgView)
        arrowImgView.snp.makeConstraints {
            $0.leading.equalTo(moveChargingHelpGuideLbl.snp.trailing)
            $0.width.height.equalTo(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
        
        let moveChargingHelpBtn = UIButton()
        
        moveChargingHelpGuideTotalView.addSubview(moveChargingHelpBtn)
        moveChargingHelpBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        moveChargingHelpBtn.rx.tap
            .asDriver()
            .drive(onNext: {
                let viewcon = ChargingGuideWebViewController()                
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
            })
            .disposed(by: self.disposebag)
        
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

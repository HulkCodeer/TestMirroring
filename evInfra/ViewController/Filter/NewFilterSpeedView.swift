//
//  NewFilterSpeedView.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/10/19.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

enum Speed: CaseIterable {
    case step0
    case step50
    case step100
    case step200
    case step350
    
    internal var description: String {
        switch self {
        case .step0: return "완속"
        case .step50: return "50"
        case .step100: return "100"
        case .step200: return "200"
        case .step350: return "350"
        }
    }
}


internal final class NewFilterSpeedView: UIView {
    
    // MARK: UI
    private lazy var totalView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
    private lazy var stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 0
    }
    
    private lazy var filterTitleLbl = UILabel().then {
        $0.text = "충전속도"
        $0.font = .systemFont(ofSize: 14, weight: .bold)
        $0.textAlignment = .left
    }
    
    private lazy var speedLbl = UILabel().then {
        $0.textColor = Colors.gr6.color
        $0.font = .systemFont(ofSize: 14)
        $0.textAlignment = .right
    }
    
    private lazy var rangeSlider = RangeSeekSlider().then {
        $0.step = 1
        $0.minValue = 1
        $0.maxValue = 5
        $0.lineHeight = 4
        $0.hideLabels = true
        $0.selectedMinValue = CGFloat(FilterManager.sharedInstance.filter.minSpeed)
        $0.selectedMaxValue = CGFloat(FilterManager.sharedInstance.filter.maxSpeed)
        $0.handleImage = Icons.iconProgressBtn.image
        $0.handleShadowOpacity = 0.15
        $0.handleShadowColor = Colors.backgroundAlwaysDark.color
        $0.handleShadowOffset = CGSize(width: 0, height: 2)
        $0.selectedHandleDiameterMultiplier = 1.0
        $0.colorBetweenHandles = Colors.contentPositive.color
        $0.initialColor = Colors.backgroundTertiary.color
        $0.minLabelColor = Colors.contentTertiary.color
        $0.maxLabelColor = Colors.contentTertiary.color
        $0.enableStep = true
        $0.disableRange = false
    }
    
    private lazy var stepHorizontalStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 45
    }
    
    // MARK: VARIABLES
    private var disposeBag = DisposeBag()
    private var speeds: [CGFloat: String] = [1: "완속",
                                             2: "50",
                                             3: "100",
                                             4: "200",
                                             5: "300"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: FUNC
    internal func bind(reactor: MainReactor) {
        self.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        totalView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.height.equalTo(32)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        stackView.addArrangedSubview(filterTitleLbl)
        stackView.addArrangedSubview(speedLbl)
        
        totalView.addSubview(rangeSlider)
        rangeSlider.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(34)
            $0.trailing.equalToSuperview().offset(-34)
            $0.height.equalTo(48)
        }
        
        totalView.addSubview(stepHorizontalStackView)
        stepHorizontalStackView.snp.makeConstraints {
            $0.top.equalTo(rangeSlider.snp.bottom)
            $0.leading.equalTo(totalView.snp.leading).offset(34)
            $0.trailing.equalTo(totalView.snp.trailing).offset(-34)
            $0.bottom.equalTo(totalView.snp.bottom)
            $0.height.equalTo(32)
        }
        
        for step in Speed.allCases {
            let stepView = createStepView(step: step.description)
            stepView.snp.makeConstraints {
                $0.width.equalTo(28)
                $0.height.equalTo(32)
            }
            stepHorizontalStackView.addArrangedSubview(stepView)
        }
    }
    
    private func createStepView(step: String) -> UIView {
        let stepView = UIView().then {
            $0.backgroundColor = Colors.borderOpaque.color
        }
        
        let stepLbl = UILabel().then {
            $0.text = step
            $0.textColor = Colors.contentTertiary.color
            $0.font = .systemFont(ofSize: 14)
            $0.textAlignment = .center
        }
        
        let stepTotalView = UIView().then {
            $0.addSubview(stepView)
            stepView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.width.equalTo(1)
                $0.height.equalTo(6)
                $0.centerX.equalToSuperview()
            }
            
            $0.addSubview(stepLbl)
            stepLbl.snp.makeConstraints {
                $0.top.equalTo(stepView.snp.bottom).offset(4)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        }
        
        return stepTotalView
    }
}

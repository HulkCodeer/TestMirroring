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

enum Speed: CGFloat, CaseIterable {
    case step0 = 1
    case step50 = 2
    case step100 = 3
    case step200 = 4
    case step350 = 5
    
    internal var description: String {
        switch self {
        case .step0: return "완속"
        case .step50: return "50"
        case .step100: return "100"
        case .step200: return "200"
        case .step350: return "350"
        }
    }
    
    internal static func convertToCGFloat(with value: Int) -> Speed {
        switch value {
        case 0: return .step0
        case 50: return .step50
        case 100: return .step100
        case 200: return .step200
        case 350: return .step350
        default: return .step0
        }
    }
    
    internal static func convertToSpeed(with value: Int) -> Int {
        switch value {
        case 1: return 0
        case 2: return 50
        case 3: return 100
        case 4: return 200
        case 5: return 350
        default: return 0
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
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textAlignment = .left
    }
    
    private lazy var speedLbl = UILabel().then {
        $0.text = "완속 ~ 200kW"
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
        $0.handleImage = Icons.iconProgressBtn.image
        $0.handleShadowOpacity = 0.15
        $0.handleShadowColor = Colors.backgroundAlwaysDark.color
        $0.handleShadowOffset = CGSize(width: 0, height: 2)
        $0.selectedHandleDiameterMultiplier = 1.0
        $0.colorBetweenHandles = Colors.contentPositive.color
        $0.initialColor = Colors.backgroundTertiary.color
        $0.tintColor = Colors.backgroundTertiary.color
        $0.minLabelColor = Colors.contentTertiary.color
        $0.maxLabelColor = Colors.contentTertiary.color
        $0.enableStep = true
        $0.disableRange = false
        $0.delegate = self
    }
    
    private lazy var stepHorizontalStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 45
    }
    
    // MARK: VARIABLES
    private var disposeBag = DisposeBag()
    private weak var mainReactor: MainReactor?
    internal var saveOnChange: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: FUNC
    internal func bind(reactor: MainReactor) {
        self.mainReactor = reactor
        
        self.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        totalView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.height.equalTo(20)
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
            $0.bottom.equalTo(totalView.snp.bottom).offset(-16)
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
        
        let cancelGesture = UIPanGestureRecognizer(target: nil, action: nil)
        cancelGesture.cancelsTouchesInView = false
        self.rangeSlider.addGestureRecognizer(cancelGesture)
        
        let minSpeed: Int = FilterManager.sharedInstance.filter.minSpeed
        let maxSpeed: Int = FilterManager.sharedInstance.filter.maxSpeed
        
        rangeSlider.selectedMinValue = Speed.convertToCGFloat(with: minSpeed).rawValue
        rangeSlider.selectedMaxValue = Speed.convertToCGFloat(with: maxSpeed).rawValue
        
        reactor.state.compactMap { $0.selectedSpeedFilter }
            .asDriver(onErrorJustReturn: MainReactor.SelectedSpeedFilter(minSpeed: 0, maxSpeed: 0))
            .drive(with: self) { obj, selectedSpeedFilter in
                let minSpeed = selectedSpeedFilter.minSpeed
                let maxSpeed = selectedSpeedFilter.maxSpeed
                
                obj.rangeSlider.selectedMinValue = Speed.convertToCGFloat(with: minSpeed).rawValue
                obj.rangeSlider.selectedMaxValue = Speed.convertToCGFloat(with: maxSpeed).rawValue
                
                FilterManager.sharedInstance.saveSpeedFilter(min: minSpeed, max: maxSpeed)
            }
            .disposed(by: self.disposeBag)
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

// MARK: RangeSeekSlider Delegate
extension NewFilterSpeedView: RangeSeekSliderDelegate {
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        guard let _reactor = mainReactor else { return }
        
        let minSpeed = Speed.convertToSpeed(with: Int(minValue))
        let maxSpeed = Speed.convertToSpeed(with: Int(maxValue))
        
        Observable.just(MainReactor.Action.setSelectedSpeedFilter((minSpeed: minSpeed, maxSpeed: maxSpeed)))
            .bind(to: _reactor.action)
            .disposed(by: self.disposeBag)
        
        speedLbl.text = FilterManager.sharedInstance.speedTitle()
    }
}

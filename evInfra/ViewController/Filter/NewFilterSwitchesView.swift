//
//  NewFilterSwitchesView.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/10/24.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

internal final class NewFilterSwitchesView: UIView {
    enum SwitchType: String, CaseIterable {
        case evpay = "EV Pay 가능한 충전소만 보기"
        case favorite = "즐겨찾는 충전소만 보기"
        case representCar = "대표차량에 맞는 충전기 타입 적용"
            
        internal var subTitle: String {
            switch self {
            case .evpay: return ""
            case .favorite: return ""
            case .representCar: return ""
            }
        }
    }
    // MARK: UI
    private lazy var verticalStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 0
    }
    
    // MARK: VARIABLES
    private weak var mainReactor: MainReactor?
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func bind(reactor: MainReactor) {
        self.addSubview(verticalStackView)
        verticalStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(168)
        }

        for switchType in SwitchType.allCases {
            let view = self.createSwitchViews(switchType: switchType, reactor: reactor)
            verticalStackView.addArrangedSubview(view)
            view.snp.makeConstraints {
                $0.height.equalTo(56)
            }
        }
    }
    
    private func createSwitchViews(switchType: SwitchType, reactor: MainReactor) -> UIView {
        let view = UIView()
        
        let stackView = UIStackView().then {
            $0.axis = .vertical
            $0.distribution = .equalSpacing
            $0.alignment = .fill
            $0.spacing = 0
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        let mainTitleLbl = UILabel().then {
            switch switchType {
            case .evpay:
                let payImage = Icons.iconElectricFillXs.image

                let attriubutedString = NSMutableAttributedString(string: "")
                let imageAttachment = NSTextAttachment(image: payImage)
                let font = UIFont(name: "Exo-SemiBoldItalic", size: 16) ?? .systemFont(ofSize: 16)
                imageAttachment.bounds = CGRect(x: 0, y: -3, width: 16, height: 16)
                
                attriubutedString.append(NSAttributedString(attachment: imageAttachment))
                attriubutedString.append(NSAttributedString(string: switchType.rawValue))
                attriubutedString.addAttribute(.font, value: font, range: (switchType.rawValue as NSString).range(of: "EV Pay "))
                $0.attributedText = attriubutedString
                $0.sizeToFit()
                $0.numberOfLines = 1
                $0.textColor = Colors.contentPrimary.color
            default:
                $0.text = switchType.rawValue
                $0.numberOfLines = 1
                $0.font = .systemFont(ofSize: 16, weight: .regular)
                $0.textColor = Colors.contentPrimary.color
            }
        }
        
        stackView.addArrangedSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.height.equalTo(24)
        }
        
        let subTitleLbl = UILabel().then {
            $0.text = switchType.subTitle
            $0.textAlignment = .natural
            $0.numberOfLines = 2
            $0.font = .systemFont(ofSize: 12, weight: .regular)
            $0.textColor = Colors.contentTertiary.color
        }
        
        if !switchType.subTitle.isEmpty {
            stackView.addArrangedSubview(subTitleLbl)
            subTitleLbl.snp.makeConstraints {
                $0.height.equalTo(18)
            }
        }
        
        let switchView = UISwitch().then {
            $0.tintColor = Colors.backgroundTertiary.color
            $0.thumbTintColor = .white
            $0.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            $0.onTintColor = Colors.backgroundPositive.color
        }
        
        view.addSubview(switchView)
        switchView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(view.snp.trailing).offset(-21)
            $0.leading.greaterThanOrEqualTo(stackView.snp.trailing).offset(30)
        }
        
        let isOn: Bool
        switch switchType {
        case .evpay:
            isOn = reactor.currentState.isEvPayFilter ?? false
            
            switchView.rx.isOn
                .changed
                .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
                .distinctUntilChanged()
                .asDriver(onErrorJustReturn: false)
                .drive(with: self) { obj, isOn in
                    Observable.just(MainReactor.Action.setEvPayFilter(isOn))
                        .bind(to: reactor.action)
                        .disposed(by: obj.disposeBag)
                }.disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.isEvPayFilter }
                .bind(to: switchView.rx.isOn)
                .disposed(by: self.disposeBag)
        case .favorite:
            isOn = reactor.currentState.isFavoriteFilter ?? false
            
            switchView.rx.isOn
                .changed
                .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
                .distinctUntilChanged()
                .asDriver(onErrorJustReturn: false)
                .drive(with: self) { obj, isOn in
                    Observable.just(MainReactor.Action.setFavoriteFilter(isOn))
                        .bind(to: reactor.action)
                        .disposed(by: obj.disposeBag)
                }.disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.isFavoriteFilter }
                .bind(to: switchView.rx.isOn)
                .disposed(by: self.disposeBag)
        case .representCar:
            isOn = reactor.currentState.isRepresentCarFilter ?? false
            
            switchView.rx.isOn
                .changed
                .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
                .distinctUntilChanged()
                .asDriver(onErrorJustReturn: false)
                .drive(with: self) { obj, isOn in
                    Observable.just(MainReactor.Action.setRepresentCarFilter(isOn))
                        .bind(to: reactor.action)
                        .disposed(by: obj.disposeBag)
                }.disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.isRepresentCarFilter }
                .bind(to: switchView.rx.isOn)
                .disposed(by: self.disposeBag)
        }
        
        switchView.isOn = isOn
        
        return view
    }
}

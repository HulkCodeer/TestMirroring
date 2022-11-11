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
    private weak var filterReactor: GlobalFilterReactor?
    private var disposeBag = DisposeBag()
    internal weak var delegate: NewDelegateFilterChange?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func bind(reactor: GlobalFilterReactor) {
        self.filterReactor = reactor
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
    
    private func createSwitchViews(switchType: SwitchType, reactor: GlobalFilterReactor) -> UIView {
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
        
        switch switchType {
        case .evpay:
            switchView.rx.isOn
                .changed
                .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
                .distinctUntilChanged()
                .asDriver(onErrorJustReturn: false)
                .drive(with: self) { obj, isOn in
                    let setEvPayFilterStream = Observable.of(GlobalFilterReactor.Action.setEvPayFilter(isOn))
                    let loadCompaniesStream = Observable.of(GlobalFilterReactor.Action.loadCompanies)
                    
                    Observable.concat([setEvPayFilterStream, loadCompaniesStream])
                        .bind(to: GlobalFilterReactor.sharedInstance.action)
                        .disposed(by: obj.disposeBag)
                    
                    obj.delegate?.changedFilter()
                }.disposed(by: self.disposeBag)
            
            GlobalFilterReactor.sharedInstance.state.compactMap { $0.isEvPayFilter }
                .bind(to: switchView.rx.isOn)
                .disposed(by: self.disposeBag)

        case .favorite:
            
            Observable.just(GlobalFilterReactor.Action.numberOfFavorits)
                .bind(to: GlobalFilterReactor.sharedInstance.action)
                .disposed(by: self.disposeBag)
            
            switchView.rx.isOn
                .changed
                .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
                .asDriver(onErrorJustReturn: false)
                .drive(with: self) { obj, isOn in
                    if isOn {
                        MemberManager.shared.tryToLoginCheck { isLogin in
                            guard isLogin else {
                                MemberManager.shared.showLoginAlert()
                                Observable.just(GlobalFilterReactor.Action.setFavoriteFilter(false))
                                    .bind(to: GlobalFilterReactor.sharedInstance.action)
                                    .disposed(by: obj.disposeBag)
                                Observable.just(GlobalFilterReactor.Action.saveFavoriteFilter(false))
                                    .bind(to: GlobalFilterReactor.sharedInstance.action)
                                    .disposed(by: obj.disposeBag)
                                return
                            }
                            
                            let numberOfFavorites = GlobalFilterReactor.sharedInstance.currentState.numberOfFavorites ?? 0
                            if numberOfFavorites == 0 {
                                // TODO: 토스트 - 해당 필터를 사용하려면 즐겨찾는 충전소를 등록해 보세요.
                                printLog(out: "TOAST :: 해당 필터를 사용하려면 즐겨찾는 충전소를 등록해 보세요.")
                                Observable.just(GlobalFilterReactor.Action.setFavoriteFilter(false))
                                    .bind(to: GlobalFilterReactor.sharedInstance.action)
                                    .disposed(by: obj.disposeBag)
                            } else {
                                Observable.just(GlobalFilterReactor.Action.setFavoriteFilter(true))
                                    .bind(to: GlobalFilterReactor.sharedInstance.action)
                                    .disposed(by: obj.disposeBag)
                                obj.delegate?.changedFilter()
                            }
                        }
                    } else {
                        Observable.just(GlobalFilterReactor.Action.setFavoriteFilter(false))
                            .bind(to: GlobalFilterReactor.sharedInstance.action)
                            .disposed(by: obj.disposeBag)
                        obj.delegate?.changedFilter()
                    }
                }.disposed(by: self.disposeBag)
            
            GlobalFilterReactor.sharedInstance.state.compactMap { $0.isFavoriteFilter }
                .asDriver(onErrorJustReturn: false)
                .drive(with: self) { obj, isFavoriteFilter in
                    MemberManager.shared.tryToLoginCheck { isLogin in
                        guard isLogin else {
                            switchView.isOn = false
                            return
                        }
                        switchView.isOn = isFavoriteFilter
                    }
                }.disposed(by: self.disposeBag)

        case .representCar:
            
            switchView.rx.isOn
                .changed
                .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
                .asDriver(onErrorJustReturn: false)
                .drive(with: self) { obj, isOn in
                    if isOn {
                        MemberManager.shared.tryToLoginCheck { isLogin in
                            guard isLogin else {
                                MemberManager.shared.showLoginAlert()
                                Observable.just(GlobalFilterReactor.Action.setRepresentCarFilter(false))
                                    .bind(to: GlobalFilterReactor.sharedInstance.action)
                                    .disposed(by: obj.disposeBag)
                                Observable.just(GlobalFilterReactor.Action.saveRepresentCarFilter(false))
                                    .bind(to: GlobalFilterReactor.sharedInstance.action)
                                    .disposed(by: obj.disposeBag)
                                return
                            }
                            
                            let hasMyCar: Bool = UserDefault().readInt(key: UserDefault.Key.MB_CAR_ID) != 0
                            guard hasMyCar else {
                                // TODO: 토스트 - 해당 필터를 사용하려면 마이페이지\n> 개인정보 관리에서 대표차량을 등록해 보세요.
                                printLog(out: "토스트 - 해당 필터를 사용하려면 마이페이지\n> 개인정보 관리에서 대표차량을 등록해 보세요.")
                                return
                            }
                            
                            Observable.just(GlobalFilterReactor.Action.setRepresentCarFilter(true))
                                .bind(to: GlobalFilterReactor.sharedInstance.action)
                                .disposed(by: obj.disposeBag)
                            
                            Observable.just(GlobalFilterReactor.Action.loadChargerTypes)
                                .bind(to: GlobalFilterReactor.sharedInstance.action)
                                .disposed(by: self.disposeBag)
                            
                            obj.delegate?.changedFilter()
                        }
                    } else {
                        Observable.just(GlobalFilterReactor.Action.setRepresentCarFilter(false))
                            .bind(to: GlobalFilterReactor.sharedInstance.action)
                            .disposed(by: obj.disposeBag)
                        
                        Observable.just(GlobalFilterReactor.Action.loadChargerTypes)
                            .bind(to: GlobalFilterReactor.sharedInstance.action)
                            .disposed(by: self.disposeBag)
                        
                        obj.delegate?.changedFilter()
                    }
                }.disposed(by: self.disposeBag)
            
            GlobalFilterReactor.sharedInstance.state.compactMap { $0.isRepresentCarFilter }
                .asDriver(onErrorJustReturn: false)
                .drive(with: self) { obj, isRepresentCarFilter in
                    MemberManager.shared.tryToLoginCheck { isLogin in
                        guard isLogin else {
                            switchView.isOn = false
                            return
                        }
                        switchView.isOn = isRepresentCarFilter
                    }
                }.disposed(by: self.disposeBag)
        }
        
        return view
    }
    
    internal func shouldChange() -> Bool {
        let isEvPayFilter = GlobalFilterReactor.sharedInstance.currentState.isEvPayFilter
        let isFavoriteFilter = GlobalFilterReactor.sharedInstance.currentState.isFavoriteFilter
        let isRepresentCarFilter = GlobalFilterReactor.sharedInstance.currentState.isRepresentCarFilter
        
        return isEvPayFilter != FilterManager.sharedInstance.filter.isMembershipCardChecked || isFavoriteFilter != FilterManager.sharedInstance.filter.isFavoriteChecked || isRepresentCarFilter != FilterManager.sharedInstance.filter.isRepresentCarChecked
    }
}

extension NewFilterSwitchesView: FilterButtonAction {
    func saveFilter() {
        let isEvPayFilter = GlobalFilterReactor.sharedInstance.currentState.isEvPayFilter ?? false
        let isFavoriteFilter = GlobalFilterReactor.sharedInstance.currentState.isFavoriteFilter ?? false
        let isRepresentCarFilter = GlobalFilterReactor.sharedInstance.currentState.isRepresentCarFilter ?? false

        let saveEvPayFilterStream = Observable.of(GlobalFilterReactor.Action.saveEvPayFilter(isEvPayFilter))
        let saveFavoriteFilterStream = Observable.of(GlobalFilterReactor.Action.saveFavoriteFilter(isFavoriteFilter))
        let saveRepresentCarFilterStream = Observable.of(GlobalFilterReactor.Action.saveRepresentCarFilter(isRepresentCarFilter))
        
        Observable.concat([saveEvPayFilterStream, saveFavoriteFilterStream, saveRepresentCarFilterStream])
            .bind(to: GlobalFilterReactor.sharedInstance.action)
            .disposed(by: self.disposeBag)
    }
    
    func resetFilter() {
        let resetEvPayFilterStream = Observable.of(GlobalFilterReactor.Action.setEvPayFilter(false))
        let resetFavoriteFilterStream = Observable.of(GlobalFilterReactor.Action.setFavoriteFilter(false))
        let resetRepresentCarFilterStream = Observable.of(GlobalFilterReactor.Action.setRepresentCarFilter(false))
        
        Observable.concat([resetEvPayFilterStream, resetFavoriteFilterStream, resetRepresentCarFilterStream])
            .bind(to: GlobalFilterReactor.sharedInstance.action)
            .disposed(by: self.disposeBag)
    }
    
    func revertFilter() {
        let revertIsEvPayFilter = Observable.of(GlobalFilterReactor.Action.setEvPayFilter(FilterManager.sharedInstance.filter.isMembershipCardChecked))
        let revertIsFavoriteFilter = Observable.of(GlobalFilterReactor.Action.setFavoriteFilter(FilterManager.sharedInstance.filter.isFavoriteChecked))
        let revertIsRepresentCarFilter = Observable.of(GlobalFilterReactor.Action.setRepresentCarFilter(FilterManager.sharedInstance.filter.isRepresentCarChecked))
        
        Observable.concat([revertIsEvPayFilter, revertIsFavoriteFilter, revertIsRepresentCarFilter])
            .bind(to: GlobalFilterReactor.sharedInstance.action)
            .disposed(by: self.disposeBag)
    }
}

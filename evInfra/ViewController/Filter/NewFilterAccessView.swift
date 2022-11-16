//
//  NewFilterAccessView.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/10/25.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import EasyTipView

internal final class NewFilterAccessView: CommonFilterView {
    // MARK: UI
    
    private lazy var filterTitleLbl = UILabel().then {
        $0.text = "접근"
        $0.font = .systemFont(ofSize: 14, weight: .bold)
    }
    
    private lazy var infoBtn = UIButton().then {
        $0.setImage(Icons.iconInfoSm.image, for: .normal)
        $0.tintColor = Colors.contentTertiary.color
    }
    
    private lazy var stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 0
    }
  
    // MARK: VARIABLES
    private var disposeBag = DisposeBag()
    internal weak var delegate: NewDelegateFilterChange?
    internal var isDirectChange: Bool = false
    
    // MARK: FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func makeUI() {
        self.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(138)
        }
        
        totalView.addSubview(filterTitleLbl)
        filterTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(16)
        }
        
        totalView.addSubview(infoBtn)
        infoBtn.snp.makeConstraints {
            $0.leading.equalTo(filterTitleLbl.snp.trailing).offset(12)
            $0.centerY.equalTo(filterTitleLbl.snp.centerY)
            $0.width.height.equalTo(20)
        }
        
        totalView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(filterTitleLbl.snp.bottom).offset(16).priority(.low)
            $0.leading.equalTo(totalView.snp.leading).offset(16)
            $0.trailing.equalTo(totalView.snp.trailing).offset(-16)
            $0.bottom.equalTo(totalView.snp.bottom).offset(-20)
            $0.height.equalTo(68)
        }
    }
    
    func bind(reactor: FilterReactor) {
        for accessFilter in reactor.currentState.tempFilterModel.accessibilityFilters {
            let filterTypeView = self.createCommonFilterTypeView(accessFilter, reactor: reactor)
            stackView.addArrangedSubview(filterTypeView.totalView)

            filterTypeView.btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    var accessFilter = accessFilter
                    filterTypeView.btn.isSelected = !filterTypeView.btn.isSelected
                    accessFilter.isSelected = filterTypeView.btn.isSelected
                    Observable.just(FilterReactor.Action.setAcessTypeFilter(accessFilter))
                        .bind(to: reactor.action)
                        .disposed(by: self.disposeBag)
                }
                .disposed(by: self.disposeBag)

            reactor.state.compactMap { $0.filterType }
                .filter { $0.isEqual(accessFilter) }
                .asDriver(onErrorJustReturn: PublicFilter(isSelected: true))
                .drive(with: self) { obj, type in
                    filterTypeView.imgView.tintColor = type.displayImageColor
                }.disposed(by: self.disposeBag)
        }
        
        infoBtn.rx.tap
            .asDriver()
            .drive(with: self) { obj, _ in
                obj.infoBtn.isSelected = !obj.infoBtn.isSelected
                guard !obj.infoBtn.isSelected else { return }
                
                var preferences = EasyTipView.Preferences()
                preferences.drawing.backgroundColor = Colors.contentSecondary.color
                preferences.drawing.foregroundColor = Colors.backgroundSecondary.color
                preferences.drawing.textAlignment = .center
                
                preferences.drawing.arrowPosition = .left
                
                preferences.animating.dismissTransform = CGAffineTransform(translationX: -30, y: -100)
                preferences.animating.showInitialTransform = CGAffineTransform(translationX: 30, y: 100)
                preferences.animating.showInitialAlpha = 0
                preferences.animating.showDuration = 1
                preferences.animating.dismissDuration = 1
                
                let text = "비개방충전소: 충전소 설치 건물 거주/이용/관계자 외엔 사용이 불가한 곳"
                EasyTipView.show(forView: obj.infoBtn,
                                 withinSuperview: obj,
                                 text: text,
                                 preferences: preferences)
            }.disposed(by: self.disposeBag)
    }
            
//    internal func shouldChanged() -> Bool {
//        let isPublic = reactor.currentState.isPublic
//        let isNonPublic = reactor.currentState.isNonPublic
//
//        return (isPublic != FilterManager.sharedInstance.filter.isPublic)
//        || (isNonPublic != FilterManager.sharedInstance.filter.isNonPublic)
//    }
}

extension NewFilterAccessView: FilterButtonAction {
    func saveFilter() {
//        let filterModel = reactor.currentState.filterModel
//        Observable.of(FilterReactor.Action.saveFilter(filterModel))
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
    }
    
    func resetFilter() {
//        let resetModel = reactor.initialState.resetFilterModel
//        Observable.just(FilterReactor.Action.savePlaceFilter(resetModel))
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
    }
    
    func revertFilter() {
//        let revertPublicChargerStream = Observable.of(FilterReactor.Action.changedAccessFilter((.publicCharger, FilterManager.sharedInstance.filter.isPublic)))
//        let revertNonPublicChargerStream = Observable.of(FilterReactor.Action.changedAccessFilter((.nonePublicCharger, FilterManager.sharedInstance.filter.isNonPublic)))
//
//        Observable.concat([revertPublicChargerStream, revertNonPublicChargerStream])
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
    }
}

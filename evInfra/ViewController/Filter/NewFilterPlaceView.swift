//
//  NewFilterPlaceView.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/10/17.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

internal final class NewFilterPlaceView: UIView {
    
    // MARK: UI
    
    private lazy var totalView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
    private lazy var filterTitleLbl = UILabel().then {
        $0.text = "설치형태"
        $0.font = .systemFont(ofSize: 14, weight: .bold)
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
    
    // MARK: FUNC
    internal func bind(reactor: FilterReactor) {
        self.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(138)
        }
        
        totalView.addSubview(filterTitleLbl)
        filterTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(16)
        }
        
        totalView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(filterTitleLbl.snp.bottom).offset(16).priority(.low)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-20)
            $0.height.equalTo(68)
        }
        
        for placeType in PlaceType.allCases {
            stackView.addArrangedSubview(self.createPlaceTypeView(placeType, reactor: reactor))
        }
    }
    
    private func createPlaceTypeView(_ placeType: PlaceType, reactor: FilterReactor) -> UIView {
        let typeImageProperty = placeType.typeImageProperty ?? (image: nil, imgUnSelectColor: nil, imgSelectColor: nil)
        let imgView = UIImageView().then {
            $0.image = typeImageProperty.image
            $0.tintColor = typeImageProperty.imgUnSelectColor
        }
        
        let titleLbl = UILabel().then {
            $0.text = placeType.typeTitle
            $0.font = .systemFont(ofSize: 14)
        }
        
        let btn = UIButton().then {
            $0.isSelected = false
        }
        
        let view = UIView().then {
            $0.addSubview(imgView)
            imgView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.centerX.equalToSuperview()
                $0.width.height.equalTo(48)
            }
            
            $0.addSubview(titleLbl)
            titleLbl.snp.makeConstraints {
                $0.top.equalTo(imgView.snp.bottom).offset(4)
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.height.equalTo(16)
            }

            $0.addSubview(btn)
            btn.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }

        let isIndoor = reactor.currentState.filterModel.isIndoor
        let isOutdoor = reactor.currentState.filterModel.isOutdoor
        let isCanopy = reactor.currentState.filterModel.isCanopy
        
        switch placeType {
        case .indoor:
            imgView.tintColor = isIndoor ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            titleLbl.textColor = isIndoor ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            
            btn.isSelected = isIndoor
            
            btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    btn.isSelected = !btn.isSelected

                    Observable.just(FilterReactor.Action.updateIndoorPlaceFilter(btn.isSelected))
                        .bind(to: reactor.action)
                        .disposed(by: obj.disposeBag)
                    
                    if obj.isDirectChange {
                        obj.saveFilter()
                    }
                    
                    Observable.just(FilterReactor.Action.shouldChanged)
                        .bind(to: reactor.action)
                        .disposed(by: obj.disposeBag)
                }
                .disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.filterModel.isIndoor }
                .asDriver(onErrorJustReturn: false)
                .drive(with: self) { obj, isSelected in
                    btn.isSelected = isSelected
                    imgView.tintColor = isSelected ? placeType.typeImageProperty?.imgSelectColor : placeType.typeImageProperty?.imgUnSelectColor
                    titleLbl.textColor = isSelected ? placeType.typeImageProperty?.imgSelectColor : placeType.typeImageProperty?.imgUnSelectColor
                }.disposed(by: self.disposeBag)
            
        case .outdoor:
            imgView.tintColor = isOutdoor ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            titleLbl.textColor = isOutdoor ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            
            btn.isSelected = isOutdoor
            
            btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    btn.isSelected = !btn.isSelected

                    Observable.just(FilterReactor.Action.updateOutdoorPlaceFilter(btn.isSelected))
                        .bind(to: reactor.action)
                        .disposed(by: obj.disposeBag)
                    
                    if obj.isDirectChange {
                        obj.saveFilter()
                    }
                    
                    Observable.just(FilterReactor.Action.shouldChanged)
                        .bind(to: reactor.action)
                        .disposed(by: obj.disposeBag)
                    
                }
                .disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.filterModel.isOutdoor }
                .asDriver(onErrorJustReturn: false)
                .drive(with: self) { obj, isSelected in
                    btn.isSelected = isSelected
                    imgView.tintColor = isSelected ? placeType.typeImageProperty?.imgSelectColor : placeType.typeImageProperty?.imgUnSelectColor
                    titleLbl.textColor = isSelected ? placeType.typeImageProperty?.imgSelectColor : placeType.typeImageProperty?.imgUnSelectColor
                }.disposed(by: self.disposeBag)
        case .canopy:
            imgView.tintColor = isCanopy ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            titleLbl.textColor = isCanopy ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            
            btn.isSelected = isCanopy
            
            btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    btn.isSelected = !btn.isSelected

                    Observable.just(FilterReactor.Action.updateCanopyPlaceFilter(btn.isSelected))
                        .bind(to: reactor.action)
                        .disposed(by: obj.disposeBag)
                    
                    if obj.isDirectChange {
                        obj.saveFilter()
                    }
                    
                    Observable.just(FilterReactor.Action.shouldChanged)
                        .bind(to: reactor.action)
                        .disposed(by: obj.disposeBag)
                }
                .disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.filterModel.isCanopy }
                .asDriver(onErrorJustReturn: false)
                .drive(with: self) { obj, isSelected in
                    btn.isSelected = isSelected
                    imgView.tintColor = isSelected ? placeType.typeImageProperty?.imgSelectColor : placeType.typeImageProperty?.imgUnSelectColor
                    titleLbl.textColor = isSelected ? placeType.typeImageProperty?.imgSelectColor : placeType.typeImageProperty?.imgUnSelectColor
                }.disposed(by: self.disposeBag)
        }
        
        return view
    }
    
    private func logEvent() {
        var values: [String] = [String]()
        if FilterManager.sharedInstance.filter.isIndoor {
            values.append(PlaceType.indoor.typeTitle)
        }
        if FilterManager.sharedInstance.filter.isOutdoor {
            values.append(PlaceType.outdoor.typeTitle)
        }
        if FilterManager.sharedInstance.filter.isCanopy {
            values.append(PlaceType.canopy.typeTitle)
        }
        
        let property: [String: Any] = ["filterName": "설치 형태",
                                       "filterValue": values]
        FilterEvent.clickUpperFilter.logEvent(property: property)
    }
    
    internal func shouldChanged() -> Bool {
//        let isIndoor = reactor.currentState.isIndoor
//        let isOutdoor = reactor.currentState.isOutdoor
//        let isCanopy = reactor.currentState.isCanopy
//
//        return (isIndoor != FilterManager.sharedInstance.filter.isIndoor)
//        || (isOutdoor != FilterManager.sharedInstance.filter.isOutdoor)
//        || (isCanopy != FilterManager.sharedInstance.filter.isCanopy)
        return true
    }
}

extension NewFilterPlaceView: FilterButtonAction {
    func saveFilter() {
//        let filterModel = reactor.currentState.filterModel
//        Observable.just(FilterReactor.Action.savePlaceFilter(filterModel))
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
        // TODO: original이랑 비교
//        let currentFilterModel = reactor.currentState.filterModel
//        let originalFilterModel = reactor.initialState.filterModel
//        Observable.just(FilterReactor.Action.savePlaceFilter(originalFilterModel))
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
    }
}

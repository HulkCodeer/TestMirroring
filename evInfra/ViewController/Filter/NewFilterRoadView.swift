//
//  NewFilterRoadView.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/10/18.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import SnapKit
import Then

internal final class NewFilterRoadView: CommonFilterView {
    
    // MARK: UI

    private lazy var filterTitleLbl = UILabel().then {
        $0.text = "도로"
        $0.font = .systemFont(ofSize: 14, weight: .bold)
    }
    
    private lazy var stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 0
    }
  
    // MARK: VARIABLES
    var disposeBag = DisposeBag()
    internal weak var delegate: NewDelegateFilterChange?
    
    // MARK: FUNC
    
    override func makeUI() {
        self.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
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
            $0.leading.equalTo(totalView.snp.leading).offset(16)
            $0.trailing.equalTo(totalView.snp.trailing).offset(-16)
            $0.bottom.equalTo(totalView.snp.bottom).offset(-20)
            $0.height.equalTo(68)
        }
    }
    
    func bind(reactor: FilterReactor) {                
        for roadFilter in reactor.currentState.tempFilterModel.roadFilters {
            let filterTypeView = self.createCommonFilterTypeView(roadFilter, reactor: reactor)
            stackView.addArrangedSubview(filterTypeView.totalView)
            
            filterTypeView.btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    var roadFilter = roadFilter
                    filterTypeView.btn.isSelected = !filterTypeView.btn.isSelected
                    roadFilter.isSelected = filterTypeView.btn.isSelected
                    Observable.just(FilterReactor.Action.setAcessTypeFilter(roadFilter))
                        .bind(to: reactor.action)
                        .disposed(by: self.disposeBag)
                }
                .disposed(by: self.disposeBag)

            reactor.state.compactMap { $0.filterType }
                .debug()
                .filter { $0.isEqual(roadFilter) }
                .asDriver(onErrorJustReturn: PublicFilter(isSelected: true))
                .drive(with: self) { obj, type in
                    filterTypeView.imgView.tintColor = type.displayImageColor
                }.disposed(by: self.disposeBag)
        }
    }
           
//    private func createRoadTypeView(_ roadTypeFilter: any Filter, reactor: FilterReactor) -> UIView {
//        let typeImageProperty = roadType.typeImageProperty ?? (image: nil, imgUnSelectColor: nil, imgSelectColor: nil)
//        let imgView = UIImageView().then {
//            $0.image = typeImageProperty.image
//            $0.tintColor = typeImageProperty.imgUnSelectColor
//        }
//
//        let titleLbl = UILabel().then {
//            $0.text = roadType.typeTitle
//            $0.font = .systemFont(ofSize: 14)
//        }
//
//        let btn = UIButton().then {
//            $0.isSelected = false
//        }
//
//        let view = UIView().then {
//            $0.addSubview(imgView)
//            imgView.snp.makeConstraints {
//                $0.top.equalToSuperview()
//                $0.centerX.equalToSuperview()
//                $0.width.height.equalTo(48)
//            }
//
//            $0.addSubview(titleLbl)
//            titleLbl.snp.makeConstraints {
//                $0.top.equalTo(imgView.snp.bottom).offset(4)
//                $0.centerX.equalToSuperview()
//                $0.bottom.equalToSuperview()
//                $0.height.equalTo(16)
//            }
//
//            $0.addSubview(btn)
//            btn.snp.makeConstraints {
//                $0.edges.equalToSuperview()
//            }
//        }
//
//        let isGenral = reactor.currentState.filterModel.isGeneralRoad
//        let isHighwayUp = reactor.currentState.filterModel.isHighwayUp
//        let isHighwayDown = reactor.currentState.filterModel.isHighwayDown
//
//        btn.rx.tap
//            .asDriver()
//            .drive(with: self) { obj, _ in
//                btn.isSelected = !btn.isSelected
//
//                Observable.just(FilterReactor.Action.updateGeneralFilter(btn.isSelected))
//                    .bind(to: reactor.action)
//                    .disposed(by: obj.disposeBag)
//
//                if obj.isDirectChange {
//                    obj.saveFilter()
//                }
//
//                Observable.just(FilterReactor.Action.shouldChanged)
//                    .bind(to: reactor.action)
//                    .disposed(by: obj.disposeBag)
//            }
//            .disposed(by: self.disposeBag)
//
//        switch roadType {
//        case .general:
//            imgView.tintColor = isGenral ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
//            titleLbl.textColor = isGenral ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
//
//            btn.isSelected = isGenral
//
//            btn.rx.tap
//                .asDriver()
//                .drive(with: self) { obj, _ in
//                    btn.isSelected = !btn.isSelected
//
//                    Observable.just(FilterReactor.Action.updateGeneralFilter(btn.isSelected))
//                        .bind(to: reactor.action)
//                        .disposed(by: obj.disposeBag)
//
//                    if obj.isDirectChange {
//                        obj.saveFilter()
//                    }
//
//                    Observable.just(FilterReactor.Action.shouldChanged)
//                        .bind(to: reactor.action)
//                        .disposed(by: obj.disposeBag)
//                }
//                .disposed(by: self.disposeBag)
//
//            reactor.state.compactMap { $0.filterModel.isGeneralRoad }
//                .asDriver(onErrorJustReturn: false)
//                .drive(with: self) { obj, isSelected in
//                    btn.isSelected = isSelected
//                    imgView.tintColor = isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
//                    titleLbl.textColor = isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
//                }.disposed(by: self.disposeBag)
//
//        case .highwayUp:
//            imgView.tintColor = isHighwayUp ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
//            titleLbl.textColor = isHighwayUp ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
//
//            btn.isSelected = isHighwayUp
//
//            btn.rx.tap
//                .asDriver()
//                .drive(with: self) { obj, _ in
//                    btn.isSelected = !btn.isSelected
//                    Observable.just(FilterReactor.Action.updateHighwayUpFilter(btn.isSelected))
//                        .bind(to: reactor.action)
//                        .disposed(by: obj.disposeBag)
//
//                    if obj.isDirectChange {
//                        obj.saveFilter()
//                    }
//
//                    Observable.just(FilterReactor.Action.shouldChanged)
//                        .bind(to: reactor.action)
//                        .disposed(by: obj.disposeBag)
//                }
//                .disposed(by: self.disposeBag)
//
//            reactor.state.compactMap { $0.filterModel.isHighwayUp }
//                .asDriver(onErrorJustReturn: false)
//                .drive(with: self) { obj, isSelected in
//                    btn.isSelected = isSelected
//                    imgView.tintColor = isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
//                    titleLbl.textColor = isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
//                }.disposed(by: self.disposeBag)
//
//        case .highwayDown:
//            imgView.tintColor = isHighwayDown ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
//            titleLbl.textColor = isHighwayDown ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
//
//            btn.isSelected = isHighwayDown
//
//            btn.rx.tap
//                .asDriver()
//                .drive(with: self) { obj, _ in
//                    btn.isSelected = !btn.isSelected
//                    Observable.just(FilterReactor.Action.updateHigywayDownFilter(btn.isSelected))
//                        .bind(to: reactor.action)
//                        .disposed(by: obj.disposeBag)
//
//                    if obj.isDirectChange {
//                        obj.saveFilter()
//                    }
//
//                    Observable.just(FilterReactor.Action.shouldChanged)
//                        .bind(to: reactor.action)
//                        .disposed(by: obj.disposeBag)
//                }
//                .disposed(by: self.disposeBag)
//
//            reactor.state.compactMap { $0.filterModel.isHighwayDown }
//                .asDriver(onErrorJustReturn: false)
//                .drive(with: self) { obj, isSelected in
//                    btn.isSelected = isSelected
//                    imgView.tintColor = isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
//                    titleLbl.textColor = isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
//                }.disposed(by: self.disposeBag)
//        }
//
//        return view
//    }
    
    internal func shouldChanged() -> Bool {
//        let isGeneral = reactor.currentState.isGeneralRoad
//        let isHighwayUp = reactor.currentState.isHighwayUp
//        let isHighwayDown = reactor.currentState.isHighwayDown
//
//        return (isGeneral != FilterManager.sharedInstance.filter.isGeneralWay)
//        || (isHighwayUp != FilterManager.sharedInstance.filter.isHighwayUp)
//        || (isHighwayDown != FilterManager.sharedInstance.filter.isHighwayDown)
        return true
    }
}

extension NewFilterRoadView: FilterButtonAction {
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
//        let filterModel = reactor.initialState.filterModel
//        Observable.just(FilterReactor.Action.saveRoadFilter(filterModel))
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
    }
}

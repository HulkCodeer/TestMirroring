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

enum PlaceType: CaseIterable {
    typealias Property = (image: UIImage?, imgUnSelectColor: UIColor?, imgSelectColor: UIColor?)
    
    case indoor
    case outdoor
    case canopy
    
    internal var typeImageProperty: Property? {
        switch self {
        case .indoor:
            return (image: Icons.iconInside.image, imgUnSelectColor: Colors.contentTertiary.color, imgSelectColor: Colors.contentPositive.color)
        case .outdoor:
            return (image: Icons.iconOutside.image, imgUnSelectColor: Colors.contentTertiary.color, imgSelectColor: Colors.contentPositive.color)
        case .canopy:
            return (image: Icons.iconCanopy.image, imgUnSelectColor: Colors.contentTertiary.color, imgSelectColor: Colors.contentPositive.color)
        }
    }
    
    internal var typeTitle: String {
        switch self {
        case .indoor: return "실내"
        case .outdoor: return "실외"
        case .canopy: return "캐노피"
        }
    }
}

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
    internal weak var delegate: DelegateFilterChange?
    internal var saveOnChange: Bool = false

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
    internal func bind(reactor: MainReactor) {
        self.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(128)
        }
        
        totalView.addSubview(filterTitleLbl)
        filterTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(16)
        }
        
        totalView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(filterTitleLbl.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-20)
            $0.height.equalTo(68)
        }
        
        for placeType in PlaceType.allCases {
            stackView.addArrangedSubview(self.createPlaceTypeView(placeType, reactor: reactor))
        }
    }
    
    private func createPlaceTypeView(_ placeType: PlaceType, reactor: MainReactor) -> UIView {
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
        
        let isSelectedIndoor = FilterManager.sharedInstance.filter.isIndoor
        let isSelectedOutdoor = FilterManager.sharedInstance.filter.isOutdoor
        let isSelectedCanopy = FilterManager.sharedInstance.filter.isCanopy
        
        switch placeType {
        case .indoor:
            imgView.tintColor = isSelectedIndoor ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            titleLbl.textColor = isSelectedIndoor ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            
            btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    btn.isSelected = !btn.isSelected
                    if obj.saveOnChange {
                        Observable.just(MainReactor.Action.setSelectedPlaceFilter((.indoor, btn.isSelected)))
                            .bind(to: reactor.action)
                            .disposed(by: obj.disposeBag)
                    }
                    obj.delegate?.onChangedFilter(type: .place)
                }
                .disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.selectedPlaceFilter }
                .asDriver(onErrorJustReturn: MainReactor.SelectedPlaceFilter(placeType: .indoor, isSelected: false))
                .drive(with: self) { obj, selectedPlaceFilter in
                    guard selectedPlaceFilter.placeType == .indoor else { return }
                    let isSelected = selectedPlaceFilter.isSelected
                    imgView.tintColor = isSelected ? placeType.typeImageProperty?.imgSelectColor : placeType.typeImageProperty?.imgUnSelectColor
                    titleLbl.textColor = isSelected ? placeType.typeImageProperty?.imgSelectColor : placeType.typeImageProperty?.imgUnSelectColor

                    FilterManager.sharedInstance.saveIndoor(with: isSelected)
                }
                .disposed(by: self.disposeBag)
        case .outdoor:
            imgView.tintColor = isSelectedOutdoor ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            titleLbl.textColor = isSelectedOutdoor ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            
            btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    btn.isSelected = !btn.isSelected
                    if obj.saveOnChange {
                        Observable.just(MainReactor.Action.setSelectedPlaceFilter((.outdoor, btn.isSelected)))
                            .bind(to: reactor.action)
                            .disposed(by: obj.disposeBag)
                    }
                    obj.delegate?.onChangedFilter(type: .place)
                }
                .disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.selectedPlaceFilter }
                .asDriver(onErrorJustReturn: MainReactor.SelectedPlaceFilter(placeType: .outdoor, isSelected: false))
                .drive(with: self) { obj, selectedPlaceFilter in
                    guard selectedPlaceFilter.placeType == .outdoor else { return }
                    let isSelected = selectedPlaceFilter.isSelected
                    imgView.tintColor = isSelected ? placeType.typeImageProperty?.imgSelectColor : placeType.typeImageProperty?.imgUnSelectColor
                    titleLbl.textColor = isSelected ? placeType.typeImageProperty?.imgSelectColor : placeType.typeImageProperty?.imgUnSelectColor

                    FilterManager.sharedInstance.saveOutdoor(with: isSelected)
                }
                .disposed(by: self.disposeBag)
        case .canopy:
            imgView.tintColor = isSelectedCanopy ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            titleLbl.textColor = isSelectedCanopy ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            
            btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    btn.isSelected = !btn.isSelected
                    if obj.saveOnChange {
                        Observable.just(MainReactor.Action.setSelectedPlaceFilter((.canopy, btn.isSelected)))
                            .bind(to: reactor.action)
                            .disposed(by: obj.disposeBag)
                    }
                    obj.delegate?.onChangedFilter(type: .place)
                }
                .disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.selectedPlaceFilter }
                .asDriver(onErrorJustReturn: MainReactor.SelectedPlaceFilter(placeType: .canopy, isSelected: false))
                .drive(with: self) { obj, selectedPlaceFilter in
                    guard selectedPlaceFilter.placeType == .canopy else { return }
                    let isSelected = selectedPlaceFilter.isSelected
                    imgView.tintColor = isSelected ? placeType.typeImageProperty?.imgSelectColor : placeType.typeImageProperty?.imgUnSelectColor
                    titleLbl.textColor = isSelected ? placeType.typeImageProperty?.imgSelectColor : placeType.typeImageProperty?.imgUnSelectColor

                    FilterManager.sharedInstance.saveCanopy(with: isSelected)
                }
                .disposed(by: self.disposeBag)
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
}

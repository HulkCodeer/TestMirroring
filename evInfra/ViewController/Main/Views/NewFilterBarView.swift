//
//  NewFilterBarView.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/09/29.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

enum FilterType {
    case price
    case speed
    case place
    case road
    case type
    case access
    case company
    case none
}

enum FilterTagType: CaseIterable {
    typealias Property = (imgUnSelect: UIImage?, imgSelect: UIImage?, imgUnSelectColor: UIColor?, imgSelectColor: UIColor?)
    
    // 현재 EV Pay는 따로 작동해야 하므로 주석, 추후 디자인 개편시 EV Pay 관련 주석 풀면 됨
    case evpay
    case favorite
    case speed
    case place
    case road
    case type
    
    internal func swipeLeft() -> FilterTagType {
        switch self {
        case .evpay: return .speed
        case .favorite: return .favorite
        case .speed: return .place
        case .place: return .road
        case .road: return .type
        case .type: return .type
        }
    }
    
    internal func swipeRight() -> FilterTagType {
        switch self {
        case .evpay: return .evpay
        case .favorite: return .favorite
        case .speed: return .favorite
        case .place: return .speed
        case .road: return .place
        case .type: return .road
        }
    }
    
    internal var typeImageProperty: Property? {
        switch self {
        // 나중에 이미지 있는 디자인으로 변경시 주석 푸세요
        case .evpay:
            return (imgUnSelect: Icons.iconElectricFillXs.image, imgSelect: Icons.iconElectricFillXs.image, imgUnSelectColor: Colors.contentSecondary.color, imgSelectColor : Colors.gr6.color)
        case .favorite: return (imgUnSelect: Icons.iconStarXs.image, imgSelect: Icons.iconStarFillXs.image, imgUnSelectColor: Colors.contentSecondary.color, imgSelectColor : Colors.gr6.color)
        default: return (imgUnSelect: Icons.iconChevronDownXs.image, imgSelect: Icons.iconChevronUpXs.image, imgUnSelectColor: Colors.contentTertiary.color, imgSelectColor : Colors.gr7.color)
        }
    }
    
    internal var typeDesc: String {
        switch self {
        case .evpay: return "EV Pay"
        case .favorite: return "즐겨찾기"
        case .speed: return FilterManager.sharedInstance.getSpeedTitle()
        case .place: return FilterManager.sharedInstance.getPlaceTitle()
        case .road: return FilterManager.sharedInstance.getRoadTitle()
        case .type: return FilterManager.sharedInstance.getTypeTitle()
        }
    }
}

internal final class NewFilterBarView: UIView {
    enum Const {
        static let cellHeight: CGFloat = 30
    }
    
    // MARK: UI
    
    private lazy var totalView = UIView()
    
    private lazy var filterSettingBtn = UIButton().then {
        $0.setImage(Icons.iconCategoryFilter.image, for: .normal)
        $0.IBcornerRadius = 32/2
        $0.IBborderWidth = 1
        $0.IBborderColor = Colors.nt1.color
        $0.tintColor = Colors.contentPrimary.color
    }
            
    private lazy var filterTagScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
    }
    
    private lazy var filterTagStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .fill
        $0.spacing = 8                
    }
    
    // MARK: VARIABLE
    
    private var disposeBag = DisposeBag()
    
    internal var evPayView: UIView = UIView()
    internal var favoriteView: UIView = UIView()
         
    // MARK: SYSTEM FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: FUNC
    
    func bind(reactor: MainReactor) {
        self.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        totalView.addSubview(filterSettingBtn)
        filterSettingBtn.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(32)
        }
                
        totalView.addSubview(filterTagScrollView)
        filterTagScrollView.snp.makeConstraints {
            $0.leading.equalTo(filterSettingBtn.snp.trailing).offset(12)
            $0.height.equalTo(54)
            $0.centerY.trailing.equalToSuperview()
        }
        
        filterTagScrollView.addSubview(filterTagStackView)
        filterTagStackView.snp.makeConstraints {
            $0.leading.trailing.centerY.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        for filterTagType in FilterTagType.allCases {
            filterTagStackView.addArrangedSubview(self.createFilterTagView(filterTagType, reactor: reactor))
        }
        
        filterSettingBtn.rx.tap
            .map { MainReactor.Action.showFilterSetting }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
               
    private func createFilterTagView(_ filterTagType: FilterTagType, reactor: MainReactor) -> UIView {
        let titleLbl = UILabel().then {
            $0.font = filterTagType == .evpay ? UIFont(name: "Exo-SemiBoldItalic", size: 14) : .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = Colors.contentSecondary.color
            $0.text = filterTagType.typeDesc
        }
        
        let typeImageProperty = filterTagType.typeImageProperty ?? (imgUnSelect: nil, imgSelect: nil, imgUnSelectColor: nil, imgSelectColor: nil)
        
        let imgView = UIImageView().then {
            $0.image = typeImageProperty.imgUnSelect
            $0.tintColor = typeImageProperty.imgUnSelectColor
        }
        
        let btn = UIButton().then {
            $0.isSelected = false
        }
        
        let view = UIView().then {
            switch filterTagType {
            case .evpay, .favorite:
                $0.addSubview(imgView)
                imgView.snp.makeConstraints {
                    $0.leading.equalTo(typeImageProperty.imgUnSelect == nil ? 10 : 8)
                    $0.centerY.equalToSuperview()
                    $0.width.height.equalTo(typeImageProperty.imgUnSelect == nil ? 0 : 16)
                }
                
                $0.addSubview(titleLbl)
                titleLbl.snp.makeConstraints {
                    $0.leading.equalTo(imgView.snp.trailing).offset(2)
                    $0.centerY.equalToSuperview()
                    $0.trailing.equalToSuperview().offset(-12)
                    $0.height.equalTo(22)
                }
            default:
                $0.addSubview(titleLbl)
                titleLbl.snp.makeConstraints {
                    $0.leading.equalToSuperview().offset(12)
                    $0.centerY.equalToSuperview()
                    $0.height.equalTo(22)
                }
                
                $0.addSubview(imgView)
                imgView.snp.makeConstraints {
                    $0.leading.equalTo(titleLbl.snp.trailing).offset(2)
                    $0.centerY.equalToSuperview()
                    $0.width.height.equalTo(typeImageProperty.imgUnSelect == nil ? 0 : 16)
                    $0.trailing.equalToSuperview().offset(-8)
                }
            }
            
            $0.addSubview(btn)
            btn.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            // 추후에 Arrow 이미지만 붙이면 새로운 디자인으로 적용됨
            $0.backgroundColor = Colors.backgroundPrimary.color
            $0.IBcornerRadius = 15
            $0.IBborderWidth = 1
            $0.IBborderColor = Colors.nt1.color
        }

        switch filterTagType {
        case .evpay:
            let isSelected = FilterManager.sharedInstance.getIsMembershipCardChecked()
            view.IBborderColor = isSelected ? Colors.borderPositive.color : Colors.nt1.color
            titleLbl.textColor = isSelected ? Colors.borderPositive.color : Colors.contentSecondary.color
            imgView.tintColor = isSelected ? Colors.borderPositive.color : Colors.contentSecondary.color
            
            btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    let isEvPayFilter = FilterManager.sharedInstance.getIsMembershipCardChecked()
                    FilterManager.sharedInstance.saveIsMembershipCardChecked(!isEvPayFilter)
                    Observable.just(MainReactor.Action.setEvPayFilter(!isEvPayFilter))
                        .bind(to: reactor.action)
                        .disposed(by: obj.disposeBag)
                }
                .disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.isEvPayFilter }
                .asDriver(onErrorJustReturn: false)
                .drive(with: self) { obj, isEvPayFilter in
                    let isSelected = FilterManager.sharedInstance.getIsMembershipCardChecked()

                    view.IBborderColor = isSelected ? Colors.borderPositive.color : Colors.nt1.color
                    titleLbl.textColor = isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
                    imgView.tintColor = isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
                }
                .disposed(by: self.disposeBag)
        case .favorite:
            let isSelected = FilterManager.sharedInstance.getIsFavoriteChecked()
            view.IBborderColor = isSelected ? Colors.borderPositive.color : Colors.nt1.color
            titleLbl.textColor = isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            imgView.tintColor = isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            imgView.image = isSelected ? typeImageProperty.imgSelect : typeImageProperty.imgUnSelect
            
            btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    let isFavoriteFilter = FilterManager.sharedInstance.getIsFavoriteChecked()
                    FilterManager.sharedInstance.saveIsFavoriteChecked(!isFavoriteFilter)
                    Observable.just(MainReactor.Action.setFavoriteFilter(!isFavoriteFilter))
                        .bind(to: reactor.action)
                        .disposed(by: obj.disposeBag)
                }
                .disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.isFavoriteFilter }
                .asDriver(onErrorJustReturn: false)
                .drive(with: self) { obj, isFavoriteFilter in
                    let isSelected = FilterManager.sharedInstance.getIsFavoriteChecked()
                    
                    view.IBborderColor = isSelected ? Colors.gr6.color : Colors.nt1.color
                    titleLbl.textColor = isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
                    imgView.tintColor = isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
                    imgView.image = isSelected ? typeImageProperty.imgSelect : typeImageProperty.imgUnSelect
                }
                .disposed(by: self.disposeBag)
        case .speed, .place, .road, .type:
            btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    btn.isSelected = !btn.isSelected
                    Observable.just(MainReactor.Action.setSelectedFilterInfo((filterTagType, btn.isSelected)))
                        .bind(to: reactor.action)
                        .disposed(by: obj.disposeBag)
                }
                .disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.selectedFilterInfo }
                .asDriver(onErrorJustReturn: MainReactor.SelectedFilterInfo(.speed, false))
                .drive(with: self) { obj, selectedFilterInfo in
                    switch selectedFilterInfo.filterTagType {
                    case .evpay, .favorite: break
                    default:
                        let isSelected = selectedFilterInfo.filterTagType == filterTagType ? selectedFilterInfo.isSeleted : false
                        view.IBborderColor = isSelected ? Colors.borderPositive.color : Colors.nt1.color
                        view.backgroundColor = isSelected ? Colors.backgroundPositiveLight.color : Colors.backgroundPrimary.color
                        titleLbl.textColor = isSelected ? Colors.gr7.color : Colors.contentSecondary.color
                        imgView.image = isSelected ? selectedFilterInfo.filterTagType.typeImageProperty?.imgSelect : selectedFilterInfo.filterTagType.typeImageProperty?.imgUnSelect
                        imgView.tintColor = isSelected ? selectedFilterInfo.filterTagType.typeImageProperty?.imgSelectColor : selectedFilterInfo.filterTagType.typeImageProperty?.imgUnSelectColor
                        btn.isSelected = isSelected
                    }
                }
                .disposed(by: self.disposeBag)
        }
   
        reactor.state.compactMap { $0.isUpdateFilterBarTitle }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { obj, isUpdate in
                titleLbl.text = filterTagType.typeDesc
            }
            .disposed(by: self.disposeBag)
        
        return view
    }
}

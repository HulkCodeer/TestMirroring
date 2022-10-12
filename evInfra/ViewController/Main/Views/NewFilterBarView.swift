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
    typealias Property = (image: UIImage?, imgUnSelectColor: UIColor?, imgSelectColor: UIColor?)
    
    // 현재 EV Pay는 따로 작동해야 하므로 주석, 추후 디자인 개편시 EV Pay 관련 주석 풀면 됨
//    case evpay
    case price
    case speed
    case place
    case road
    case type
    
    internal func swipeLeft() -> FilterTagType {
        switch self {
//        case .evpay: return .price
        case .price: return .speed
        case .speed: return .place
        case .place: return .road
        case .road: return .type
        case .type: return .type
        }
    }
    
    internal func swipeRight() -> FilterTagType {
        switch self {
//        case .evpay: return .evpay
        case .price: return .price
        case .speed: return .price
        case .place: return .speed
        case .road: return .place
        case .type: return .road
        }
    }
    
    internal var typeImageProperty: Property? {
        switch self {
        // 나중에 이미지 있는 디자인으로 변경시 주석 푸세요
//        case .evpay:
//            return (image: Icons.iconElectricFillXs.image, imgUnSelectColor: Colors.contentSecondary.color, imgSelectColor : Colors.borderPositive.color)
        case .price: return nil
        case .speed: return nil
        case .place: return nil
        case .road: return nil
        case .type: return nil
        }
    }
    
    internal var typeDesc: String {
        switch self {
//        case .evpay: return "EV Pay"
        case .price: return FilterManager.sharedInstance.getPriceTitle()
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
        
        evPayView = self.createFilterTagView(reactor)
        
        filterTagStackView.addArrangedSubview(evPayView)
        
        for filterTagType in FilterTagType.allCases {
            filterTagStackView.addArrangedSubview(self.createFilterTagView(filterTagType, reactor: reactor))
        }
        
        filterSettingBtn.rx.tap
            .map { MainReactor.Action.showFilterSetting }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
    }
    
    // 아래 코드는 추후 디자인 개편시 지워도 됨
    private func createFilterTagView(_ reactor: MainReactor) -> UIView {
        let titleLbl = UILabel().then {
            $0.font = UIFont(name: "Exo-SemiBoldItalic", size: 14)
            $0.textColor = Colors.contentSecondary.color
            $0.textAlignment = .center
            $0.text = "EV Pay"
        }
        
        let typeImageProperty = (image: Icons.iconElectricFillXs.image, imgUnSelectColor: Colors.contentSecondary.color, imgSelectColor : Colors.borderPositive.color)
        
        let imgView = UIImageView().then {
            $0.image = typeImageProperty.image
            $0.tintColor = typeImageProperty.imgUnSelectColor
        }
        
        let btn = UIButton().then {
            $0.isSelected = false
        }
        
        let view = UIView().then {
            $0.addSubview(imgView)
            imgView.snp.makeConstraints {
                $0.leading.equalTo(8)
                $0.centerY.equalToSuperview()
                $0.width.height.equalTo(16)
            }
            
            $0.addSubview(titleLbl)
            titleLbl.snp.makeConstraints {
                $0.leading.equalTo(imgView.snp.trailing).offset(2)
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().offset(-12)
                $0.height.equalTo(22)
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
                
                let GROUP_TITLE = ["A.B.C..", "가", "나", "다", "라", "마", "바", "사", "아", "자", "차", "카", "타", "파", "하", "힣"];
                var groupList = Array<CompanyGroup>()
                var companyList = [CompanyInfoDto]()
                var tagList = Array<TagValue>()
                var titleIndex = 1
                var recommendList = Array<TagValue>()
                
                if isSelected {
                    companyList = Array(FilterManager.sharedInstance.filter.companyDictionary.values)
                    let companyNameSortList = companyList.sorted { $0.name!.lowercased() < $1.name!.lowercased() }

                    for company in companyNameSortList {
                        if company.name! >= GROUP_TITLE[titleIndex] {
                            let currentIndex = titleIndex
                            for index in (currentIndex+1)..<GROUP_TITLE.count {
                                if company.name! >= GROUP_TITLE[index] {
                                    titleIndex += 1
                                } else {
                                    break
                                }
                            }
                            if !tagList.isEmpty {
                                groupList.append(CompanyGroup(title: GROUP_TITLE[titleIndex-1], list: tagList))
                                tagList = Array<TagValue>()
                            }
                            titleIndex += 1
                        }
                        
                        var selected = company.is_visible
                        if isSelected {
                            selected = company.card_setting ?? false // infra card
                        }
                        
                        let icon : UIImage?
                        if company.icon_name != nil {
                            icon = ImageMarker.companyImg(company: company.icon_name!)
                        } else {
                            icon = UIImage(named: "icon_building_sm")
                        }
                        let tag = TagValue(title:company.name!, img:icon!, selected: selected)
                        tagList.append(tag)
                        if company.recommend ?? false {
                            recommendList.append(tag)
                        }
                    }
                    
                    if !tagList.isEmpty {
                        groupList.append(CompanyGroup(title: GROUP_TITLE[titleIndex-1], list: tagList))
                    }

                    let abcGroup = groupList[0]
                    groupList.remove(at: 0)
                    groupList.append(abcGroup)
                    
                    groupList.insert(CompanyGroup(title: "추천", list: recommendList), at: 0)

                    for company in companyList {
                        for list in groupList {
                            for tag in list.list {
                                if (company.name == tag.title){
                                    if let companyId = company.company_id {
                                        ChargerManager.sharedInstance.updateCompanyVisibility(isVisible: tag.selected, companyID: companyId)
                                        continue
                                    }
                                }
                            }
                        }
                    }                    
                } else {
                    for company in companyList {
                        for groupItem in groupList {
                            for _ in groupItem.list {
                                if let companyId = company.company_id {
                                    ChargerManager.sharedInstance.updateCompanyVisibility(isVisible: true, companyID: companyId)
                                    continue
                                }
                            }
                        }
                    }
                }
                FilterManager.sharedInstance.updateCompanyFilter()
            }
            .disposed(by: self.disposeBag)
                
        return view
    }
               
    private func createFilterTagView(_ filterTagType: FilterTagType, reactor: MainReactor) -> UIView {
        let titleLbl = UILabel().then {
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = Colors.contentSecondary.color
            $0.text = filterTagType.typeDesc
        }
        
        let typeImageProperty = filterTagType.typeImageProperty ?? (image: nil, imgUnSelectColor: nil, imgSelectColor: nil)
        
        let imgView = UIImageView().then {
            $0.image = typeImageProperty.image
            $0.tintColor = typeImageProperty.imgUnSelectColor
        }
        
        let btn = UIButton().then {
            $0.isSelected = false
        }
        
        let view = UIView().then {
            $0.addSubview(imgView)
            imgView.snp.makeConstraints {
                $0.leading.equalTo(typeImageProperty.image == nil ? 10 : 8)
                $0.centerY.equalToSuperview()
                $0.width.height.equalTo(typeImageProperty.image == nil ? 0 : 16)
            }
            
            $0.addSubview(titleLbl)
            titleLbl.snp.makeConstraints {
                $0.leading.equalTo(imgView.snp.trailing).offset(2)
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().offset(-12)
                $0.height.equalTo(22)
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
            .asDriver(onErrorJustReturn: MainReactor.SelectedFilterInfo(.price, false))
            .drive(with: self) { obj, selectedFilterInfo in
                let isSelected = selectedFilterInfo.filterTagType == filterTagType ? selectedFilterInfo.isSeleted : false
                view.IBborderColor = isSelected ? Colors.borderPositive.color : Colors.nt1.color
                titleLbl.textColor = isSelected ? Colors.borderPositive.color : Colors.contentSecondary.color
                btn.isSelected = isSelected
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.isUpdateFilterBarTitle }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { obj, isUpdate in
                titleLbl.text = filterTagType.typeDesc
            }
            .disposed(by: self.disposeBag)
        
        return view
    }
}

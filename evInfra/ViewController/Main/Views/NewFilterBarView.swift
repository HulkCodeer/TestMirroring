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
    
    case evpay
    case price
    case speed
    case place
    case road
    case type
    
    internal func swipeLeft() -> FilterTagType {
        switch self {
        case .evpay: return .price
        case .price: return .speed
        case .speed: return .place
        case .place: return .road
        case .road: return .type
        case .type: return .type
        }
    }
    
    internal func swipeRight() -> FilterTagType {
        switch self {
        case .evpay: return .evpay
        case .price: return .evpay
        case .speed: return .price
        case .place: return .speed
        case .road: return .place
        case .type: return .road
        }
    }
    
    internal var typeImageProperty: Property? {
        switch self {
        // 나중에 이미지 있는 디자인으로 변경시 주석 푸세요
        case .evpay:
            return (image: Icons.iconElectricFillXs.image, imgUnSelectColor: Colors.contentSecondary.color, imgSelectColor : Colors.borderPositive.color)
        case .price: return nil
        case .speed: return nil
        case .place: return nil
        case .road: return nil
        case .type: return nil
        }
    }
    
    internal var typeDesc: String {
        switch self {
        case .evpay: return "EV Pay"
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
        
    private weak var mainReactor: MainReactor?
         
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
                let tempIsSelected = !btn.isSelected
                btn.isSelected = tempIsSelected
                Observable.just(MainReactor.Action.setFilterType(tempIsSelected ? filterTagType : nil))
                    .bind(to: reactor.action)
                    .disposed(by: obj.disposeBag)
            }
            .disposed(by: self.disposeBag)
        
        if filterTagType == .evpay {
            let isSelected = FilterManager.sharedInstance.getIsMembershipCardChecked()
            view.IBborderColor = isSelected ? Colors.borderPositive.color : Colors.nt1.color
            titleLbl.textColor = isSelected ? Colors.borderPositive.color : Colors.contentSecondary.color
            imgView.tintColor = isSelected ? Colors.borderPositive.color : Colors.contentSecondary.color
        }
        
                
        reactor.state.map { $0.selectedFilterTagType }
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { obj, selectedFilterTagType in
                let isSelected = selectedFilterTagType == filterTagType ? (selectedFilterTagType == nil ? false : true) : false
                if filterTagType == .evpay {
                    view.IBborderColor = isSelected ? Colors.borderPositive.color : Colors.nt1.color
                    titleLbl.textColor = isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
                    imgView.tintColor = isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
                    FilterManager.sharedInstance.saveIsMembershipCardChecked(isSelected)
                    
                    let GROUP_TITLE = ["A.B.C..", "가", "나", "다", "라", "마", "바", "사", "아", "자", "차", "카", "타", "파", "하", "힣"];
                    var groupList = Array<CompanyGroup>()
                    var companyList = [CompanyInfoDto]()
                    var tagList = Array<TagValue>()
                    var titleIndex = 1
                    var recommendList = Array<TagValue>()
                    
                    companyList = Array(FilterManager.sharedInstance.filter.companyDictionary.values)
                    let companyNameSortList = companyList.sorted { $0.name!.lowercased() < $1.name!.lowercased() }

                    for company in companyNameSortList {
                        printLog(out: "PARK TEST company name : \(company.name)")
                        if company.name! >= GROUP_TITLE[titleIndex] {
                            printLog(out: "PARK TEST company : \(company.name)")
                            
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
                    FilterManager.sharedInstance.updateCompanyFilter()
                } else {
                    
                    view.IBborderColor = isSelected ? Colors.borderPositive.color : Colors.nt1.color
                    titleLbl.textColor = isSelected ? Colors.borderPositive.color : Colors.contentSecondary.color
                    btn.isSelected = isSelected
                }
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

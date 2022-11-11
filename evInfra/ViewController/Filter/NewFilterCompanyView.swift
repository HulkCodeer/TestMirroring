//
//  NewFilterCompanyView.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/10/27.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

internal final class NewFilterCompanyView: UIView {
    // MARK: UI
    private lazy var totalView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
    private lazy var filterTitleLbl = UILabel().then {
        $0.text = "충전사업자"
        $0.font = .systemFont(ofSize: 14, weight: .bold)
    }
    
    private lazy var filterSubTitleLbl = UILabel().then {
        $0.text = "충전사업자 선택 시, 지도에 해당하는 충전 사업자만 노출됩니다."
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = Colors.contentTertiary.color
    }
    
    private lazy var switchTitleLbl = UILabel().then {
        $0.text = "전체"
        $0.font = .systemFont(ofSize: 12, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
    }
    
    private lazy var allSwitch = UISwitch().then {
        $0.tintColor = Colors.backgroundTertiary.color
        $0.thumbTintColor = .white
        $0.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        $0.onTintColor = Colors.backgroundPositive.color
    }
    
    private lazy var groupStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .fill
        $0.spacing = 4
    }
    
    let groupTitleLbl = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = Colors.contentDisabled.color
    }

    internal lazy var companyTableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = UITableView.automaticDimension
        $0.separatorStyle = .none
        $0.separatorInset = .zero
        $0.allowsSelection = false
        $0.isScrollEnabled = false
        $0.backgroundColor = Colors.backgroundPositiveLight.color
    }
    
    // MARK: VARIABLES
    private var filterReactor: GlobalFilterReactor?
    private var disposeBag = DisposeBag()
    private let groupTitle: [String] = ["A.B.C..", "가", "나", "다", "라", "마", "바", "사", "아", "자", "차", "카", "타", "파", "하", "힣"]
    private var groups: [NewCompanyGroup] = [NewCompanyGroup]()
    private var originalGroups: [NewCompanyGroup] = [NewCompanyGroup]()
    private var isAllSelect: Bool = true
    internal weak var delegate: NewDelegateFilterChange?
    internal var companies: [Company] = [Company]()
    
    // MARK: SYSTEM FUNC
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(500)
        }
        
        totalView.addSubview(filterTitleLbl)
        filterTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(16)
        }
        
        totalView.addSubview(filterSubTitleLbl)
        filterSubTitleLbl.snp.makeConstraints {
            $0.top.equalTo(filterTitleLbl.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(14)
        }
        
        let totalSwitchView = UIView().then {
            $0.addSubview(switchTitleLbl)
            switchTitleLbl.snp.makeConstraints {
                $0.top.equalToSuperview().offset(17)
                $0.bottom.equalToSuperview().offset(-17)
                $0.leading.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
            
            $0.addSubview(allSwitch)
            allSwitch.snp.makeConstraints {
                $0.leading.equalTo(switchTitleLbl.snp.trailing).offset(8)
                $0.trailing.equalToSuperview()
                $0.centerY.equalTo(switchTitleLbl.snp.centerY)
            }
        }
        
        totalView.addSubview(totalSwitchView)
        totalSwitchView.snp.makeConstraints {
            $0.top.equalTo(filterSubTitleLbl.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(56)
        }
        
        totalView.addSubview(companyTableView)
        companyTableView.snp.makeConstraints {
            $0.top.equalTo(totalSwitchView.snp.bottom)
            $0.leading.equalTo(totalView.snp.leading)
            $0.trailing.equalTo(totalView.snp.trailing)
            $0.bottom.equalTo(totalView.snp.bottom).offset(-16)
            $0.height.equalTo(400)
        }
        
        companyTableView.register(NewCompanyTableViewCell.self, forCellReuseIdentifier: "NewCompanyTableViewCell")
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    internal func bind(reactor: GlobalFilterReactor) {
        self.filterReactor = reactor
        
        Observable.just(GlobalFilterReactor.Action.loadCompanies)
            .bind(to: GlobalFilterReactor.sharedInstance.action)
            .disposed(by: self.disposeBag)
        
        GlobalFilterReactor.sharedInstance.state.compactMap { $0.loadedCompanies }
            .subscribe(with: self) { obj, companies in
                obj.groups.removeAll()

                var companiesInGroup: [Company] = [Company]()
                var recommand: [Company] = [Company]()
                var titleIndex: Int = 1
                var allSelect: Bool = true

                for (index, company) in companies.enumerated() {
                    if company.title >= obj.groupTitle[titleIndex] {
                        let currentIndex = titleIndex
                        for index in (currentIndex + 1) ..< obj.groupTitle.count {
                            if company.title >= obj.groupTitle[index] {
                                titleIndex += 1
                            } else {
                                break
                            }
                        }
                        if !companiesInGroup.isEmpty {
                            obj.groups.append(NewCompanyGroup(groupTitle: obj.groupTitle[titleIndex - 1], companies: companiesInGroup, groupIndex: index))
                            companiesInGroup = [Company]()
                        }

                        titleIndex += 1
                    }

                    // evpay filter 적용
                    companiesInGroup.append(company)
                    
                    // 추천 그룹 추가
                    if company.isRecommaned {
                        recommand.append(company)
                    }

                    if !company.selected {
                        allSelect = false
                    }
                }
                // 전체 선택 유무
                allSelect ? Observable.just(GlobalFilterReactor.Action.setAllCompanies(true))
                    .bind(to: GlobalFilterReactor.sharedInstance.action).disposed(by: self.disposeBag)
                : Observable.just(GlobalFilterReactor.Action.setAllCompanies(false))
                    .bind(to: GlobalFilterReactor.sharedInstance.action).disposed(by: self.disposeBag)

                if !companiesInGroup.isEmpty {
                    obj.groups.append(NewCompanyGroup(groupTitle: obj.groupTitle[titleIndex-1], companies: companiesInGroup, groupIndex: obj.groups.count - 1))
                }

                let abcGroup = obj.groups[0]
                obj.groups.remove(at: 0)
                obj.groups.append(abcGroup)
                obj.groups.insert(NewCompanyGroup(groupTitle: "추천", companies: recommand, groupIndex: 0), at: 0)

                obj.originalGroups = obj.groups
                obj.companyTableView.reloadData()
            }.disposed(by: self.disposeBag)
        
        GlobalFilterReactor.sharedInstance.state.compactMap { $0.isSelectedAllCompanies }
            .bind(to: allSwitch.rx.isOn)
            .disposed(by: self.disposeBag)
        
        allSwitch.rx.isOn
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { obj, isOn in
                obj.allSwitch.isOn = isOn
                
                // step1. EvPay filter 끄기 , isOn == true 일때
                if isOn {
                    Observable.just(GlobalFilterReactor.Action.setEvPayFilter(false))
                        .bind(to: GlobalFilterReactor.sharedInstance.action)
                        .disposed(by: obj.disposeBag)
                }
                
                // step2. 충전 사업자 불러오기
                Observable.just(GlobalFilterReactor.Action.loadCompanies)
                    .bind(to: GlobalFilterReactor.sharedInstance.action)
                    .disposed(by: obj.disposeBag)
            }.disposed(by: self.disposeBag)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        companyTableView.snp.updateConstraints {
            $0.height.equalTo(companyTableView.contentSize.height)
        }
    }
    
    internal func shouldChange() -> Bool {
        let originalGroups = Array(FilterManager.sharedInstance.filter.companyDictionary.values)
        
        for original in originalGroups {
            for group in groups {
                for company in group.companies {
                    if original.name == company.title && original.is_visible != company.selected {
                        return true
                    }
                }
            }
        }
        
        return false
    }
}

extension NewFilterCompanyView: FilterButtonAction {
    func saveFilter() {
        Observable.just(GlobalFilterReactor.Action.setCompanyFilter(groups))
            .bind(to: GlobalFilterReactor.sharedInstance.action)
            .disposed(by: self.disposeBag)
    }
    
    func resetFilter() {
        for group in groups {
            for company in group.companies {
                company.selected = true
            }
        }
        Observable.just(GlobalFilterReactor.Action.setCompanyFilter(groups))
            .bind(to: GlobalFilterReactor.sharedInstance.action)
            .disposed(by: self.disposeBag)

        Observable.just(GlobalFilterReactor.Action.setAllCompanies(true))
            .bind(to: GlobalFilterReactor.sharedInstance.action)
            .disposed(by: self.disposeBag)

        companyTableView.reloadData()
        delegate?.changedFilter()
    }
    
    func revertFilter() {}
}

// MARK: UITableView Delegate
extension NewFilterCompanyView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCell(ofType: NewCompanyTableViewCell.self, for: indexPath)
        cell.configuration(with: groups, groupIndex: indexPath.row)
        cell.layoutIfNeeded()
        
        return 200
    }
}

// MARK: UITableView DataSource
extension NewFilterCompanyView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: NewCompanyTableViewCell.self, for: indexPath)
        cell.configuration(with: groups, groupIndex: indexPath.row)
        cell.delegate = self

        if let _reactor = self.filterReactor {
            cell.bind(reactor: _reactor)
        }
        
        let height = cell.companiesCollectionView.collectionViewLayout.collectionViewContentSize.height
        cell.bounds.size.height = height
        cell.layoutIfNeeded()
        
        return cell
    }
}

extension NewFilterCompanyView: CompanyTableCellDelegate {
    func onClickTag(tagName: String, value: Bool, groupIndex: Int) {
        for company in groups[groupIndex].companies {
            if company.title == tagName {
                company.selected = value
            }
        }
        
        companyTableView.reloadData()
        delegate?.changedFilter()
    }
}
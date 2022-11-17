//
//  NewCompanyTableViewCell.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/10/28.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import SnapKit
import Then

internal class NewCompanyGroup {
    var groupTitle: String
    var companies: [Company]
    var groupIndex: Int
    
    init(groupTitle: String, companies: [Company], groupIndex: Int) {
        self.groupTitle = groupTitle
        self.companies = companies
        self.groupIndex = groupIndex
    }
}

internal class Company {
    let title: String
    let companyId: String
    let img: UIImage
    var selected: Bool
    let isRecommaned: Bool
    let isEvPayAvailable: Bool
    
    init(title: String, companyId: String, img: UIImage, selected: Bool, isRecommaned: Bool, isEvPayAvailable: Bool) {
        self.title = title
        self.companyId = companyId
        self.img = img
        self.selected = selected
        self.isRecommaned = isRecommaned
        self.isEvPayAvailable = isEvPayAvailable
    }
}

internal final class NewCompanyTableViewCell: UITableViewCell {
    
    // MARK: UI
    private lazy var containerView = UIView()

    internal var groupTitleLbl = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = Colors.contentDisabled.color
        $0.numberOfLines = 1
        $0.sizeToFit()
    }
    
    internal var companiesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = TagFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        $0.collectionViewLayout = layout
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = false
        $0.register(NewTagListViewCell.self, forCellWithReuseIdentifier: "NewTagListViewCell")
    }
    
    // MARK: VARIABLES
    private var filterReactor: FilterReactor?
    private var disposeBag = DisposeBag()
    private var group: NewCompanyGroup?
    internal var groups: [NewCompanyGroup] = [NewCompanyGroup]()
    internal var groupIndex: Int = 0
    internal weak var delegate: CompanyTableCellDelegate?
    internal weak var delegateFilterChange: NewDelegateFilterChange?
    internal var companies: [Company] = [Company]()
    internal var totalWidthPerRow: CGFloat = 0
    internal var rowCounts: Int = 1
    
    // MARK: SYSTEM FUNC
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.addSubview(groupTitleLbl)
        groupTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(14)
        }

        self.contentView.addSubview(companiesCollectionView)
        companiesCollectionView.snp.makeConstraints {
            $0.top.equalTo(groupTitleLbl.snp.bottom).offset(16).priority(.low)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(34)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: FUNC
    
    internal func configuration(with groups: [NewCompanyGroup], groupIndex: Int) {
        self.groups = groups
        self.groupIndex = groupIndex
        groupTitleLbl.text = groups[groupIndex].groupTitle
        companies = groups[groupIndex].companies
        companiesCollectionView.reloadData()
    }
    
    internal func bind(reactor: FilterReactor) {
        self.filterReactor = reactor
        companiesCollectionView.delegate = self
        companiesCollectionView.dataSource = self
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        companiesCollectionView.layoutIfNeeded()
        companiesCollectionView.frame = CGRect(x: 0, y: 0, width: targetSize.width - 16 - 16, height: 34)
        let size = companiesCollectionView.collectionViewLayout.collectionViewContentSize

        companiesCollectionView.snp.updateConstraints {
            $0.height.equalTo(size.height)
        }

        return CGSize(width: size.width, height: size.height + 46)
    }
}

// MARK: UICollecionView DataSource
extension NewCompanyTableViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return companies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewTagListViewCell", for: indexPath) as? NewTagListViewCell else { return UICollectionViewCell() }

        let index = indexPath.row
        let company = companies[index]

        cell.btn.isSelected = company.selected
        cell.titleLbl.text = company.title
        cell.titleLbl.textColor = company.selected ? Colors.gr7.color : Colors.contentSecondary.color
        cell.imgView.image = company.img
        cell.imgView.tintColor = company.selected ? Colors.gr7.color : Colors.contentSecondary.color
        cell.totalView.backgroundColor = company.selected ? Colors.backgroundPositiveLight.color : Colors.backgroundPrimary.color
        cell.totalView.borderColor = company.selected ? Colors.borderPositive.color : Colors.nt1.color
        
        cell.btn.rx.tap
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { obj, _ in
                cell.btn.isSelected = !cell.btn.isSelected
                
                let isSelected = cell.btn.isSelected
                obj.groups[obj.groupIndex].companies[index].selected = isSelected
                cell.btn.isSelected = isSelected
                cell.titleLbl.textColor = isSelected ? Colors.gr7.color : Colors.contentSecondary.color
                cell.imgView.tintColor = isSelected ? Colors.gr7.color : Colors.contentSecondary.color
                cell.totalView.backgroundColor = isSelected ? Colors.backgroundPositiveLight.color : Colors.backgroundPrimary.color
                cell.totalView.borderColor = isSelected ? Colors.borderPositive.color : Colors.nt1.color
                
                if !isSelected {
//                    Observable.just(FilterReactor.Action.setAllCompanies(false))
//                        .bind(to: reactor.action)
//                        .disposed(by: obj.disposeBag)
                }
                
                obj.delegateFilterChange?.changedFilter()
                obj.delegate?.onClickTag(tagName: obj.groups[obj.groupIndex].companies[index].title, value: cell.btn.isSelected, groupIndex: obj.groupIndex)
            }.disposed(by: self.disposeBag)
        
        return cell
    }
}

extension NewCompanyTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewTagListViewCell", for: indexPath) as? NewTagListViewCell else { return CGSize.zero }
        cell.titleLbl.text = groups[groupIndex].companies[indexPath.row].title
        cell.titleLbl.sizeToFit()
        
        let totalWidth = cell.titleLbl.frame.width + 12 + 16 + 4 + 12 // leftPadding + imgView + rightPadding + label right padding
        return CGSize(width: ceil(totalWidth), height: 30)
    }
}



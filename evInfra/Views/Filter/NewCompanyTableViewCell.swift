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
    
    init(groupTitle: String, companies: [Company]) {
        self.groupTitle = groupTitle
        self.companies = companies
    }
}

internal class Company {
    let title: String
    let img: UIImage
    var selected: Bool
    let isRecommaned: Bool
    
    init(title: String, img: UIImage, selected: Bool, isRecommaned: Bool) {
        self.title = title
        self.img = img
        self.selected = selected
        self.isRecommaned = isRecommaned
    }
}

internal final class NewCompanyTableViewCell: UITableViewCell {
    
    // MARK: UI
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .red
    }
    
    internal var groupTitleLbl = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = Colors.contentDisabled.color
    }
    
    internal var companiesCollectionView = DynamicCollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = TagFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        $0.collectionViewLayout = layout
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.register(NewTagListViewCell.self, forCellWithReuseIdentifier: "NewTagListViewCell")
    }
    
    // MARK: VARIABLES
    private var filterReactor: GlobalFilterReactor?
    private var disposeBag = DisposeBag()
    internal weak var delegate: CompanyTableCellDelegate?
    internal var companies: [Company] = [Company]()
    internal var totalWidthPerRow: CGFloat = 0
    internal var rowCounts: Int = 1
    
    // MARK: SYSTEM FUNC
    override func awakeFromNib() {
        super.awakeFromNib()
//        makeUI()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        makeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: FUNC
    private func makeUI() {
        
    }
    
    internal func configuration(with group: NewCompanyGroup) {
        groupTitleLbl.text = group.groupTitle
        companies = group.companies
        companiesCollectionView.reloadData()
    }
    
    internal func bind(reactor: GlobalFilterReactor) {
        self.filterReactor = reactor
        companiesCollectionView.delegate = self
        companiesCollectionView.dataSource = self
        
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
            $0.top.equalTo(groupTitleLbl.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(32)
        }
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        companiesCollectionView.layoutIfNeeded()
        companiesCollectionView.frame = CGRect(x: 0, y: 0, width: targetSize.width - 16 - 16, height: 1)
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
        
        if let _reactor = self.filterReactor {
            cell.btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    cell.btn.isSelected = !cell.btn.isSelected
                    printLog(out: "//// 클릭 ////")
                    
                    if !cell.btn.isSelected {
                        Observable.just(GlobalFilterReactor.Action.setAllCompanies(false))
                            .bind(to: _reactor.action)
                            .disposed(by: obj.disposeBag)
                        
                        Observable.just(GlobalFilterReactor.Action.changedFilter(true))
                            .bind(to: _reactor.action)
                            .disposed(by: obj.disposeBag)
                    }
                    
                    obj.companies[index].selected = !company.selected
                    obj.companiesCollectionView.reloadData()
                }.disposed(by: self.disposeBag)
        }
        
        return cell
    }
}


extension NewCompanyTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewTagListViewCell", for: indexPath) as? NewTagListViewCell else { return CGSize.zero }
        let strText = companies[indexPath.row].title
        let cellSize = cell.getInteresticSize(text: strText, cv: collectionView)

        let collectionViewWidth = UIScreen.main.bounds.width - 32
        let dynamicCellWidth = cellSize.width
        totalWidthPerRow += dynamicCellWidth + 8

        if (totalWidthPerRow > collectionViewWidth) {
           rowCounts += 1
           totalWidthPerRow = dynamicCellWidth + 8
        }
        
        return cellSize
    }
}



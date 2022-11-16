//
//  NewFilterTypeView.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/10/18.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

protocol NewDelegateSlowTypeChange: AnyObject {
    func onChangeSlowType(isFastSpeedOn: Bool, isSlowSpeedon: Bool)
}

internal class NewTag: Equatable {
    static func == (lhs: NewTag, rhs: NewTag) -> Bool {
        return lhs.title == rhs.title && lhs.selected == rhs.selected && lhs.uniqueKey == rhs.uniqueKey && lhs.image == rhs.image
    }
    
    var title: String
    var selected: Bool
    var uniqueKey: Int
    var image: UIImage?
    
    init(title: String, selected: Bool, uniqueKey: Int, image: UIImage?) {
        self.title = title
        self.selected = selected
        self.uniqueKey = uniqueKey
        self.image = image
    }
}

enum ChargerType: CaseIterable {
    typealias Property = (image: UIImage?, imgUnSelectColor: UIColor?, imgSelectColor: UIColor?)
    
    case dcCombo
    case dcDemo
    case ac3
    case slow
    case superCharger
    case destination
    
    internal var typeImageProperty: Property? {
        switch self {
        case .dcCombo:
            return (image: Icons.iconChargerDcComboMd.image, imgUnSelectColor: Colors.contentSecondary.color, imgSelectColor: Colors.gr7.color)
        case .dcDemo:
            return (image: Icons.iconChargerDcDemoMd.image, imgUnSelectColor: Colors.contentSecondary.color, imgSelectColor: Colors.gr7.color)
        case .ac3:
            return (image: Icons.iconChargerActhreeMd.image, imgUnSelectColor: Colors.contentSecondary.color, imgSelectColor: Colors.gr7.color)
        case .slow:
            return (image: Icons.iconChargerSlowMd.image, imgUnSelectColor: Colors.contentSecondary.color, imgSelectColor: Colors.gr7.color)
        case .superCharger:
            return (image: Icons.iconChargerSuperMd.image, imgUnSelectColor: Colors.contentSecondary.color, imgSelectColor: Colors.gr7.color)
        case .destination:
            return (image: Icons.iconChargerSlowMd.image, imgUnSelectColor: Colors.contentSecondary.color, imgSelectColor: Colors.gr7.color)
        }
    }
    
    internal var typeTitle: String {
        switch self {
        case .dcCombo: return "DC콤보"
        case .dcDemo: return "DC차데모"
        case .ac3: return "AC3상"
        case .slow: return "완속"
        case .superCharger: return "슈퍼차저"
        case .destination: return "데스티네이션"
        }
    }
    
    internal var selected: Bool {
        switch self {
        case .dcCombo: return FilterManager.sharedInstance.filter.dcCombo
        case .dcDemo: return FilterManager.sharedInstance.filter.dcDemo
        case .ac3: return FilterManager.sharedInstance.filter.ac3
        case .slow: return FilterManager.sharedInstance.filter.slow
        case .superCharger: return FilterManager.sharedInstance.filter.superCharger
        case .destination: return FilterManager.sharedInstance.filter.destination
        }
    }
    
    internal var uniqueKey: Int {
        switch self {
        case .dcCombo: return Const.CHARGER_TYPE_DCCOMBO
        case .dcDemo: return Const.CHARGER_TYPE_DCDEMO
        case .ac3: return Const.CHARGER_TYPE_AC
        case .slow: return Const.CHARGER_TYPE_SLOW
        case .superCharger: return Const.CHARGER_TYPE_SUPER_CHARGER
        case .destination: return Const.CHARGER_TYPE_DESTINATION
        }
    }
}

internal final class NewFilterTypeView: UIView {
    // MARK: UI
    private lazy var totalView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
    private lazy var filterTitleLbl = UILabel().then {
        $0.text = "충전기타입"
        $0.font = .systemFont(ofSize: 14, weight: .bold)
    }
    
    private lazy var chargerTypesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = TagFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        $0.collectionViewLayout = layout
        $0.register(NewTagListViewCell.self, forCellWithReuseIdentifier: "NewTagListViewCell")
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = false
        $0.delegate = self
        $0.dataSource = self
    }
    
    // MARK: VARIABLES
    private weak var mainReactor: MainReactor?
    private var disposeBag = DisposeBag()
    private var _originalTags: [NewTag] = [NewTag]()
    private var tags: [NewTag] = [NewTag]()
    internal weak var delegateSlowTypeChange: NewDelegateSlowTypeChange?

    internal var isDirectChange: Bool = false
    
    // MARK: SYSTEM FUNC
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: REACTORKIT
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
        
        totalView.addSubview(chargerTypesCollectionView)
        chargerTypesCollectionView.snp.makeConstraints {
            $0.top.equalTo(filterTitleLbl.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.lessThanOrEqualToSuperview().offset(-20)
            $0.height.equalTo(76)
        }
        
        Observable.just(FilterReactor.Action.loadChargerTypes)
            .bind(to: FilterReactor.sharedInstance.action)
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.filterModel.chargerTypes }
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { obj, types in
                obj.tags.removeAll()
                obj._originalTags.removeAll()
                obj._originalTags = types
                obj.tags = types
                obj.chargerTypesCollectionView.reloadData()
            }.disposed(by: self.disposeBag)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension NewFilterTypeView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewTagListViewCell", for: indexPath) as? NewTagListViewCell else { return CGSize.zero }
        let title = tags[indexPath.row].title
        return cell.adjustCellSize(height: 34, str: title)
    }
}

extension NewFilterTypeView: FilterButtonAction {
    func saveFilter() {
        let filterModel = GlobalFilterReactor.sharedInstance.currentState.filterModel
        Observable.of(GlobalFilterReactor.Action.saveFilter(filterModel))
            .bind(to: GlobalFilterReactor.sharedInstance.action)
            .disposed(by: self.disposeBag)

        Observable.just(GlobalFilterReactor.Action.loadChargerTypes)
            .bind(to: GlobalFilterReactor.sharedInstance.action)
            .disposed(by: self.disposeBag)
    }
    
    func resetFilter() {
        for index in 0..<tags.count {
            tags[index].selected = !(tags[index].uniqueKey == Const.CHARGER_TYPE_SLOW || tags[index].uniqueKey == Const.CHARGER_TYPE_DESTINATION)
            Observable.just(FilterReactor.Action.changedChargerTypeFilter((tags[index].uniqueKey, tags[index].selected)))
                .bind(to: FilterReactor.sharedInstance.action)
                .disposed(by: self.disposeBag)
        }
        
        Observable.just(FilterReactor.Action.setChargerTypeFilter(tags))
            .bind(to: FilterReactor.sharedInstance.action)
            .disposed(by: self.disposeBag)
    }
    
    func revertFilter() {
        for original in _originalTags {
            Observable.just(FilterReactor.Action.changedChargerTypeFilter((original.uniqueKey, original.selected)))
                .bind(to: FilterReactor.sharedInstance.action)
                .disposed(by: self.disposeBag)
        }
    }
}

// MARK: UICollectionViewDataSource
extension NewFilterTypeView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewTagListViewCell", for: indexPath) as? NewTagListViewCell else { return UICollectionViewCell() }
        
        let index = indexPath.row
        let chargerType = tags[indexPath.row]
        
        cell.btn.isSelected = chargerType.selected
        cell.titleLbl.text = chargerType.title
        cell.titleLbl.textColor = chargerType.selected ? Colors.gr7.color : Colors.contentSecondary.color
        cell.imgView.image = chargerType.image
        cell.imgView.tintColor = chargerType.selected ? Colors.gr7.color : Colors.contentSecondary.color
        cell.totalView.backgroundColor = chargerType.selected ? Colors.backgroundPositiveLight.color : Colors.backgroundPrimary.color
        cell.totalView.borderColor = chargerType.selected ? Colors.borderPositive.color : Colors.nt1.color
        
        cell.btn.rx.tap
            .asDriver()
            .drive(with: self) { obj, _ in
                cell.btn.isSelected = !cell.btn.isSelected
                obj.tags[index].selected = cell.btn.isSelected

                Observable.just(GlobalFilterReactor.Action.updateChargerTypeFilter(obj.tags))
                    .bind(to: GlobalFilterReactor.sharedInstance.action)
                    .disposed(by: obj.disposeBag)
                
                self.shouldSlowType()
                if obj.isDirectChange {
                    obj.saveFilter()
                }
                
                Observable.just(GlobalFilterReactor.Action.shouldChanged)
                    .bind(to: GlobalFilterReactor.sharedInstance.action)
                    .disposed(by: obj.disposeBag)
            
                cell.titleLbl.textColor = cell.btn.isSelected ? Colors.gr7.color : Colors.contentSecondary.color
                cell.imgView.tintColor = cell.btn.isSelected ? Colors.gr7.color : Colors.contentSecondary.color
                cell.totalView.backgroundColor = cell.btn.isSelected ? Colors.backgroundPositiveLight.color : Colors.backgroundPrimary.color
                cell.totalView.borderColor = cell.btn.isSelected ? Colors.borderPositive.color : Colors.nt1.color
            }.disposed(by: self.disposeBag)
        /* cell에 리액터 주입 안 한 이유:
         * NewTagListViewCell은 상단필터의 충전기타입 필터 뿐만 아니라 필터 상세의 회사필터에도 적용되는데,
         * 각각 충전기타입과 회사타입에 대한 바인드 함수를 따로 정의하기 위해 cell안에 리액터 주입을 안함.
         */

        return cell
    }
    
    private func shouldSlowType() {
        var isFastSpeedTypeOn: Bool = false
        var isSlowSpeedTypeOn: Bool = false
        
        for index in 0..<tags.count {
            if tags[index].uniqueKey == Const.CHARGER_TYPE_SLOW || tags[index].uniqueKey == Const.CHARGER_TYPE_DESTINATION {
                // 완속
                isSlowSpeedTypeOn = isSlowSpeedTypeOn || tags[index].selected
            } else {
                // 급속
                isFastSpeedTypeOn = isFastSpeedTypeOn || tags[index].selected
            }
        }
        
        delegateSlowTypeChange?.onChangeSlowType(isFastSpeedOn: isFastSpeedTypeOn, isSlowSpeedon: isSlowSpeedTypeOn)
        
        if !isSlowSpeedTypeOn {
            Observable.just(GlobalFilterReactor.Action.updateSlowTypeOn(false))
                .bind(to: GlobalFilterReactor.sharedInstance.action)
                .disposed(by: self.disposeBag)
        }
    }
}

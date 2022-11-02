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
    
    internal var index: Int {
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
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        $0.collectionViewLayout = layout
        $0.register(NewTagListViewCell.self, forCellWithReuseIdentifier: "NewTagListViewCell")
        $0.delegate = self
        $0.dataSource = self
    }
    
    // MARK: VARIABLES
    private weak var mainReactor: MainReactor?
    private var disposeBag = DisposeBag()
    internal var types: [ChargerType] = [ChargerType]()
    internal var saveOnChange: Bool = false
    
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
    internal func bind(reactor: MainReactor) {
        self.mainReactor = reactor
        self.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(138)
        }
        
        totalView.addSubview(filterTitleLbl)
        filterTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(16)
        }
        
        totalView.addSubview(chargerTypesCollectionView)
        chargerTypesCollectionView.snp.makeConstraints {
            $0.top.equalTo(filterTitleLbl.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-20)
            $0.height.equalTo(76)
        }
        
        for chargerType in ChargerType.allCases {
            types.append(chargerType)
        }
        
        chargerTypesCollectionView.reloadData()
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension NewFilterTypeView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewTagListViewCell", for: indexPath) as? NewTagListViewCell else { return CGSize.zero }
        let title = types[indexPath.row].typeTitle
        return cell.getInteresticSize(text: title, cv: collectionView)
    }
}

// MARK: UICollectionViewDataSource
extension NewFilterTypeView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return types.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewTagListViewCell", for: indexPath) as? NewTagListViewCell else { return UICollectionViewCell() }
        
        let index = indexPath.row
        let chargerType = types[indexPath.row]
        
        let typeImageProperty = chargerType.typeImageProperty ?? (image: nil, imgUnSelectColor: nil, imgSelectColor: nil)
        cell.btn.isSelected = chargerType.selected
        cell.titleLbl.text = chargerType.typeTitle
        cell.titleLbl.textColor = chargerType.selected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
        cell.imgView.image = typeImageProperty.image
        cell.imgView.tintColor = chargerType.selected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
        cell.totalView.backgroundColor = chargerType.selected ? Colors.backgroundPositiveLight.color : Colors.backgroundPrimary.color
        cell.totalView.borderColor = chargerType.selected ? Colors.borderPositive.color : Colors.nt1.color

        if let _reactor = self.mainReactor {
            cell.btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    cell.btn.isSelected = !cell.btn.isSelected
                    Observable.just(MainReactor.Action.setSelectedChargerTypeFilter((obj.types[index], cell.btn.isSelected)))
                        .bind(to: _reactor.action)
                        .disposed(by: obj.disposeBag)
                }.disposed(by: self.disposeBag)
            
            _reactor.state.compactMap { $0.selectedChargerTypeFilter }
                .asDriver(onErrorJustReturn: MainReactor.SelectedChargerTypeFilter(chargerType: types[index], isSelected: false))
                .drive(with: self) { obj, selectedChargerFilter in
                    guard selectedChargerFilter.chargerType == obj.types[index] else { return }
                    let isSelected = selectedChargerFilter.isSelected
                    cell.titleLbl.textColor = isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
                    cell.imgView.tintColor = isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
                    cell.totalView.backgroundColor = isSelected ? Colors.backgroundPositiveLight.color : Colors.backgroundPrimary.color
                    cell.totalView.borderColor = isSelected ? Colors.borderPositive.color : Colors.nt1.color
                    
                    FilterManager.sharedInstance.saveTypeFilter(index: obj.types[index].index, val: isSelected)
                }
                .disposed(by: self.disposeBag)
        }
        
        /* cell에 리액터 주입 안 한 이유:
         * NewTagListViewCell은 상단필터의 충전기타입 필터 뿐만 아니라 필터 상세의 회사필터에도 적용되는데,
         * 각각 충전기타입과 회사타입에 대한 바인드 함수를 따로 정의하기 위해 cell안에 리액터 주입을 안함.
         */

        return cell
    }
}

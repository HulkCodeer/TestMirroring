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

enum RoadType: CaseIterable {
    typealias Property = (image: UIImage?, imgUnSelectColor: UIColor?, imgSelectColor: UIColor?)
    
    case general
    case highwayUp
    case highwayDown
    
    internal var typeImageProperty: Property? {
        switch self {
        case .general:
            return (image: Icons.iconGeneralRoad.image, imgUnSelectColor: Colors.contentTertiary.color, imgSelectColor: Colors.contentPositive.color)
        case .highwayUp:
            return (image: Icons.iconHighwayTop.image, imgUnSelectColor: Colors.contentTertiary.color, imgSelectColor: Colors.contentPositive.color)
        case .highwayDown:
            return (image: Icons.iconHighwayBottom.image, imgUnSelectColor: Colors.contentTertiary.color, imgSelectColor: Colors.contentPositive.color)
        }
    }
    
    internal var typeTitle: String {
        switch self {
        case .general: return "일반도로"
        case .highwayUp: return "고속도로(상)"
        case .highwayDown: return "고속도로(하)"
        }
    }
}

internal final class NewFilterRoadView: UIView {
    
    // MARK: UI
    private lazy var totalView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
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
    private weak var mainReactor: MainReactor?
    internal weak var delegate: DelegateFilterChange?
    internal var saveOnChange: Bool = false
    
    // MARK: FUNC
    
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
    
    func bind(reactor: MainReactor) {
        self.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
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
            $0.leading.equalTo(totalView.snp.leading).offset(16)
            $0.trailing.equalTo(totalView.snp.trailing).offset(-16)
            $0.bottom.equalTo(totalView.snp.bottom).offset(-20)
            $0.height.equalTo(68)
        }
        
        for roadType in RoadType.allCases {
            stackView.addArrangedSubview(self.createRoadTypeView(roadType, reactor: reactor))
        }
    }
    
    private func createRoadTypeView(_ roadType: RoadType, reactor: MainReactor) -> UIView {
        let typeImageProperty = roadType.typeImageProperty ?? (image: nil, imgUnSelectColor: nil, imgSelectColor: nil)
        let imgView = UIImageView().then {
            $0.image = typeImageProperty.image
            $0.tintColor = typeImageProperty.imgUnSelectColor
        }
        
        let titleLbl = UILabel().then {
            $0.text = roadType.typeTitle
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
        
        let isSelectedGeneral = FilterManager.sharedInstance.filter.isGeneralWay
        let isSelectedHighwayUp = FilterManager.sharedInstance.filter.isHighwayUp
        let isSelectedHighwayDown = FilterManager.sharedInstance.filter.isHighwayDown
        
        switch roadType {
        case .general:
            imgView.tintColor = isSelectedGeneral ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            titleLbl.textColor = isSelectedGeneral ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            
            btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    btn.isSelected = !btn.isSelected
                    
                    Observable.just(MainReactor.Action.setSelectedRoadFilter((.general, btn.isSelected)))
                        .bind(to: reactor.action)
                        .disposed(by: obj.disposeBag)
                    
                    obj.delegate?.onChangedFilter(type: .road)
                }
                .disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.selectedRoadFilter }
                .asDriver(onErrorJustReturn: MainReactor.SelectedRoadFilter(roadType: .general, isSelected: false))
                .drive(with: self) { obj, selectedRoadFilter in
                    guard selectedRoadFilter.roadType == .general else { return }
                    let isSelected = selectedRoadFilter.isSelected
                    imgView.tintColor = isSelected ? roadType.typeImageProperty?.imgSelectColor : roadType.typeImageProperty?.imgUnSelectColor
                    titleLbl.textColor = isSelected ? roadType.typeImageProperty?.imgSelectColor : roadType.typeImageProperty?.imgUnSelectColor

                    FilterManager.sharedInstance.saveGeneralRoad(with: isSelected)
                }
                .disposed(by: self.disposeBag)
        case .highwayUp:
            imgView.tintColor = isSelectedHighwayUp ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            titleLbl.textColor = isSelectedHighwayUp ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            
            btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    btn.isSelected = !btn.isSelected
                    
                    Observable.just(MainReactor.Action.setSelectedRoadFilter((.highwayUp, btn.isSelected)))
                        .bind(to: reactor.action)
                        .disposed(by: obj.disposeBag)
                    
                    obj.delegate?.onChangedFilter(type: .road)
                }
                .disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.selectedRoadFilter }
                .asDriver(onErrorJustReturn: MainReactor.SelectedRoadFilter(roadType: .highwayUp, isSelected: false))
                .drive(with: self) { obj, selectedRoadFilter in
                    guard selectedRoadFilter.roadType == .highwayUp else { return }
                    let isSelected = selectedRoadFilter.isSelected
                    imgView.tintColor = isSelected ? roadType.typeImageProperty?.imgSelectColor : roadType.typeImageProperty?.imgUnSelectColor
                    titleLbl.textColor = isSelected ? roadType.typeImageProperty?.imgSelectColor : roadType.typeImageProperty?.imgUnSelectColor

                    FilterManager.sharedInstance.saveHighwayUp(with: isSelected)
                }
                .disposed(by: self.disposeBag)
        case .highwayDown:
            imgView.tintColor = isSelectedHighwayDown ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            titleLbl.textColor = isSelectedHighwayDown ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            
            btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    btn.isSelected = !btn.isSelected
                    Observable.just(MainReactor.Action.setSelectedRoadFilter((.highwayDown, btn.isSelected)))
                        .bind(to: reactor.action)
                        .disposed(by: obj.disposeBag)
                    
                    obj.delegate?.onChangedFilter(type: .road)
                }
                .disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.selectedRoadFilter }
                .asDriver(onErrorJustReturn: MainReactor.SelectedRoadFilter(roadType: .highwayDown, isSelected: false))
                .drive(with: self) { obj, selectedRoadFilter in
                    guard selectedRoadFilter.roadType == .highwayDown else { return }
                    let isSelected = selectedRoadFilter.isSelected
                    imgView.tintColor = isSelected ? roadType.typeImageProperty?.imgSelectColor : roadType.typeImageProperty?.imgUnSelectColor
                    titleLbl.textColor = isSelected ? roadType.typeImageProperty?.imgSelectColor : roadType.typeImageProperty?.imgUnSelectColor

                    FilterManager.sharedInstance.saveHighwayDown(with: isSelected)
                }
                .disposed(by: self.disposeBag)
        }
        
        return view
    }
}

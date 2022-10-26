//
//  NewFilterAccessView.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/10/25.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import EasyTipView

enum AccessType: CaseIterable {
    typealias Property = (image: UIImage?, imgUnSelectColor: UIColor?, imgSelectColor: UIColor?)
    
    case publicCharger
    case nonePublicCharger
    
    internal var typeImageProperty: Property? {
        switch self {
        case .publicCharger:
            return (image: Icons.iconAccessPublic.image, imgUnSelectColor: Colors.contentTertiary.color, imgSelectColor: Colors.contentPositive.color)
        case .nonePublicCharger:
            return (image: Icons.iconAccessNonpublic.image, imgUnSelectColor: Colors.contentTertiary.color, imgSelectColor: Colors.contentPositive.color)
        }
    }
    
    internal var typeTilte: String {
        switch self {
        case .publicCharger: return "개방 충전소"
        case .nonePublicCharger: return "비개방 충전소"
        }
    }
}

internal final class NewFilterAccessView: UIView {
    // MARK: UI
    private lazy var totalView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
    private lazy var filterTitleLbl = UILabel().then {
        $0.text = "접근"
        $0.font = .systemFont(ofSize: 14, weight: .bold)
    }
    
    private lazy var infoBtn = UIButton().then {
        $0.setImage(Icons.iconInfoSm.image, for: .normal)
        $0.tintColor = Colors.contentTertiary.color
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
            $0.edges.equalToSuperview()
        }
        
        totalView.addSubview(filterTitleLbl)
        filterTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(16)
        }
        
        totalView.addSubview(infoBtn)
        infoBtn.snp.makeConstraints {
            $0.leading.equalTo(filterTitleLbl.snp.trailing).offset(12)
            $0.centerY.equalTo(filterTitleLbl.snp.centerY)
            $0.width.height.equalTo(20)
        }
        
        totalView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(filterTitleLbl.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(68)
        }
        
        for accessType in AccessType.allCases {
            stackView.addArrangedSubview(self.createAccessTypeView(accessType, reactor: reactor))
        }
        
        infoBtn.rx.tap
            .asDriver()
            .drive(with: self) { obj, _ in
                obj.infoBtn.isSelected = !obj.infoBtn.isSelected
                guard !obj.infoBtn.isSelected else { return }
                
                var preferences = EasyTipView.Preferences()
                preferences.drawing.backgroundColor = Colors.contentSecondary.color
                preferences.drawing.foregroundColor = Colors.backgroundSecondary.color
                preferences.drawing.textAlignment = .center
                
                preferences.drawing.arrowPosition = .left
                
                preferences.animating.dismissTransform = CGAffineTransform(translationX: -30, y: -100)
                preferences.animating.showInitialTransform = CGAffineTransform(translationX: 30, y: 100)
                preferences.animating.showInitialAlpha = 0
                preferences.animating.showDuration = 1
                preferences.animating.dismissDuration = 1
                
                let text = "비개방충전소: 충전소 설치 건물 거주/이용/관계자 외엔 사용이 불가한 곳"
                EasyTipView.show(forView: obj.infoBtn,
                                 withinSuperview: obj,
                                 text: text,
                                 preferences: preferences)
            }.disposed(by: self.disposeBag)
    }
    
    private func createAccessTypeView(_ accessType: AccessType, reactor: MainReactor) -> UIView {
        let typeImageProperty = accessType.typeImageProperty ?? (image: nil, imgUnSelectColor: nil, imgSelectColor: nil)
        let imgView = UIImageView().then {
            $0.image = typeImageProperty.image
            $0.tintColor = typeImageProperty.imgUnSelectColor
        }
        
        let titleLbl = UILabel().then {
            $0.text = accessType.typeTilte
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
            }

            $0.addSubview(btn)
            btn.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        guard let selectedAccessFilter = reactor.currentState.selectedAccessFilter else { return view }
        
        let isSelectedPublic = selectedAccessFilter.accessType == .publicCharger ? selectedAccessFilter.isSelected : false
        let isSelectedNonPublic = selectedAccessFilter.accessType == .nonePublicCharger ? selectedAccessFilter.isSelected : false
        let access = selectedAccessFilter.accessType
        
        switch access {
        case .publicCharger:
            imgView.tintColor = isSelectedPublic ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            titleLbl.textColor = isSelectedPublic ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            
            btn.isSelected = isSelectedPublic
            
            btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    btn.isSelected = !btn.isSelected
                    if obj.saveOnChange {
                        Observable.just(MainReactor.Action.setSelectedAccessFilter((.publicCharger, btn.isSelected)))
                            .bind(to: reactor.action)
                            .disposed(by: obj.disposeBag)
                    }
                }.disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.selectedAccessFilter }
                .asDriver(onErrorJustReturn: MainReactor.SelectedAccessFilter(accessType: .publicCharger, isSelected: false))
                .drive(with: self) { obj, selectedFilter in
                    guard selectedFilter.accessType == .publicCharger else { return }
                    let isSelected = selectedFilter.isSelected
                    imgView.tintColor = isSelected ? accessType.typeImageProperty?.imgSelectColor : accessType.typeImageProperty?.imgUnSelectColor
                    titleLbl.textColor = isSelected ? accessType.typeImageProperty?.imgSelectColor : accessType.typeImageProperty?.imgUnSelectColor
                    
                    FilterManager.sharedInstance.savePublic(with: isSelected)
                }.disposed(by: self.disposeBag)
        case .nonePublicCharger:
            imgView.tintColor = isSelectedNonPublic ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            titleLbl.textColor = isSelectedNonPublic ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
            
            btn.isSelected = isSelectedNonPublic
            
            btn.rx.tap
                .asDriver()
                .drive(with: self) { obj, _ in
                    btn.isSelected = !btn.isSelected
                    if obj.saveOnChange {
                        Observable.just(MainReactor.Action.setSelectedAccessFilter((.nonePublicCharger, btn.isSelected)))
                            .bind(to: reactor.action)
                            .disposed(by: obj.disposeBag)
                    }
                }.disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.selectedAccessFilter }
                .asDriver(onErrorJustReturn: MainReactor.SelectedAccessFilter(accessType: .nonePublicCharger, isSelected: false))
                .drive(with: self) { obj, selectedFilter in
                    guard selectedFilter.accessType == .nonePublicCharger else { return }
                    let isSelected = selectedFilter.isSelected
                    imgView.tintColor = isSelected ? accessType.typeImageProperty?.imgSelectColor : accessType.typeImageProperty?.imgUnSelectColor
                    titleLbl.textColor = isSelected ? accessType.typeImageProperty?.imgSelectColor : accessType.typeImageProperty?.imgUnSelectColor
                    
                    FilterManager.sharedInstance.saveNonPublic(with: isSelected)
                }.disposed(by: self.disposeBag)
        }
        
        return view
    }
}

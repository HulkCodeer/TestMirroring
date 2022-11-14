//
//  BottomMenuView.swift
//  evInfra
//
//  Created by youjin kim on 2022/11/02.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

import Then
import RxCocoa
import SnapKit
import RxSwift

internal final class BottomMenuItem: UIView {
    
    private lazy var icon = UIImageView().then {
        $0.tintColor = Colors.contentTertiary.color
        $0.contentMode = .scaleAspectFill
    }
    private lazy var titleLabel = UILabel().then {
        $0.textColor = Colors.contentTertiary.color
        $0.font = .systemFont(ofSize: 11, weight: .semibold)
    }
    
    internal lazy var button = UIButton().then {
        $0.isExclusiveTouch = true
    }
    
    internal var disposeBag = DisposeBag()
    private let menuType: MainReactor.BottomMenuType
    
    init(menuType: MainReactor.BottomMenuType, reactor: MainReactor) {
        self.menuType = menuType
        super.init(frame: .zero)
        
        bind(reactor: reactor)
        
        icon.image = menuType.value.icon
        titleLabel.text = menuType.value.title
        
        let iconTopPadding: CGFloat = 10
        let labelTopPadding: CGFloat = 4
        
        let iconWidth: CGFloat = 32
        let iconHeight: CGFloat = 24
        
 
        self.addSubview(icon)
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(iconTopPadding)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(iconHeight)
            $0.width.equalTo(iconWidth)
        }
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(icon.snp.bottom).offset(labelTopPadding)
            $0.centerX.equalToSuperview()
        }
        
        self.addSubview(button)
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.menuType = .qrCharging
        super.init(coder: aDecoder)
        
        fatalError()
    }
    
    private func bind(reactor: MainReactor) {
        switch menuType {
        case .qrCharging:
            reactor.state.compactMap { $0.isCharging }
                .asDriver(onErrorJustReturn: true)
                .drive(with: self) { obj, isCharging in
                    guard let specificValue = obj.menuType.specificValue else { return }
                    let value = isCharging ? specificValue : obj.menuType.value

                    obj.icon.image = value.icon
                    obj.titleLabel.text = value.title
                }
                .disposed(by: disposeBag)
        case .evPay:
            reactor.state.compactMap { $0.isAccountsReceivable }
                .asDriver(onErrorJustReturn: true)
                .drive(with: self) { obj, isAccountsReceivable in
                    guard let icon = obj.menuType.accountsReceivableIcon else { return }
                    obj.icon.image = icon
                }
                .disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.hasEVPayCard }
                .asDriver(onErrorJustReturn: false)
                .drive(with: self) { owner, hasEVPayCard in
                    guard let specificValue = owner.menuType.specificValue else { return }
                    let value = hasEVPayCard ? owner.menuType.value : specificValue
                    
                    owner.icon.image = value.icon
                    owner.titleLabel.text = value.title
                }
                .disposed(by: disposeBag)
            
        default:
            break
        }

    }

}

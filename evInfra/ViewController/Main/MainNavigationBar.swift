//
//  MainNavigationBar.swift
//  evInfra
//
//  Created by youjin kim on 2022/09/26.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

import Then
import RxCocoa
import SnapKit

internal final class MainNavigationBar: UIView {
    private let contentStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .fill
        $0.spacing = 8
    }
    
    internal let menuButton = UIButton()
    internal let searchChargeButton = UIButton()
    internal let searchWayButton = UIButton()
    internal let cancelSearchWayButton = UIButton()
    
    internal var height: CGFloat {
        get {
            return 54
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setUI() {
        self.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(menuButton)
        contentStackView.addArrangedSubview(searchChargeButton)
        contentStackView.addArrangedSubview(searchWayButton)
        
        let verticalPadding: CGFloat = 8
        let itemSize: CGFloat = 40
        
        contentStackView.snp.makeConstraints {
            $0.height.equalTo(itemSize)
            $0.leading.trailing.equalToSuperview().inset(verticalPadding)
            $0.centerY.equalToSuperview()
        }
        
        menuButton.snp.makeConstraints {
            $0.width.equalTo(itemSize)
        }
        
        searchWayButton.snp.makeConstraints {
            $0.width.equalTo(itemSize)
        }
        
    }

}

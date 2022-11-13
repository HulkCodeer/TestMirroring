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
    private lazy var contentStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .fill
        $0.spacing = 8
    }
    
    internal lazy var menuButton = UIButton().then {
        let image = UIImage(asset: Icons.iconMenuMd)
        $0.setImage(image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFill
        $0.isExclusiveTouch = true
    }
    
    // 충전소 검색
    internal lazy var searchChargeButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.isExclusiveTouch = true
    }
    private lazy var searchChargeContentsView = UIView().then {
        $0.backgroundColor = Colors.nt0.color
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }
    private lazy var searchChargeIcon = UIImageView().then {
        $0.image = UIImage(asset: Icons.iconSearchMd)
        $0.tintColor = Colors.contentTertiary.color
        $0.contentMode = .scaleAspectFill
    }
    private lazy var searchChargeText = UILabel().then {
        $0.text = "어디서 충전할까요?"
        $0.textColor = Colors.nt4.color
        $0.font = .systemFont(ofSize: 16)
    }
    
    // 길찾기 button
    private lazy var searchWayContentView = UIView()
    
    internal lazy var searchWayButton = UIButton().then {
        let image = UIImage(asset: Icons.iconMapCourseMd)?
            .withTintColor(Colors.contentPrimary.color)
        $0.setImage(image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFill
        $0.isExclusiveTouch = true
    }
    internal lazy var cancelSearchWayButton = UIButton().then {
        let image = UIImage(asset: Icons.iconCloseLg)
        $0.tintColor = Colors.contentTertiary.color
        $0.setImage(image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFill
        $0.isHidden = true
        $0.isExclusiveTouch = true
    }
    
    internal var height: CGFloat {
        get {
            return 54
        }
    }
    
    // MARK: - initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = Colors.backgroundPrimary.color
        
        let verticalPadding: CGFloat = 8
        let searchChargeInset: CGFloat = 10
        
        let itemSize: CGFloat = 40
        let searchChargeIconSize: CGFloat = 20
        
        self.addSubview(contentStackView)
        contentStackView.snp.makeConstraints {
            $0.height.equalTo(itemSize)
            $0.leading.trailing.equalToSuperview().inset(verticalPadding)
            $0.bottom.equalToSuperview().inset(4)
        }
        
        contentStackView.addArrangedSubview(menuButton)
        menuButton.snp.makeConstraints {
            $0.width.equalTo(itemSize)
        }
        contentStackView.addArrangedSubview(searchChargeContentsView)
        contentStackView.addArrangedSubview(searchWayContentView)
        searchWayContentView.snp.makeConstraints {
            $0.width.equalTo(itemSize)
        }
        
        searchChargeContentsView.addSubview(searchChargeIcon)
        searchChargeIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(searchChargeInset)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(searchChargeIconSize)
        }
        searchChargeContentsView.addSubview(searchChargeText)
        searchChargeText.snp.makeConstraints {
            $0.leading.equalTo(searchChargeIcon.snp.trailing).offset(searchChargeInset)
            $0.centerY.equalToSuperview()
        }
        searchChargeContentsView.addSubview(searchChargeButton)
        searchChargeButton.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        searchWayContentView.addSubview(searchWayButton)
        searchWayButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        searchWayContentView.addSubview(cancelSearchWayButton)
        cancelSearchWayButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Action
    
    func setMenuBadge(hasBadge: Bool) {
        let image = hasBadge ? UIImage(asset: Icons.iconMenuBadge) : UIImage(asset: Icons.iconMenuMd)
        menuButton.setImage(image, for: .normal)
    }

    func hideSearchWayMode(_ hideSearch: Bool) {
        searchWayButton.isHidden = !hideSearch
        cancelSearchWayButton.isHidden = hideSearch
    }
}
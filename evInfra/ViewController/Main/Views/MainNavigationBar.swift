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
    }
    
    // 충전소 검색
    internal lazy var searchChargeButton = UIButton().then {
        $0.backgroundColor = .clear
    }
    private lazy var searchChargeContentsView = UIView().then {
        $0.backgroundColor = Colors.nt0.color
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }
    private lazy var searchChargeIcon = UIImageView().then {
        $0.image = UIImage(asset: Icons.iconSearchMd)?
            .withTintColor(Colors.contentTertiary.color)
        $0.contentMode = .scaleAspectFill
    }
    private lazy var searchChargeText = UILabel().then {
        $0.text = "어디서 충전할까요?"
        $0.textColor = Colors.nt4.color
        $0.font = .systemFont(ofSize: 16)
    }
    
    // 길찾기 button
    internal lazy var searchWayButton = UIButton().then {
        let image = UIImage(asset: Icons.iconMapCourseMd)?
            .withTintColor(Colors.contentPrimary.color)
        $0.setImage(image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFill
    }
    internal lazy var cancelSearchWayButton = UIButton().then {
        let image = UIImage(asset: Icons.iconCloseLg)?
            .withTintColor(Colors.contentTertiary.color)
        $0.setImage(image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFill
        $0.isHidden = true
    }
    
    internal var height: CGFloat {
        get {
            return 54
        }
    }
    
    // MARK: - initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - makeUI
    
    private func setUI() {
        self.backgroundColor = Colors.backgroundPrimary.color
        
        self.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(menuButton)
        contentStackView.addArrangedSubview(searchChargeContentsView)
        contentStackView.addArrangedSubview(searchWayButton)
        contentStackView.addArrangedSubview(cancelSearchWayButton)
        
        searchChargeContentsView.addSubview(searchChargeIcon)
        searchChargeContentsView.addSubview(searchChargeText)
        searchChargeContentsView.addSubview(searchChargeButton)
    }
    
    private func setConstraints() {
        let verticalPadding: CGFloat = 8
        let searchChargeInset: CGFloat = 10
        
        let itemSize: CGFloat = 40
        let searchChargeIconSize: CGFloat = 20
        
        contentStackView.snp.makeConstraints {
            $0.height.equalTo(itemSize)
            $0.leading.trailing.equalToSuperview().inset(verticalPadding)
            $0.bottom.equalToSuperview().inset(4)
        }
        
        menuButton.snp.makeConstraints {
            $0.width.equalTo(itemSize)
        }
        searchWayButton.snp.makeConstraints {
            $0.width.equalTo(itemSize)
        }
        cancelSearchWayButton.snp.makeConstraints {
            $0.width.equalTo(itemSize)
        }
        
        searchChargeIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(searchChargeInset)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(searchChargeIconSize)
        }
        searchChargeText.snp.makeConstraints {
            $0.leading.equalTo(searchChargeIcon.snp.trailing).offset(searchChargeInset)
            $0.centerY.equalToSuperview()
        }
        searchChargeButton.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
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

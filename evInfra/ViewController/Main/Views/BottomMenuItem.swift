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

internal final class BottomMenuItem: UIView {
    private lazy var icon = UIImageView().then {
        $0.tintColor = Colors.contentTertiary.color
        $0.contentMode = .scaleAspectFill
    }
    private lazy var titleLabel = UILabel().then {
        $0.textColor = Colors.contentTertiary.color
        $0.font = .systemFont(ofSize: 11)
    }
    internal lazy var button = UIButton()
    
    init(icon image: UIImage, title: String) {
        super.init(frame: .zero)
        
        icon.image = image
        titleLabel.text = title
        
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
        super.init(coder: aDecoder)
    }
    
}

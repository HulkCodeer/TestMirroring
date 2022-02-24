//
//  EmptyTableViewCell.swift
//  evInfra
//
//  Created by PKH on 2022/02/23.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit

class EmptyTableViewCell: UITableViewCell {
    lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var warningImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "iconCommentLg")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var warningLabel: UILabel = {
       let label = UILabel()
        label.text = "첫 댓글의 주인공이 되어주세요."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(named: "nt-5")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    var isSearchViewType: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    
    private func setUI() {
        self.addSubview(containerStackView)
        containerStackView.backgroundColor = UIColor(named: "nt-white")
        containerStackView.addArrangedSubview(warningImageView)
        containerStackView.addArrangedSubview(warningLabel)
        
        containerStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.right.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(72)
        }
        
        warningImageView.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }
        
        warningLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(50)
            $0.trailing.equalToSuperview().offset(-50)
            $0.height.equalTo(36)
        }
    }
    
    func configure(isSearchViewType: Bool) {
        if isSearchViewType {
            warningImageView.image = UIImage(named: "iconExclamationCircleLg")
            warningLabel.text = "검색결과가 없습니다.\n입력하신 검색어를 확인해주세요."
        } else {
            
        }
    }
}

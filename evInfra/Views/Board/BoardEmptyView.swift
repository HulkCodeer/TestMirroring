//
//  BoardEmptyView.swift
//  evInfra
//
//  Created by PKH on 2022/01/26.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit

class BoardEmptyView: UIView {
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "iconCommentLg")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var label: UILabel = {
       let label = UILabel()
        label.text = "첫 댓글의 주인공이 되어주세요."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(named: "nt-5")
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    
    private func setUI() {

        self.addSubview(stackView)
        stackView.backgroundColor = UIColor(named: "nt-white")
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(64)
            $0.left.right.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }
        
        label.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(16)
        }
    }
}

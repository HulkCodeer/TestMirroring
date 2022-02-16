//
//  SearchTypeSelectView.swift
//  evInfra
//
//  Created by PKH on 2022/02/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit

class SearchTypeSelectView: UIView {
    
    lazy var containerStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.contentMode = .left
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 16
        return stackView
    }()
    
    lazy var titleWithContentButton: UIButton = {
       let button = UIButton()
        button.setTitle("제목+내용", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        button.setTitleColor(UIColor(named: "nt-black"), for: .normal)
        button.setImage(UIImage(named: "iconRadioSelected"), for: .normal)
        button.setImage(UIImage(named: "iconRadioUnselected"), for: .selected)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        return button
    }()
    
    lazy var writerButton: UIButton = {
        let button = UIButton()
        button.setTitle("작성자", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        button.setTitleColor(UIColor(named: "nt-black"), for: .normal)
        button.setImage(UIImage(named: "iconRadioSelected"), for: .selected)
        button.setImage(UIImage(named: "iconRadioUnselected"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        return button
    }()
    
    lazy var spacerView: UIView = {
       let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    var buttonGroup: [UIButton] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUI() {
        self.backgroundColor = UIColor(named: "nt-0")
        buttonGroup.append(titleWithContentButton)
        buttonGroup.append(writerButton)
        
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(titleWithContentButton)
        containerStackView.addArrangedSubview(writerButton)
        containerStackView.addArrangedSubview(spacerView)
        
        containerStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(24)
        }
    }
    
    @objc func butttonTapped() {
        
    }
}

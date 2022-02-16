//
//  SearchBarView.swift
//  evInfra
//
//  Created by PKH on 2022/02/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit

class SearchBarView: UIView {
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()
    
    lazy var searchButton: UIButton = {
       let button = UIButton()
        button.setTitle("찾기", for: .normal)
        button.setTitleColor(UIColor(named: "nt-9"), for: .normal)
        button.setTitleColor(UIColor(named:"nt-3"), for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUI() {
        backgroundColor = UIColor(named: "nt-white")
        layer.borderWidth = 0
//        searchBar.delegate = self
        searchBar.clipsToBounds = true
        
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor(named: "nt-white")
            textfield.layer.borderColor = UIColor(named: "nt-2")?.cgColor
            textfield.layer.borderWidth = 1
            textfield.layer.cornerRadius = 4
            textfield.snp.makeConstraints {
                $0.top.equalToSuperview().offset(16)
                $0.left.equalToSuperview().offset(16)
                $0.right.equalToSuperview().offset(-86)
                $0.bottom.equalToSuperview().offset(-16)
            }
            
            if let leftImageView = textfield.leftView as? UIImageView {
                leftImageView.image = UIImage(named: "iconSearchSm")?.withAlignmentRectInsets(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 4))
                leftImageView.tintColor = UIColor(named: "nt-9")
            }
        }

        searchBar.placeholder = "검색어를 입력해주세요."
        
        searchButton.layer.cornerRadius = 6
        searchButton.backgroundColor = UIColor(named: "gr-5")
        
        addSubview(searchBar)
        searchBar.addSubview(searchButton)
        
        searchBar.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        searchButton.snp.makeConstraints {
            $0.width.equalTo(62)
            $0.height.equalTo(40)
            $0.top.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}

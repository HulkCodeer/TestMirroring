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
        searchBar.setImage(UIImage(named: "iconSearchSm"), for: .search, state: .normal)
        searchBar.setImage(UIImage(named: "iconCloseSm"), for: .clear, state: .normal)
        searchBar.clipsToBounds = true
        searchBar.layer.borderColor = UIColor(named: "nt-2")?.cgColor
        searchBar.layer.borderWidth = 2
        searchBar.layer.cornerRadius = 4
        searchBar.placeholder = "검색어를 입력해주세요."
        return searchBar
    }()
    
    lazy var searchButton: UIButton = {
       let button = UIButton()
        button.setTitle("찾기", for: .normal)
        button.setTitleColor(UIColor(named: "nt-9"), for: .normal)
        button.setTitleColor(UIColor(named:"nt-3"), for: .disabled)
        button.setBackgroundColor(UIColor(named:"gr-5")!, for: .normal)
        button.setBackgroundColor(UIColor(named:"nt-0")!, for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.layer.cornerRadius = 6
        button.isEnabled = false
        button.clipsToBounds = true
        return button
    }()
    
    var searchButtonCompletion: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUI()
    }
    
    private func setUI() {
        backgroundColor = UIColor(named: "nt-white")
        layer.borderWidth = 0

        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor(named: "nt-white")
            textfield.addTarget(self, action: #selector(textfiledDidChange(textField:)), for: .editingChanged)
            textfield.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.leading.equalToSuperview().offset(6)
                $0.trailing.equalToSuperview().offset(-6)
                $0.bottom.equalToSuperview()
            }

            if let leftImageView = textfield.leftView as? UIImageView {
                leftImageView.tintColor = UIColor(named: "nt-9")
            }
            
            if let rightImageView = textfield.rightView as? UIImageView {
                rightImageView.tintColor = UIColor(named: "nt-9")
            }
        }
        
        addSubview(searchBar)
        addSubview(searchButton)
        
        searchBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(searchButton.snp.leading).offset(-8)
        }
        
        searchButton.snp.makeConstraints {
            $0.width.equalTo(62)
            $0.height.equalTo(40)
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalTo(searchBar.snp.trailing).offset(8)
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
}

extension SearchBarView {
    @objc func textfiledDidChange(textField: UITextField) {
        guard let text = textField.text else { return }
        
        searchButton.isEnabled = !text.isEmpty
        
        if text.isEmpty {
            searchBar.layer.borderColor = UIColor(named: "nt-2")?.cgColor
        } else {
            searchBar.layer.borderColor = UIColor(named: "nt-9")?.cgColor
        }
    }
    
    @objc func searchButtonTapped() {
        guard let keyword = searchBar.text else { return }
        searchButtonCompletion?(keyword)
    }
}


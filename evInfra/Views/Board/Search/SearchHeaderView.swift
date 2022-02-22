//
//  SearchHeaderView.swift
//  evInfra
//
//  Created by PKH on 2022/02/17.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit

class SearchHeaderView: UITableViewHeaderFooterView {
    
    weak var delegate: RecentKeywordTableViewCellDelegate?
    
    lazy var headerStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 4
        return stackView
    }()
    
    lazy var headerTitleLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor(named: "nt-9")
        label.text = "이전 검색어"
        return label
    }()
    
    lazy var allDeleteButton: UIButton = {
       let button = UIButton()
        button.setTitle("전체삭제", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        button.setTitleColor(UIColor(named: "nt-5"), for: .normal)
        button.addTarget(self, action: #selector(deleteAllKeyword), for: .touchUpInside)
        return button
    }()
    
    private var isSearching: Bool = false
    private var countOfDatas = 0
    
    convenience init(_ isSearching: Bool, _ countOfDatas: Int) {
        self.init()
        self.isSearching = isSearching
        self.countOfDatas = countOfDatas
        
        setUI()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
   
    private func setUI() {
        addSubview(headerStackView)
        
        [headerTitleLabel, allDeleteButton].forEach {
            headerStackView.addArrangedSubview($0)
        }
        
        headerStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-20)
            $0.height.equalTo(16)
        }
        
        headerTitleLabel.snp.makeConstraints {
            $0.height.equalTo(16)
        }
        
        allDeleteButton.setContentHuggingPriority(UILayoutPriority(751), for: .horizontal)
        allDeleteButton.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
        
        if isSearching {
            allDeleteButton.isHidden = true
            headerTitleLabel.text = "검색결과 \(countOfDatas)건"
        } else {
            allDeleteButton.isHidden = false
            headerTitleLabel.text = "이전 검색어"
        }
    }
    
    @objc func deleteAllKeyword(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.deleteButtonTapped(row: nil)
        }
    }
}

//
//  RecentKeywordTableViewCell.swift
//  evInfra
//
//  Created by PKH on 2022/02/17.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit

class RecentKeywordTableViewCell: UITableViewCell {
    
    weak var delegate: RecentKeywordTableViewCellDelegate?
    var index: Int? = 0
    
    lazy var containerStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 4
        return stackView
    }()
    
    lazy var keywordTitleLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(named: "nt-black")
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = UIColor(named:"nt-5")
        return label
    }()
    
    lazy var deleteButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "iconDeleteKeyword"), for: .normal)
        button.addTarget(self, action: #selector(deleteKeyword(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func setUI() {
        self.selectionStyle = .none
        contentView.addSubview(containerStackView)
        
        [keywordTitleLabel,
         dateLabel,
         deleteButton]
            .forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-8)
            $0.bottom.equalToSuperview().offset(-8)
            $0.height.equalTo(32)
        }
        
        deleteButton.snp.makeConstraints {
            $0.width.equalTo(32)
            $0.height.equalTo(32)
        }
        
        dateLabel.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
        deleteButton.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
    }
    
    func configure(item: Keyword) {
        let keyword = item.title
        if let date = item.date {
            dateLabel.text = " \(DateUtils.getTimesAgoString(date: date))"
        }
        keywordTitleLabel.text = keyword
    }
    
    @objc func deleteKeyword(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.deleteButtonTapped(row: index)
        }
    }
}

struct Keyword: Codable {
    var title: String?
    var date: String?
}

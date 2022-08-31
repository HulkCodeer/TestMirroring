//
//  NewNoticeTableViewCell.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/30.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

import Then
import SnapKit

final class NewNoticeTableViewCell: CommonBaseTableViewCell {
    
    private lazy var titleLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = Colors.contentPrimary.color
    }
    private lazy var dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = Colors.nt4.color
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUI()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        
        let verticalMargin: CGFloat = 20
        let horizontalMargin: CGFloat = 16
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(verticalMargin)
            $0.leading.trailing.equalToSuperview().inset(horizontalMargin)
//            $0.bottom.equalTo(contentView.snp.centerY)
        }
        dateLabel.snp.makeConstraints {
//            $0.top.equalTo(contentView.snp.centerY)
            $0.bottom.equalToSuperview().inset(verticalMargin)
            $0.leading.trailing.equalTo(titleLabel)
        }
    }
    
    
    func configure(title: String, date: String) {
        titleLabel.text = title
        dateLabel.text = date
    }
}

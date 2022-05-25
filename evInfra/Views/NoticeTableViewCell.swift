//
//  NoticeTableViewCell.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 20..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import SnapKit
import Then

internal class NoticeTableViewCell: UITableViewCell {

    lazy var noticeTitleLbl = UILabel().then {
        $0.fontSize = 17
        $0.textColor = UIColor(named: "content-primary")
    }
    
    lazy var dateTimeLbl = UILabel().then {
        $0.fontSize = 14
        $0.textColor = UIColor(named: "content-secondary")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attribute() {
        selectionStyle = .none
    }
    
    private func layout() {
        [noticeTitleLbl, dateTimeLbl].forEach {
            contentView.addSubview($0)
        }
        
        noticeTitleLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.trailing.equalToSuperview().inset(12)
            $0.top.equalToSuperview().inset(8)
            $0.bottom.equalTo(dateTimeLbl.snp.top).offset(-8)
            $0.height.equalTo(20)
        }
        
        dateTimeLbl.snp.makeConstraints {
            $0.leading.lessThanOrEqualToSuperview().inset(320)
            $0.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(8)
            $0.height.equalTo(20)
        }
    }
}


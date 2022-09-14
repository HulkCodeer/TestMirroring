//
//  NewNoticeTableViewCell.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/30.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

import Then
import ReactorKit
import RxCocoa
import SnapKit

final class NewNoticeTableViewCell: CommonBaseTableViewCell, ReactorKit.View  {
    internal var disposeBag = DisposeBag()
    
    private lazy var contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 4
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = Colors.contentPrimary.color
    }
    private lazy var dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = Colors.nt4.color
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = String()
        dateLabel.text = String()
        disposeBag = DisposeBag()
    }
    
    internal func bind(reactor: NoticeCellReactor) {
        reactor.state.map { $0.title }
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.date }
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    override func makeUI() {
        self.selectionStyle = .none
        
        contentView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(dateLabel)
                
        let verticalMargin: CGFloat = 20
        let horizontalMargin: CGFloat = 16
        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(verticalMargin)
            $0.bottom.equalToSuperview().inset(verticalMargin)
            $0.leading.trailing.equalTo(horizontalMargin).inset(horizontalMargin)
        }

    }

}

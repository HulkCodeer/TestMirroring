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
    var disposeBag = DisposeBag()
    
    private let wrappingButton = UIButton()
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
        wrappingButton.rx.tap
            .map { _ in NoticeCellReactor.Action.moveDetailView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    override func makeUI() {
        contentView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(dateLabel)
        
        contentView.addSubview(wrappingButton)
        
        let verticalMargin: CGFloat = 20
        let horizontalMargin: CGFloat = 16
        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(verticalMargin)
            $0.bottom.equalToSuperview().inset(verticalMargin)
            $0.leading.trailing.equalTo(horizontalMargin).inset(horizontalMargin)
        }

        wrappingButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(title: String, date: String) {
        titleLabel.text = title
        dateLabel.text = date
    }
}

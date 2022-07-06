//
//  NoticeTableViewCell.swift
//  evInfra
//
//  Created by pkh on 2022/06/03.
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import SnapKit
import Then
import ReactorKit

internal class NoticeCell: UITableViewCell, ReactorKit.View {
    internal var disposeBag = DisposeBag()
    
    private lazy var cellButton = UIButton().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var noticeTitleLbl = UILabel().then {
        $0.fontSize = 17
        $0.textColor = UIColor(named: "content-primary")
    }
    
    private lazy var dateTimeLbl = UILabel().then {
        $0.fontSize = 14
        $0.textColor = UIColor(named: "content-secondary")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        makeUI()
    }
    
    private func makeUI() {
        contentView.addSubview(dateTimeLbl)
        dateTimeLbl.snp.makeConstraints {
            $0.leading.lessThanOrEqualToSuperview().inset(320)
            $0.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(8)
            $0.height.equalTo(20)
        }
        
        contentView.addSubview(noticeTitleLbl)
        noticeTitleLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.trailing.equalToSuperview().inset(12)
            $0.top.equalToSuperview().inset(8)
            $0.bottom.equalTo(dateTimeLbl.snp.top).offset(-8)
            $0.height.equalTo(20)
        }
        
        contentView.addSubview(cellButton)
        cellButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    internal func bind(reactor: NoticeCellReactor<NoticeListDataModel.NoticeInfo>) {
        
        reactor.state.compactMap {
            $0.model.title
        }.bind(to: noticeTitleLbl.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap {
            $0.model.datetime
        }.bind(to: dateTimeLbl.rx.text)
            .disposed(by: disposeBag)
        
        cellButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive { _ in
                guard let boardId = Int(reactor.currentState.model.id) else { return }
                let noticeDetailReactor = NoticeDetailReactor(provider: RestApi())
                noticeDetailReactor.boardId = boardId
                let noticeDetailViewController = NoticeDetailViewController()
                noticeDetailViewController.reactor = noticeDetailReactor
                
                GlobalDefine.shared.mainNavi?.push(viewController: noticeDetailViewController)
            }.disposed(by: disposeBag)
    }
}


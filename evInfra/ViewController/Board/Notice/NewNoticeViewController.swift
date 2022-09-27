//
//  NewNoticeViewController.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/25.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import WebKit

import Then
import ReactorKit
import ReusableKit
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit
import WebKit

final class NewNoticeViewController: CommonBaseViewController, StoryboardView {
    typealias NoticeDataSource = RxTableViewSectionedReloadDataSource<NoticeSectionModel>
    private enum Reusable {
        static let noticeListCell = ReusableCell<NewNoticeTableViewCell>()
    }
    
    private lazy var customNaviBar = CommonNaviView().then {
        $0.naviTitleLbl.text = "EV Infra 공지사항"
    }
    
    private lazy var noticeTableView = UITableView().then {
        $0.register(Reusable.noticeListCell)
        $0.rowHeight = UITableView.automaticDimension 
        $0.estimatedRowHeight = 91
        $0.isMultipleTouchEnabled = false
        $0.allowsMultipleSelection = false
        $0.allowsMultipleSelectionDuringEditing = false
    }
    
    private let dataSource = NoticeDataSource(configureCell: { dataSource, tableView, indexPath, item in
        let cell = tableView.dequeue(Reusable.noticeListCell, for: indexPath)
        cell.reactor = item.reactor
        
        return cell
    })
    
    init(reactor: NoticeReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        contentView.addSubview(customNaviBar)
        contentView.addSubview(noticeTableView)
        
        customNaviBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
        
        noticeTableView.snp.makeConstraints {
            $0.top.equalTo(customNaviBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }

    internal func bind(reactor: NoticeReactor) {
        noticeTableView.rx.modelSelected(NoticeSectionModel.Item.self)
            .asDriver()
            .map { $0.reactor }
            .drive(with: self) { owner, detailReactor in
                Observable.just(NoticeCellReactor.Action.moveDetailView)
                    .bind(to: detailReactor.action)
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        Observable.just(NoticeReactor.Action.loadNotices)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.noticeList }
            .bind(to: self.noticeTableView.rx.items(dataSource: self.dataSource) )
            .disposed(by: disposeBag)
    }
    
}

// MARK: - ViewItem, Model

struct NoticeCellItem {
    let reactor: NoticeCellReactor
}

struct NoticeSectionModel {
    var noticeList: [NoticeCellItem]
    
    init(items: [NoticeCellItem]) {
        self.noticeList = items
    }
}

extension NoticeSectionModel:SectionModelType {
    typealias Item = NoticeCellItem
    
    var items: [NoticeCellItem] {
        self.noticeList
    }
    
    init(original: NoticeSectionModel, items: [Item]) {
        self = original
        self.noticeList = items
    }
}

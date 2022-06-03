//
//  NoticeViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 3. 2..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Material
import RxDataSources
import ReactorKit
import SwiftyJSON
import RxSwift
import SnapKit
import Then
import ReusableKit

internal final class NoticeViewController: BaseViewController, StoryboardView {
    
    typealias NoticeDataSource = RxTableViewSectionedReloadDataSource<NoticeListSectionModel>

    // ReusableKit
    private enum Reusable {
        static let noticeListCell = ReusableCell<NoticeCell>(nibName: NoticeCell.reuseID)
    }
    
    private lazy var tableView = UITableView().then {
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = UITableViewAutomaticDimension
        $0.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        $0.separatorColor = UIColor(rgb: 0xE4E4E4)
        $0.estimatedRowHeight = 102
        $0.register(Reusable.noticeListCell)
    }

    private let dataSource = NoticeDataSource(configureCell: { _, tableView, indexPath, item in
        switch item {
        case .noticeListItem(let reactor):
            let cell = tableView.dequeue(Reusable.noticeListCell, for: indexPath)
            cell.reactor = reactor
            return cell
        }
    })

    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareActionBar(with: "공지사항")
    }
    
    internal func bind(reactor: NoticeReactor) {
        Observable.just(Reactor.Action.loadData)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.sections }
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: disposeBag)
    }
    
    private func layout() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: Reactive Extension
enum NoticeListItem {
    case noticeListItem(reactor: NoticeCellReactor<NoticeInfo>)
}

struct NoticeListSectionModel {
    var noticeList: [NoticeListItem]
    
    init(items: [NoticeListItem]) {
        self.noticeList = items
    }
}

extension NoticeListSectionModel: SectionModelType {
    typealias Item = NoticeListItem
    
    var items: [NoticeListItem] {
        self.noticeList
    }
    
    init(original: NoticeListSectionModel, items: [NoticeListItem]) {
        self = original
        self.noticeList = items
    }
}



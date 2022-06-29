//
//  ReportHistoryViewController.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/06/29.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import ReusableKit
import RxDataSources
import RxSwift
import RxCocoa
import SnapKit
import Then

internal final class ReportHistoryViewController: BaseViewController, StoryboardView {
    
    typealias ReportHistoryDataSource = RxTableViewSectionedReloadDataSource<ReportHistoryListSectionModel>
    
    private enum Reusable {
        static let reportHistoryListCell = ReusableCell<ReportHistoryCell>(nibName: ReportHistoryCell.reuseID)
    }
    
    private let tableView = UITableView().then {
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = UITableViewAutomaticDimension
        $0.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        $0.separatorColor = UIColor(rgb: 0xE4E4E4)
        $0.estimatedRowHeight = 102
        $0.showsHorizontalScrollIndicator = false
        $0.separatorStyle = .singleLine
        $0.register(Reusable.reportHistoryListCell)
    }
    
    private let dataSource = ReportHistoryDataSource(configureCell: { _, tableView, indexPath, item in
        switch item {
        case .reportHistoryItem(let reactor):
            let cell = tableView.dequeue(Reusable.reportHistoryListCell, for: indexPath)
            cell.reactor = reactor
            return cell
        }
    })
    
    override func loadView() {
        super.loadView()
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareActionBar(with: "나의 제보 내역")
    }
    
    internal func bind(reactor: ReportHistoryReactor) {
        Observable.just(Reactor.Action.loadData)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.sections }
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: disposeBag)
    }
}

enum ReportHistoryListItem {
    case reportHistoryItem(reactor: ReportHistoryCellReactor<ReportHistoryListDataModel.ReportHistoryInfo>)
}

struct ReportHistoryListSectionModel {
    var reportHistoryList: [ReportHistoryListItem]
    
    init(items: [ReportHistoryListItem]) {
        self.reportHistoryList = items
    }
}

extension ReportHistoryListSectionModel: SectionModelType {
    typealias Item = ReportHistoryListItem
    
    var items: [ReportHistoryListItem] {
        self.reportHistoryList
    }
    
    init(original: ReportHistoryListSectionModel, items: [ReportHistoryListItem]) {
        self = original
        self.reportHistoryList = items
    }
}

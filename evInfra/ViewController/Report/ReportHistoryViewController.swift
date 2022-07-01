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
import UIKit

internal final class ReportHistoryViewController: BaseViewController, StoryboardView {
    
    typealias ReportHistoryDataSource = RxTableViewSectionedReloadDataSource<ReportHistoryListSectionModel>
    
    private enum Reusable {
        static let reportHistoryListCell = ReusableCell<ReportHistoryCell>(nibName: ReportHistoryCell.reuseID)
    }
    
    private lazy var tableView = UITableView().then {
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = UITableViewAutomaticDimension
        $0.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        $0.separatorColor = UIColor(rgb: 0xE4E4E4)
        $0.estimatedRowHeight = 102
        $0.showsHorizontalScrollIndicator = false
        $0.separatorStyle = .singleLine
        $0.register(Reusable.reportHistoryListCell)
    }
    
    private lazy var emptyTextLabel = UILabel().then {
        $0.text = "제보한 내역이 없습니다."
        $0.font = .systemFont(ofSize: 17, weight: .regular)
        $0.textColor = UIColor(named: "content-primary")
        $0.isHidden = true
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
        
        view.addSubview(emptyTextLabel)
        emptyTextLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareActionBar(with: "나의 제보 내역")
    }
    
    internal func bind(reactor: ReportHistoryReactor) {
        Observable.just(Reactor.Action.loadData("0"))
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isHiddenEmptyLabel }
            .bind(to: emptyTextLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.sections }
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.didEndDragging
            .filter { [weak self] isEnd in
                guard let self = self else { return false }
                guard reactor.currentState.isPaging else { return false }
                
                let currentOffset = self.tableView.contentOffset.y
                let maximumOffset = self.tableView.contentSize.height - self.tableView.frame.size.height
                
                guard maximumOffset - currentOffset <= self.tableView.frame.size.height else { return false}
                return true
            }
            .map { _ in Reactor.Action.loadData(reactor.initialState.lastId) }
            .bind(to: reactor.action)
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

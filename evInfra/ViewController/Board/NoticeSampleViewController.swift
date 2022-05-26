//
//  NoticeSampleViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/26.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Then
import RxDataSources
import ReactorKit
import ReusableKit

internal final class TestController: BaseViewController, StoryboardView {
    typealias MainDataSource = RxTableViewSectionedReloadDataSource<TestListSectionModel>
    
    private enum Reusable {
        static let TestListCell = ReusableCell<TestListCell>(nibName: TestListCell.reuseID)
        static let emptyCell = ReusableCell<EmptyCell>(nibName: EmptyCell.reuseID)
    }
    
    private lazy var tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(Reusable.TestListCell)
        $0.register(Reusable.emptyCell)
        $0.backgroundColor = UIColor.clear
        $0.showsVerticalScrollIndicator = false
        $0.separatorStyle = .none
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = 129
        $0.allowsSelection = false
        $0.allowsSelectionDuringEditing = false
        $0.isMultipleTouchEnabled = false
        $0.allowsMultipleSelection = false
        $0.allowsMultipleSelectionDuringEditing = false
        $0.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 16.0, right: 0.0)
        $0.bounces = false
    }
    
    private let dataSource = MainDataSource(configureCell: { _, tableView, indexPath, item in
        switch item {
        case .TestListItem(let reactor):
            let cell = tableView.dequeueReusableCell(ofType: TestListCell.self, for: indexPath)
            cell.reactor = reactor
            return cell
            
        case .emptyItem(let reactor):
            let cell = tableView.dequeue(Reusable.emptyCell, for: indexPath)
            cell.reactor = reactor
            return cell
        }
    })
    
    
    override func loadView() {
        super.loadView()
        
        self.contentView.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    internal func bind(reactor: Reactor) {
        Observable.just(Reactor.Action.loadData)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
    reactor.state.map { $0.sections }
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
    }
}

enum TestListItem {
    case TestListItem(reactor: TestListSectionItemReactor<TestListDataModel.TestListDataItem>)
    case emptyItem(reactor: TestListSectionItemReactor<TestListDataModel.EmptyDataItem>)
}

struct TestListSectionModel {
    var title: String
    var TestList: [TestListItem]
    
    init(title: String, items: [TestListItem]) {
        self.title = title
        self.TestList = items
    }
}

extension TestListSectionModel: SectionModelType {
    typealias Item = TestListItem
    
    var items: [TestListItem] {
        self.TestList
    }

    init(original: TestListSectionModel, items: [Item]) {
        self = original
        self.TestList = items
    }
}

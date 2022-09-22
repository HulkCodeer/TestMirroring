//
//  NewEventViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/09/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import ReusableKit
import RxDataSources
import SwiftyJSON
import RxViewController
import UIKit


internal final class NewEventViewController: CommonBaseViewController, StoryboardView {
    typealias MainDataSource = RxTableViewSectionedReloadDataSource<EventListSectionModel>
    
    private enum Reusable {
        static let eventListCell = ReusableCell<EventListCell>()
    }
    
    // MARK: UI
    
    private lazy var commonNaviView = CommonNaviView().then {
        $0.naviTitleLbl.text = "이벤트"
    }
    
    private lazy var emptyLbl = UILabel().then {
        $0.text = "이벤트 준비중입니다.^^"
        $0.font = .systemFont(ofSize: 17, weight: .regular)
    }
        
    private lazy var tableView = UITableView().then {
        $0.register(Reusable.eventListCell)
        $0.backgroundColor = UIColor.clear
        $0.separatorStyle = .none
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = 150
        $0.allowsSelection = false
        $0.allowsSelectionDuringEditing = false
        $0.isMultipleTouchEnabled = false
        $0.allowsMultipleSelection = false
        $0.allowsMultipleSelectionDuringEditing = false
        $0.contentInset = .zero
        $0.bounces = false
    }
    
    // MARK: VARIABLE
    
    private let dataSource = MainDataSource(configureCell: { _, tableView, indexPath, item in
        switch item {
        case .eventItem(let reactor):
            let cell = tableView.dequeue(Reusable.eventListCell, for: indexPath)
            cell.reactor = reactor
            return cell
    
        }
    })
    
    // MARK: SYSTEM FUNC
    
    init(reactor: EventReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        self.contentView.addSubview(commonNaviView)
        commonNaviView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(emptyLbl)
        emptyLbl.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
                        
        self.contentView.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(Constants.view.naviBarHeight).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
    
    func bind(reactor: EventReactor) {
        reactor.state.map { $0.sections}
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
    }
}

enum EventListItem {
    case eventItem(reactor: EventDetailReactor)
}

struct EventListSectionModel {
    var eventList: [EventListItem]
    
    init(items: [EventListItem]) {
        self.eventList = items
    }
}

extension EventListSectionModel: SectionModelType {
    typealias Item = EventListItem
    
    var items: [EventListItem] {
        self.eventList
    }
    
    init(original: EventListSectionModel, items: [Item]) {
        self = original
        self.eventList = items
    }
}

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

internal final class NoticeViewController: BaseViewController, StoryboardView {
    
    typealias NoticeDataSource = RxTableViewSectionedReloadDataSource<NoticeListSectionModel>

// ReusableKit
//    private enum Reusable {
//        static let NoticeListCell = ReusableCell<NoticeTableViewCell>(nibName: NoticeTableViewCell.reuseID)
//    }
    
    private lazy var tableView = UITableView().then {
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = UITableViewAutomaticDimension
        $0.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        $0.separatorColor = UIColor(rgb: 0xE4E4E4)
        $0.estimatedRowHeight = 102
        $0.register(NoticeTableViewCell.self, forCellReuseIdentifier: "noticeCell")
    }

    private let dataSource = NoticeDataSource(configureCell: { _, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath) as! NoticeTableViewCell
        cell.noticeTitleLbl.text = item.title
        cell.dateTimeLbl.text = item.datetime
        return cell
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
        
        tableView.rx
            .modelSelected(NoticeListDataModel.Notice.self)
            .map { $0.id }
            .bind(to: self.rx.push)
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
extension Reactive where Base: NoticeViewController {
    var push: Binder<String> {
        return Binder(base) { base, boardId in
            let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
            guard let noticeContentViewController = boardStoryboard.instantiateViewController(withIdentifier: "NoticeContentViewController") as? NoticeContentViewController else { return }
            noticeContentViewController.boardId = Int(boardId) ?? -1
            base.navigationController?.push(viewController: noticeContentViewController)
        }
    }
}

//enum NoticeListItem {
//    case NoticeListItem(reactor: NoticeTableViewCellReactor)
//}

struct NoticeListSectionModel {
    var noticeList: [Item]
    
    init(items: [Item]) {
        self.noticeList = items
    }
}

extension NoticeListSectionModel: SectionModelType {
    typealias Item = NoticeListDataModel.Notice
    
    var items: [NoticeListDataModel.Notice] {
        self.noticeList
    }
    
    init(original: NoticeListSectionModel, items: [NoticeListDataModel.Notice]) {
        self = original
        self.noticeList = items
    }
}



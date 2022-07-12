//
//  NewFavoriteViewController.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/07/06.
//  Copyright © 2022 soft-berry. All rights reserved.
//

//import UIKit
import ReactorKit
import ReusableKit
import RxDataSources
import RxSwift
import RxCocoa
import SnapKit
import Then

internal final class NewFavoriteViewController: BaseViewController, StoryboardView {
    typealias FavoriteDataSource = RxTableViewSectionedReloadDataSource<FavoriteListSectionModel>
    
    private enum Reusable {
        static let favoriteListCell = ReusableCell<NewFavoriteCell>(nibName: NewFavoriteCell.reuseID)
    }
    
    private lazy var tableView = UITableView().then {
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = UITableViewAutomaticDimension
        $0.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        $0.separatorColor = UIColor(rgb: 0xE4E4E4)
        $0.estimatedRowHeight = 102
        $0.showsHorizontalScrollIndicator = false
        $0.separatorStyle = .singleLine
        $0.register(Reusable.favoriteListCell)
    } 
    
    private let dataSource = FavoriteDataSource(configureCell: { _, tableView, indexPath, item in
        switch item {
        case .favoriteListItem(let reactor):
            let cell = tableView.dequeue(Reusable.favoriteListCell, for: indexPath)
            cell.reactor = reactor
            return cell
        }
    })
    
    private lazy var emptyView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
        $0.isHidden = true
    }
    
    private lazy var emptyImageView = UIImageView().then {
        $0.image = UIImage(named: "empty_bookmark_img")
        $0.clipsToBounds = true
    }
    
    private lazy var emptyTitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 24, weight: .regular)
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.text = "아직 즐겨찾는 충전소가 없으신가요?"
    }
    
    private lazy var emptySubTitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 17, weight: .regular)
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = """
            자주 방문하시는 충전소의 별모양 버튼을 눌러
            즐겨찾기를 추가해보세요!
        """
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emptyView.addSubview(emptyImageView)
        emptyView.addSubview(emptyTitleLabel)
        emptyView.addSubview(emptySubTitleLabel)
        emptyImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(emptyTitleLabel.snp.top).offset(-56)
        }
        emptyTitleLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImageView.snp.bottom).offset(56)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(emptySubTitleLabel.snp.bottom)
        }
        emptySubTitleLabel.snp.makeConstraints {
            $0.top.equalTo(emptyTitleLabel.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints {
            $0.centerX.centerY.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareActionBar(with: "즐겨찾기")
    }
    
    internal func bind(reactor: NewFavoriteReactor) {
        Observable.just(Reactor.Action.loadData)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.sections }
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: disposeBag)
    }
    
    override func backButtonTapped() {
        GlobalDefine.shared.mainNavi?.dismiss(animated: true)
    }
}


enum FavoriteListItem {
    case favoriteListItem(reactor: NewFavoriteCellReactor<FavoriteListInfo>)
}

struct FavoriteListSectionModel {
    var favoriteList: [FavoriteListItem]
    
    init(items: [FavoriteListItem]) {
        self.favoriteList = items
    }
}

extension FavoriteListSectionModel: SectionModelType {
    typealias Item = FavoriteListItem
    
    var items: [FavoriteListItem] {
        self.favoriteList
    }
    
    init(original: FavoriteListSectionModel, items: [FavoriteListItem]) {
        self = original
        self.favoriteList = items
    }
}

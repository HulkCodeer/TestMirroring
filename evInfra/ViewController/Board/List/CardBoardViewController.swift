//
//  CardBoardViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 17..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Motion
import Material
import SwiftyJSON
import SnapKit
import CoreMIDI

internal final class CardBoardViewController: CommonBaseViewController {
    private lazy var commonNaviView = CommonNaviView().then {
        $0.naviTitleLbl.text = ""
    }
    private lazy var boardTableView = BoardTableView()
    private lazy var searchButton = UIButton().then {
        $0.setImage(Icons.iconSearchMd.image, for: .normal)
        $0.tintColor = Colors.nt9.color
        
        $0.addTarget(self, action: #selector(handleSearchButton), for: .touchUpInside)
    }
    
    var category: Board.CommunityType = .FREE // default 자유게시판
    var bmId: Int = -1
    var brdTitle: String = ""
    var currentPage = 0
    var lastPage: Bool = false
    var communityBoardList: [BoardListItem] = [BoardListItem]()
    var sortType: Board.SortType = .LATEST
    var mode: Board.ScreenType = .LIST
    var boardListViewModel: BoardListViewModel?
    let boardWriteButton = BoardWriteButton()
    
    override func loadView() {
        super.loadView()
        
        boardTableView.tableViewDelegate = self
        boardTableView.category = self.category
        boardTableView.screenType = self.mode
        boardTableView.refreshControl = UIRefreshControl()
        boardTableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        boardTableView.refreshControl?.attributedTitle = NSAttributedString(string: "새로고침")
        boardTableView.separatorColor = UIColor(rgb: 0xE4E4E4)
        boardTableView.separatorInset = .zero
        boardTableView.separatorStyle = .none
        boardTableView.allowsSelection = true
                
        switch self.category {
        case .CHARGER:
            self.commonNaviView.naviTitleLbl.text = "충전소 게시판"
        case .CORP_GS, .CORP_JEV, .CORP_STC, .CORP_SBC:
            self.commonNaviView.naviTitleLbl.text = "\(self.brdTitle) 게시판"
        case .FREE:
            self.commonNaviView.naviTitleLbl.text = "자유게시판"
        default:
            self.commonNaviView.naviTitleLbl.text = "게시판"
        }
                
        self.contentView.addSubview(commonNaviView)
        commonNaviView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
        
        self.contentView.addSubview(boardTableView)
        boardTableView.snp.makeConstraints {
            $0.top.equalTo(commonNaviView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        commonNaviView.addSubview(searchButton)
        searchButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(Constants.view.naviBarItemPadding)
            $0.size.equalTo(Constants.view.naviBarItemWidth)
        }
                        
        self.contentView.addSubview(boardWriteButton)
        self.contentView.addSubview(activityIndicator)
        
        boardWriteButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-74)
            $0.trailing.equalToSuperview().offset(-24)
            $0.width.equalTo(101)
            $0.height.equalTo(36)
        }
        
        boardWriteButton.addTarget(self, action: #selector(handlePostButton), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardListViewModel = BoardListViewModel(category)
        fetchFirstBoard(mid: category.rawValue, sort: sortType, mode: mode.rawValue)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCompletion(_:)), name: Notification.Name("ReloadData"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
}

extension CardBoardViewController {
    
    @objc func updateCompletion(_ notification: Notification) {
        fetchFirstBoard(mid: category.rawValue, sort: sortType, mode: mode.rawValue)
    }
    
    @objc func pullToRefresh(refresh: UIRefreshControl) {
        refresh.endRefreshing()
        fetchFirstBoard(mid: category.rawValue, sort: sortType, mode: mode.rawValue)
    }
            
    @objc
    fileprivate func handleSearchButton() {
        let storyboard = UIStoryboard.init(name: "BoardSearchViewController", bundle: nil)
        guard let boardSearchViewController = storyboard.instantiateViewController(withIdentifier: "BoardSearchViewController") as? BoardSearchViewController else { return }
        
        boardSearchViewController.category = self.category
        self.navigationController?.push(viewController: boardSearchViewController)
    }
    
    @objc
    fileprivate func handlePostButton() {
        let storyboard = UIStoryboard.init(name: "BoardWriteViewController", bundle: nil)
        guard let viewcon = storyboard.instantiateViewController(withIdentifier: "BoardWriteViewController") as? BoardWriteViewController else { return }
        
        viewcon.isFromDetailView = false
        viewcon.category = self.category
        viewcon.popCompletion = { [weak self] in
            guard let self = self else { return }
            self.fetchFirstBoard(mid: self.category.rawValue, sort: self.sortType, mode: self.mode.rawValue)
        }        
                
        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                
        BoardEvent.clickWriteBoardPost.logEvent()
    }
}

// MARK: - TableView Delegate
extension CardBoardViewController: BoardTableViewDelegate {
    func fetchNextBoard(mid: String, sort: Board.SortType, mode: String) {
        if lastPage == false {
            self.currentPage = self.currentPage + 1
            
            boardListViewModel?.fetchNextBoard(mid: mid, sort: sort, currentPage: self.currentPage, mode: mode)
            boardListViewModel?.listener = { [weak self] boardResponseData in
                guard let self = self,
                      let boardResponseData = boardResponseData,
                        let communityBoardList = boardResponseData.list else { return }
                
                self.communityBoardList += communityBoardList
                self.boardTableView.communityBoardList = self.communityBoardList
                self.activityIndicator.stopAnimating()
                
                DispatchQueue.main.async {
                    self.boardTableView.reloadData()
                }
            }
        }
    }
    

    func fetchFirstBoard(mid: String, sort: Board.SortType, mode: String) {
        self.currentPage = 1
        self.lastPage = false
        self.sortType = sort
        activityIndicator.startAnimating()
        boardListViewModel?.fetchFirstBoard(mid: category.rawValue, sort: sortType, currentPage: currentPage, mode: mode)
        boardListViewModel?.listener = { [weak self] boardResponseData in
            guard let self = self,
                  let boardResponseData = boardResponseData,
                    let communityBoardList = boardResponseData.list else { return }
            
            self.communityBoardList = communityBoardList
            self.boardTableView.communityBoardList = self.communityBoardList
            self.activityIndicator.stopAnimating()
            
            DispatchQueue.main.async {
                self.boardTableView.reloadData()
            }
        }
    }
    
    func didSelectItem(at index: Int) {
        guard let documentSRL = communityBoardList[index].document_srl,
        !documentSRL.elementsEqual("-1") else { return }
        
        if communityBoardList[index].blind != nil { return }
        
        let storyboard = UIStoryboard(name: "BoardDetailViewController", bundle: nil)
        guard let boardDetailTableViewController = storyboard.instantiateViewController(withIdentifier: "BoardDetailViewController") as? BoardDetailViewController else { return }
        
        boardDetailTableViewController.category = category
        boardDetailTableViewController.document_srl = documentSRL
        boardDetailTableViewController.isFromStationDetailView = false
        
        boardDetailTableViewController.popCompletion = { [weak self] isModifed in
            if isModifed {
                guard let self = self else { return }
                self.fetchFirstBoard(mid: self.category.rawValue, sort: self.sortType, mode: self.mode.rawValue)
            }
        }
        
        self.navigationController?.push(viewController: boardDetailTableViewController)
    }
    
    func showImageViewer(url: URL, isProfileImageMode: Bool) {
        let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
        guard let imageVC: EIImageViewerViewController = boardStoryboard.instantiateViewController(withIdentifier: "EIImageViewerViewController") as? EIImageViewerViewController else { return }
        imageVC.mImageURL = url
        imageVC.isProfileImageMode = isProfileImageMode
    
        self.navigationController?.push(viewController: imageVC)
    }
}


//
//  MyWritingViewController.swift
//  evInfra
//
//  Created by bulacode on 30/10/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import UIKit
import Material
import Motion
import SwiftyJSON

class MyWritingViewController: BaseViewController {
    
    private lazy var boardTableView = BoardTableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var currentPage = 0
    var lastPage: Bool = false
    var communityBoardList: [BoardListItem] = [BoardListItem]()
    var boardCategory = ""
    var screenType = Board.ScreenType.LIST
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(boardTableView)
        boardTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }                
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTabItem()
        boardTableView.tableViewDelegate = self
        boardTableView.separatorColor = UIColor(rgb: 0xE4E4E4)
        boardTableView.separatorInset = .zero
        boardTableView.separatorStyle = .none
        boardTableView.allowsSelection = true
        boardTableView.isNoneHeader = true
        boardTableView.category = boardCategory
        boardTableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Recalculates height
        fetchFirstBoard(mid: boardCategory, sort: Board.SortType.LATEST, mode: screenType.rawValue)
    }
}

extension MyWritingViewController {
    func prepareTabItem() {
        if (boardCategory.elementsEqual(Board.CommunityType.FREE.rawValue)) {
            tabItem.title = "자유게시판"
        } else if (boardCategory.elementsEqual(Board.CommunityType.CHARGER.rawValue)) {
            tabItem.title = "충전소게시판"
        }
        
        tabItem.setTitleColor(UIColor(named: "content-primary")!, for: .selected)
        tabItem.setTitleColor(Color.grey.base, for: .normal)
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
}

extension MyWritingViewController: BoardTableViewDelegate {
    func fetchFirstBoard(mid: String, sort: Board.SortType, mode: String) {
        self.activityIndicator.startAnimating()
        self.currentPage = 1
        self.lastPage = false
        
        let mbID = MemberManager.shared.mbId
        
        Server.fetchBoardList(mid: mid,
                              page: "\(self.currentPage)",
                              mode: mode,
                              sort: sort.rawValue,
                              searchType: Board.SearchType.MBID.rawValue,
                              searchKeyword: "\(mbID)") { (isSuccess, value) in
            if isSuccess {
                guard let data = value else { return }
                let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(BoardResponseData.self, from: data)
                    
                    if let itemList = result.list {
                        self.communityBoardList.removeAll()
                        self.communityBoardList = itemList
                        self.boardTableView.communityBoardList = self.communityBoardList
                        self.activityIndicator.stopAnimating()

                        DispatchQueue.main.async {
                            self.boardTableView.reloadData()
                        }
                    }
                } catch {
                    debugPrint("error")
                }
            } else {
                
            }
        }
    }
    
    func fetchNextBoard(mid: String, sort: Board.SortType, mode: String) {
        self.currentPage += 1
        
        let mbID = MemberManager.shared.mbId
        
        Server.fetchBoardList(mid: mid,
                              page: "\(self.currentPage)",
                              mode: mode,
                              sort: sort.rawValue,
                              searchType: Board.SearchType.MBID.rawValue,
                              searchKeyword: "\(mbID)") { (isSuccess, value) in
            if isSuccess {
                guard let data = value else { return }
                let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(BoardResponseData.self, from: data)
                    
                    if let updateList = result.list {
                        self.communityBoardList += updateList
                        self.boardTableView.communityBoardList = self.communityBoardList
                        
                        DispatchQueue.main.async {
                            self.boardTableView.reloadData()
                        }
                    }
                } catch {
                    debugPrint("error")
                }
            } else {
                
            }
        }
    }
    
    func didSelectItem(at index: Int) {
        guard let documentSRL = communityBoardList[index].document_srl,
        !documentSRL.elementsEqual("-1") else { return }
        
        let storyboard = UIStoryboard(name: "BoardDetailViewController", bundle: nil)
        guard let boardDetailTableViewController = storyboard.instantiateViewController(withIdentifier: "BoardDetailViewController") as? BoardDetailViewController else { return }
        
        boardDetailTableViewController.category = boardCategory
        boardDetailTableViewController.document_srl = documentSRL
        boardDetailTableViewController.isFromStationDetailView = false
        
        self.navigationController?.push(viewController: boardDetailTableViewController)
    }
    
    func showImageViewer(url: URL, isProfileImageMode: Bool) { }
}

extension MyWritingViewController: AppTabsControllerDelegate {
    func changeTab() {}
}

//
//  BoardSearchViewController.swift
//  evInfra
//
//  Created by PKH on 2022/02/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit

class BoardSearchViewController: BaseViewController {

    private var searchBarView = SearchBarView()
    private var searchTypeSelectView = SearchTypeSelectView()
    private var tableView = UITableView()
    private var recentKeywords: [Keyword] = []
    private var boardList: [BoardListItem] = [BoardListItem]()
    
    let boardSearchViewModel = BoardSearchViewModel()
    
    var searchResultListView = BoardTableView()
    var isSearchButtonTapped: Bool = false
    var category = Board.CommunityType.FREE.rawValue
    var page: String = "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        prepareActionBar(with: "게시글 검색")
        
        boardSearchViewModel.fetchKeywords { [weak self] keywords in
            guard let self = self else { return }
            self.recentKeywords = keywords

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        searchBarView.searchButtonCompletion = { [weak self] keyword in
            guard let self = self else { return }
            self.searchBarView.searchBar.endEditing(true)
            
            self.boardSearchViewModel.setKeyword(keyword)
            self.boardSearchViewModel.fetchKeywords { keywords in
                self.recentKeywords = keywords
            }
            self.fetchSearchResultList(page: self.page)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - Private Extension
private extension BoardSearchViewController {
    func setUI() {
        view.addSubview(searchBarView)
        view.addSubview(searchTypeSelectView)
        view.addSubview(tableView)
        
        searchBarView.searchBar.delegate = self
        
        // Searchbar UI
        searchBarView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(72)
        }
        
        // SearchTypeSelecteView UI
        searchTypeSelectView.snp.makeConstraints {
            $0.top.equalTo(searchBarView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchTypeSelectView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        tableView.register(RecentKeywordTableViewCell.classForCoder(), forCellReuseIdentifier: "RecentKeywordTableViewCell")
        tableView.register(EmptyTableViewCell.classForCoder(), forCellReuseIdentifier: "EmptyTableViewCell")
        tableView.register(SearchHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: "SearchHeaderView")
        tableView.keyboardDismissMode = .onDrag
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    func fetchSearchResultList(page: String) {
        let mid = self.category
        let addedPage = page
        let type = searchTypeSelectView.selectedType
        let keyword = self.boardSearchViewModel.keyword
        
        boardSearchViewModel.fetchSearchResultList(mid: mid,
                                                   page: addedPage,
                                                   searchType: type,
                                                   keyword: keyword) { [weak self] boardList in
            guard let self = self else { return }
            
            self.isSearchButtonTapped = true
            
            if type != self.searchTypeSelectView.previousSelectedType {
                self.boardList = boardList
            } else {
                self.boardList += boardList
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func isSearchBarEmpty() -> Bool {
        return searchBarView.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return !isSearchBarEmpty() && !isSearchButtonTapped
    }
}

// MARK: - UISearchBarDelegate
extension BoardSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        guard !searchText.isEmpty else {
            isSearchButtonTapped = false
            
            boardSearchViewModel.fetchKeywords { [weak self] keywords in
                guard let self = self else { return }
                self.recentKeywords = keywords

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            boardList.removeAll()
            
            return
        }
        
        boardSearchViewModel.filteredKeywords(keyword: searchText) { [weak self] filteredKeywords in
            guard let self = self else { return }
            self.recentKeywords = filteredKeywords
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let keyword = searchBar.text {
            searchBar.endEditing(true)
            
            boardSearchViewModel.setKeyword(keyword)
            boardSearchViewModel.fetchKeywords { [weak self] keywords in
                guard let self = self else { return }
                self.recentKeywords = keywords
            }
            
            fetchSearchResultList(page: self.page)
        }
    }
}

// MARK: - UITableViewDataSource
extension BoardSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return recentKeywords.count
        } else {
            if isSearchButtonTapped {
                if boardList.isEmpty {
                    switch section {
                    case 0:
                        return 1
                    case 1:
                        return recentKeywords.count
                    default:
                        return 0
                    }
                } else {
                    return boardList.count
                }
            } else {
                if recentKeywords.isEmpty {
                    return 1
                } else {
                    return recentKeywords.count
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFiltering() {
            guard let recentKeywordCell = tableView.dequeueReusableCell(withIdentifier: "RecentKeywordTableViewCell", for: indexPath) as? RecentKeywordTableViewCell else { return UITableViewCell() }

            recentKeywordCell.configure(item: recentKeywords[indexPath.row])
            recentKeywordCell.delegate = self
            
            return recentKeywordCell
        } else {
            if isSearchButtonTapped {
                if boardList.isEmpty {
                    switch indexPath.section {
                    case 0:
                        guard let emptyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell", for: indexPath) as? EmptyTableViewCell else { return UITableViewCell() }
                        emptyTableViewCell.configure(isSearchViewType: .Searching)
                        emptyTableViewCell.selectionStyle = .none
                        return emptyTableViewCell
                    case 1:
                        guard let recentKeywordCell = tableView.dequeueReusableCell(withIdentifier: "RecentKeywordTableViewCell", for: indexPath) as? RecentKeywordTableViewCell else { return UITableViewCell() }

                        recentKeywordCell.configure(item: recentKeywords[indexPath.row])
                        recentKeywordCell.delegate = self

                        return recentKeywordCell
                    default:
                        return UITableViewCell()
                    }
                } else {
                    switch self.category {
                    case Board.CommunityType.FREE.rawValue,
                        Board.CommunityType.CORP_GS.rawValue,
                        Board.CommunityType.CORP_JEV.rawValue,
                        Board.CommunityType.CORP_STC.rawValue,
                        Board.CommunityType.CORP_SBC.rawValue:
                        guard let cell = Bundle.main.loadNibNamed("CommunityBoardTableViewCell", owner: self, options: nil)?.first as? CommunityBoardTableViewCell else { return UITableViewCell() }

                        cell.configure(item: boardList[indexPath.row])
                        cell.selectionStyle = .none
                        
                        return cell
                    case Board.CommunityType.CHARGER.rawValue:
                        guard let cell = Bundle.main.loadNibNamed("CommunityChargeStationTableViewCell", owner: self, options: nil)?.first as? CommunityChargeStationTableViewCell else { return UITableViewCell() }
                        
                        cell.configure(item: boardList[indexPath.row])
                        cell.selectionStyle = .none
                        
                        return cell
                    default:
                        return UITableViewCell()
                    }
                }
            } else {
                if recentKeywords.isEmpty {
                    guard let emptyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell", for: indexPath) as? EmptyTableViewCell else { return UITableViewCell() }
                    emptyTableViewCell.configure(isSearchViewType: .Keyword)
                    emptyTableViewCell.selectionStyle = .none
                    return emptyTableViewCell
                } else {
                    guard let recentKeywordCell = tableView.dequeueReusableCell(withIdentifier: "RecentKeywordTableViewCell", for: indexPath) as? RecentKeywordTableViewCell else { return UITableViewCell() }

                    recentKeywordCell.configure(item: recentKeywords[indexPath.row])
                    recentKeywordCell.delegate = self
                    
                    return recentKeywordCell
                }
            }
        }
    }
}

// MARK: - RecentKeywordTableViewCellDelegate
extension BoardSearchViewController: RecentKeywordTableViewCellDelegate {
    func deleteButtonTapped(row: Int?) {
        if let selectedRow = row {
            boardSearchViewModel.removeKeyword(at: selectedRow)
        } else {
            boardSearchViewModel.removeAllKeywords()
        }
        
        boardSearchViewModel.fetchKeywords { [weak self] keywords in
            guard let self = self else { return }
            self.recentKeywords = keywords

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension BoardSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isSearchButtonTapped {
            if boardList.isEmpty {
                switch section {
                case 0:
                    return SearchHeaderView(true, 0)
                case 1:
                    let headerView = SearchHeaderView(false, self.recentKeywords.count)
                    headerView.delegate = self
                    return headerView
                default:
                    return SearchHeaderView(true, 0)
                }
            } else {
                return SearchHeaderView(isSearchButtonTapped, self.boardList.count)
            }
        } else {
            if recentKeywords.isEmpty {
                return nil
            } else {
                let headerView = SearchHeaderView(isSearchButtonTapped, self.boardList.count)
                headerView.delegate = self
                return headerView
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearchButtonTapped {
            if boardList.isEmpty {
                return 2
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering() {
            guard let keyword = boardSearchViewModel.keyword(at: indexPath.row).title else { return }
            
            boardSearchViewModel.setKeyword(keyword)
            fetchSearchResultList(page: self.page)
        } else {
            if isSearchButtonTapped {
                if boardList.isEmpty {
                    if indexPath.section == 1 {
                        guard let keyword = self.recentKeywords[indexPath.row].title else { return }
                        
                        self.searchBarView.searchBar.text = keyword
                        boardSearchViewModel.setKeyword(keyword)
                        fetchSearchResultList(page: self.page)
                    }
                } else {
                    guard let documentSRL = boardList[indexPath.row].document_srl else { return }
                    
                    let storyboard = UIStoryboard(name: "BoardDetailViewController", bundle: nil)
                    guard let boardDetailTableViewController = storyboard.instantiateViewController(withIdentifier: "BoardDetailViewController") as? BoardDetailViewController else { return }
                    
                    boardDetailTableViewController.category = category
                    boardDetailTableViewController.document_srl = documentSRL
                    boardDetailTableViewController.isFromStationDetailView = false
                    
                    self.navigationController?.push(viewController: boardDetailTableViewController)
                }
            } else {
                guard let keyword = self.recentKeywords[indexPath.row].title else { return }
                
                self.searchBarView.searchBar.text = keyword
                boardSearchViewModel.setKeyword(keyword)
                fetchSearchResultList(page: self.page)
            }
        }
    }
}

// MARK: - UIScrollViewDelegate
extension BoardSearchViewController {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height

        if maximumOffset - currentOffset <= -20.0 {
            if isFiltering() {
                
            } else {
                if isSearchButtonTapped {
                    let isLast = self.boardSearchViewModel.lastPage
                    
                    if !isLast {
                        let addedPage = "\(Int(self.page)! + 1)"
                        fetchSearchResultList(page: addedPage)
                    }
                }
            }
        }
    }
}

protocol RecentKeywordTableViewCellDelegate: AnyObject {
    func deleteButtonTapped(row: Int?)
}

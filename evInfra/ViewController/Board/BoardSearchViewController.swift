//
//  BoardSearchViewController.swift
//  evInfra
//
//  Created by PKH on 2022/02/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit

class BoardSearchViewController: UIViewController {

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
        setNavigationController()
        
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
            self.fetchSearchResultList(page: self.page)
        }
    }
}

// MARK: - Extension
private extension BoardSearchViewController {
    func setNavigationController() {
        navigationItem.titleLabel.text = "게시글 검색"
    }
    
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
        tableView.register(SearchHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: "SearchHeaderView")
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
            
            if boardList.isEmpty {
                // 검색 결과 없음 view 표시
            } else {
                self.boardList += boardList
                                    
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
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
            boardSearchViewModel.setKeyword(keyword)
            searchBar.endEditing(true)
            
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
                return boardList.count
            } else {
                return recentKeywords.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFiltering() {
            guard let recentKeywordCell = tableView.dequeueReusableCell(withIdentifier: "RecentKeywordTableViewCell", for: indexPath) as? RecentKeywordTableViewCell else { return UITableViewCell() }

            recentKeywordCell.configure(item: recentKeywords[indexPath.row])

            return recentKeywordCell
        } else {
            if isSearchButtonTapped {
                guard let cell = Bundle.main.loadNibNamed("CommunityBoardTableViewCell", owner: self, options: nil)?.first as? CommunityBoardTableViewCell else { return UITableViewCell() }

                cell.configure(item: boardList[indexPath.row])
                cell.selectionStyle = .none
                
                return cell
            } else {
                guard let recentKeywordCell = tableView.dequeueReusableCell(withIdentifier: "RecentKeywordTableViewCell", for: indexPath) as? RecentKeywordTableViewCell else { return UITableViewCell() }

                recentKeywordCell.configure(item: recentKeywords[indexPath.row])

                return recentKeywordCell
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
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate
extension BoardSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerVeiw = SearchHeaderView(isSearchButtonTapped, self.boardList.count)
        headerVeiw.delegate = self
        return headerVeiw
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
                print("상세보기")
            } else {
                guard let keyword = self.recentKeywords[indexPath.row].title else { return }
                
                self.searchBarView.searchBar.text = keyword
                boardSearchViewModel.setKeyword(keyword)
                fetchSearchResultList(page: self.page)
            }
        }
    }
}

extension BoardSearchViewController {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // UITableView only moves in one direction, y axis
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
                } else {
                    
                }
            }
        }
    }
}

protocol RecentKeywordTableViewCellDelegate: AnyObject {
    func deleteButtonTapped(row: Int?)
}

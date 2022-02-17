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

    var searchBarView = SearchBarView()
    var searchTypeSelectView = SearchTypeSelectView()
    var tableView = UITableView()
    var recentKeywords: [Keyword] = []
    
    let boardSearchViewModel = BoardSearchViewModel()
    let mockDatas = ["아이오닉5", "모델X", "일론머스크", "테슬라", "차박", "소프트베리", "EvInfra", "전기차", "니로", "전기"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardSearchViewModel.fetchKeywords()
        boardSearchViewModel.reloadTableViewClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        setNavigationController()
        setUI()
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
        
        // searchbar UI
        searchBarView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(72)
        }
        
        // searchTypeSelecteView UI
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
    
    func isSearchBarEmpty() -> Bool {
        return searchBarView.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return !isSearchBarEmpty()
    }
}

// MARK: - UITextFieldDelegate
extension BoardSearchViewController: UITextFieldDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        recentKeywords = boardSearchViewModel.filteredKeywords(keyword: searchText)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - UISearchBarDelegate
extension BoardSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let keyword = searchBar.text {
            boardSearchViewModel.setKeyword(keyword)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            searchBar.text = nil
            searchBar.endEditing(true)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}

// MARK: - UITableViewDataSource
extension BoardSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isFiltering() {
            return UITableViewAutomaticDimension
        } else {
            return 48
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return recentKeywords.count
        } else {
            return boardSearchViewModel.countOfKeywords()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let recentKeywordCell = tableView.dequeueReusableCell(withIdentifier: "RecentKeywordTableViewCell", for: indexPath) as? RecentKeywordTableViewCell else { return UITableViewCell() }
        
        if isFiltering() {
            recentKeywordCell.configure(item: recentKeywords[indexPath.row])
        } else {
            recentKeywordCell.configure(item: boardSearchViewModel.keyword(at: indexPath.row))
        }
        recentKeywordCell.delegate = self
        recentKeywordCell.index = indexPath.row
        
        return recentKeywordCell
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
        let headerVeiw = SearchHeaderView()
        headerVeiw.delegate = self
        return headerVeiw
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select")
    }
}

protocol RecentKeywordTableViewCellDelegate: AnyObject {
    func deleteButtonTapped(row: Int?)
}

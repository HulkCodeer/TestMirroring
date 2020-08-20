//
//  SearchTableView.swift
//  evInfra
//
//  Created by 이신광 on 14/03/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit

protocol SearchTableViewViewDelegate {
    func didAddrSelectRow(row: Int)
}

class SearchTableView: UITableView {
    
    var searchTableDelegate:SearchTableViewViewDelegate?
    
    var poiList: [EIPOIItem]? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        
        self.rowHeight = UITableViewAutomaticDimension
        self.estimatedRowHeight = 102
        
        // empty list의 separator 보이지 않도록 함
        self.tableFooterView = UIView()
        
        reloadData()
    }
}

extension SearchTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poiList?.count ?? 0
    }
    
    /// Prepares the cells within the tableView.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ChargerTableViewCell", owner: self, options: nil)?.first as! ChargerTableViewCell
        
        if indexPath.row >= (poiList?.count)! {
            return cell
        }
        
        guard let poi = poiList?[indexPath.row] else {
            return cell
        }
        
        cell.setAddrMode(item: poi)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchTableDelegate?.didAddrSelectRow(row: indexPath.row)
    }
}

extension SearchTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

//
//  CidTableView.swift
//  evInfra
//
//  Created by Shin Park on 2018. 4. 10..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

protocol ChargerTableViewDelegate {
    func didSelectRow(row: Int)
}

class ChargerTableView: UITableView {
    
    var chargerTableDelegate: ChargerTableViewDelegate?
    var chargerList: [ChargerStationInfo]? = nil
    var isHiddenAlertFavoriteIcon: Bool = false
    
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

extension ChargerTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chargerList?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// Prepares the cells within the tableView.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ChargerTableViewCell", owner: self, options: nil)?.first as! ChargerTableViewCell
        
        if indexPath.row >= (chargerList?.count)! {
            return cell
        }
        
        guard let charger = chargerList?[indexPath.row] else {
            return cell
        }
        
        cell.setCharger(item: charger)
        cell.setHidden(isOn: isHiddenAlertFavoriteIcon)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chargerTableDelegate?.didSelectRow(row: indexPath.row)
    }
}

extension ChargerTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

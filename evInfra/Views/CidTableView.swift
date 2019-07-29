//
//  CidTableView.swift
//  evInfra
//
//  Created by Shin Park on 2018. 3. 16..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

class CidTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    struct Constants {
        static let cellHeight: CGFloat = 60
    }
    
    var cidList = [CidInfo]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        self.autoresizingMask = UIViewAutoresizing.flexibleHeight
        
        reloadData()
    }
    
    func setCidList(chargerList: [CidInfo]) {
        cidList = chargerList
    }

    // MARK: - TableView DataSource and Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cidList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CidTableViewCell", for: indexPath) as! CidTableViewCell
        let cInfo = cidList[indexPath.row]
        
        // 충전기 상태
        cell.statusLabel.text = cInfo.cstToString(cst: cInfo.status)
        cell.statusLabel.textColor = cInfo.getCstColor(cst: cInfo.status)
        
        // 충전기 타입
        cell.setChargerTypeImage(type: cInfo.chargerType)
        
        // 최근 충전일
        if cInfo.recentDate != nil && ((cInfo.recentDate?.count)! > 0) {
            if cInfo.status == Const.CHARGER_STATE_CHARGING {
                cell.dateKind.text = "경과시간"
                cell.lastDate.text = cInfo.getChargingDuration()
            } else {
                cell.dateKind.text = "충전완료"
                cell.lastDate.text = cInfo.getRecentDateSimple()
            }
        } else {
            cell.dateKind.text = ""
            cell.lastDate.text = ""
        }
        
        if let pw = cInfo.power, pw > 0 {
            cell.powerLable.text = String(pw) + "kW"
        } else {
            cell.powerLable.text = ""
        }
        
        return cell
    }
}

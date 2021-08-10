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
        let cidInfo = cidList[indexPath.row]
        let cell = Bundle.main.loadNibNamed("CidInfoTableViewCell", owner: self, options: nil)?.first as! CidInfoTableViewCell
        
        // 충전기 상태
//        cell.statusLabel.text = cInfo.cstToString(cst: cInfo.status)
//        cell.statusLabel.textColor = cInfo.getCstColor(cst: cInfo.status)
//
//        // 충전기 타입
//        cell.setChargerTypeImage(type: cInfo.chargerType)
//
//        // 최근 충전일
//        if cInfo.recentDate != nil && ((cInfo.recentDate?.count)! > 0) {
//            cell.dateKind.roundCorners(.allCorners, radius: 5)
//
//            if cInfo.status == Const.CHARGER_STATE_CHARGING {
//                cell.lastDate.text = cInfo.getChargingDuration()
//                cell.dateKind.text = "경과시간"
//                cell.dateKind.backgroundColor = UIColor(hex: "#DFECF3")
//            } else {
//                //cell.lastDate.text = cInfo.getRecentDateSimple()
//                if let dateString = cInfo.recentDate {
//                    cell.lastDate.text = DateUtils.getDateStringForDetail(date: dateString)
//                }
//                cell.dateKind.text = "마지막 사용"
//                cell.dateKind.backgroundColor = UIColor(hex: "#E2E2E2")
//            }
//        } else {
//            cell.dateKind.roundCorners(.allCorners, radius: 5)
//            cell.dateKind.text = "마지막 사용"
//            cell.lastDate.text = "알 수 없음"
//            cell.dateKind.backgroundColor = UIColor(hex: "#E2E2E2")
//        }
//
//        if let pw = cInfo.power, pw > 0 {
//            cell.powerLable.text = String(pw) + "kW"
//        } else {
//            cell.powerLable.text = ""
//        }

        return cell
    }
}

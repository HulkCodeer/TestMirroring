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
        static let cellHeight: CGFloat = 95 // 93
        static let goneHeight: CGFloat = 60
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let cidInfo = cidList[indexPath.row]

        if cidInfo.chargerType == Const.CHARGER_TYPE_SLOW { // heddien
            return Constants.goneHeight
        } else{
            return Constants.cellHeight
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let cidInfo = cidList[indexPath.row]
//        let cell = Bundle.main.loadNibNamed("CidInfoTableViewCell", owner: self, options: nil)?.first as! CidInfoTableViewCell
//
//        if cidInfo.chargerType == Const.CHARGER_TYPE_SLOW {
//            Constants.goneHeight = Constants.cellHeight - cell.getDividerHeight()
//            return self.goneCellHeight()
//        }
//        return Constants.cellHeight
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cidInfo = cidList[indexPath.row]
        let cell = Bundle.main.loadNibNamed("CidInfoTableViewCell", owner: self, options: nil)?.first as! CidInfoTableViewCell
        
        // 충전기 상태
        cell.statusLabel.text = cidInfo.cstToString(cst: cidInfo.status)
        cell.statusLabel.textColor = cidInfo.getCstColor(cst: cidInfo.status)
        cell.statusImg.tintColor = cidInfo.getCstColor(cst: cidInfo.status)
        if cidInfo.status != Const.CHARGER_STATE_CHECKING && cidInfo.status != Const.CHARGER_STATE_UNCONNECTED &&
            cidInfo.status != Const.CHARGER_STATE_UNKNOWN{
            if isChargePower(position: indexPath.row) {
                cell.statusBtn.isHidden = false
                if cidInfo.power == 0 {
                    cell.powerLable.text = "50 kW"
                }else{
                    cell.powerLable.text = String(cidInfo.power) + "kW"
                }
            }
        }else{
            if isChargePower(position: indexPath.row) {
                cell.statusBtn.isHidden = false
                cell.powerLable.text = "완속"
            }
        }
        
//         충전기 타입
        cell.setChargerTypeImage(type: cidInfo.chargerType)

//        // 최근 충전일
        if cidInfo.recentDate != nil && ((cidInfo.recentDate?.count)! > 0) {
            cell.dateKind.roundCorners(.allCorners, radius: 5)

            if cidInfo.status == Const.CHARGER_STATE_CHARGING {
                cell.lastDate.text = cidInfo.getChargingDuration()
                cell.dateKind.text = "경과시간"
                cell.dateKind.backgroundColor = UIColor(hex: "#DFECF3")
            } else {
                if let dateString = cidInfo.recentDate {
                    cell.lastDate.text = DateUtils.getDateStringForDetail(date: dateString)
                }
                cell.dateKind.text = "마지막 사용"
                cell.dateKind.backgroundColor = UIColor(hex: "#E2E2E2")
            }
        } else {
            cell.dateKind.roundCorners(.allCorners, radius: 5)
            cell.dateKind.text = "마지막 사용"
            cell.lastDate.text = "알 수 없음"
            cell.dateKind.backgroundColor = UIColor(hex: "#E2E2E2")
        }

        return cell
    }
    
    public func goneCellHeight() -> CGFloat {
        let cell = Bundle.main.loadNibNamed("CidInfoTableViewCell", owner: self, options: nil)?.first as! CidInfoTableViewCell
        return Constants.cellHeight - cell.getDividerHeight()
    }
    
    func isChargePower(position:Int) -> Bool {
        if position > 0 {
            return cidList[position-1].power != cidList[position].power
        }
        return true
    }
}

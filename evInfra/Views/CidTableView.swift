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
        static let cellHeight: CGFloat = 96
        static let goneHeight: CGFloat = 64
    }
    
    var cidInfoList = [CidInfo]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        self.autoresizingMask = UIViewAutoresizing.flexibleHeight
        
        reloadData()
    }
    
    func setCidInfoList(infoList: [CidInfo]) {
        cidInfoList = infoList
    }

    // MARK: - TableView DataSource and Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cidInfoList.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let slow = cidInfoList[indexPath.row].chargerType == Const.CHARGER_TYPE_SLOW || cidInfoList[indexPath.row].chargerType == Const.CHARGER_TYPE_DESTINATION
        if slow {
            if indexPath.row != 0 && isChangeType(position: indexPath.row){
                return Constants.cellHeight
            } else {
                return Constants.goneHeight
            }
        } else {
            if isChangePower(position: indexPath.row) {
                return Constants.cellHeight
            } else {
                return Constants.goneHeight
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let slow = cidInfoList[indexPath.row].chargerType == Const.CHARGER_TYPE_SLOW || cidInfoList[indexPath.row].chargerType == Const.CHARGER_TYPE_DESTINATION
        if slow {
            if indexPath.row != 0 && isChangeType(position: indexPath.row){
                return Constants.cellHeight
            } else {
                return Constants.goneHeight
            }
        } else {
            if isChangePower(position: indexPath.row) {
                return Constants.cellHeight
            } else {
                return Constants.goneHeight
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cidInfo = cidInfoList[indexPath.row]
        let cell = Bundle.main.loadNibNamed("CidInfoTableViewCell", owner: self, options: nil)?.first as! CidInfoTableViewCell
        
        // 충전기 상태
        cell.statusLabel.text = cidInfo.cstToString(cst: cidInfo.status)
        cell.statusLabel.textColor = cidInfo.getCstColor(cst: cidInfo.status)
        cell.statusImg.tintColor = cidInfo.getCstColor(cst: cidInfo.status)
        
        if cidInfo.status != Const.CHARGER_STATE_UNCONNECTED && cidInfo.status != Const.CHARGER_STATE_UNKNOWN {
            cell.statusBtn.gone()
        }
        
        if let limit = cidInfo.limit, limit != "Y" {
            cell.lockBtn.isHidden = true
        }
        
        if cidInfo.chargerType != Const.CHARGER_TYPE_SLOW && cidInfo.chargerType != Const.CHARGER_TYPE_DESTINATION &&
            cidInfo.chargerType != Const.CHARGER_TYPE_ETC{
            if isChangePower(position: indexPath.row) {
                cell.dividerView.isHidden = false
                if cidInfo.power == 0 {
                    cell.powerLable.text = "50 kW"
                }else{
                    cell.powerLable.text = String(cidInfo.power) + "kW"
                }
            }else{
                cell.dividerView.isHidden = true
            }
        }else{
            if indexPath.row > 0 && isChangeType(position: indexPath.row){
                cell.dividerView.isHidden = false
                cell.powerLable.text = "완속"
            } else {
                cell.dividerView.isHidden = true
            }
        }
        
//         충전기 타입
        cell.setChargerTypeImage(type: cidInfo.chargerType)

        
        // 최근 충전일
        if cidInfo.recentDate != nil && ((cidInfo.recentDate?.count)! > 0) {
            if cidInfo.status == Const.CHARGER_STATE_CHARGING {
                cell.lastDate.text = cidInfo.getChargingDuration()
                cell.dateKind.setTitle("경과시간", for: .normal)
            } else {
                if let dateString = cidInfo.recentDate {
                    cell.lastDate.text = DateUtils.getDateStringForDetail(date: dateString)
                }
                cell.dateKind.setTitle("마지막 사용", for: .normal)
            }
        } else {
            cell.dateKind.setTitle("마지막 사용", for: .normal)
            cell.lastDate.text = "알 수 없음"
        }
        layoutIfNeeded()

        return cell
    }
    
    func isChangePower(position:Int) -> Bool {
        if position > 0 {
            return cidInfoList[position-1].power != cidInfoList[position].power
        }
        return true
    }
    
    func isChangeType(position:Int) -> Bool {
        if position > 0 {
            return cidInfoList[position-1].chargerType != cidInfoList[position].chargerType
        }
        return true
    }
}

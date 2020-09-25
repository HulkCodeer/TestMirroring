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
    var waitTimeStatus = Array<WaitTimeStatus>()
	
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        self.autoresizingMask = UIViewAutoresizing.flexibleHeight
        
        reloadData()
    }
    
	func setCidList(chargerList: [CidInfo], waitTimeStatus:[WaitTimeStatus]) {
        cidList = chargerList
		self.waitTimeStatus = waitTimeStatus
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
		var statusInfo:WaitTimeStatus? = nil
		for item in waitTimeStatus{
			if(cInfo.cid == item.cid){
				statusInfo = item
				break
			}
		}
        // 충전기 상태
        cell.statusLabel.text = cInfo.cstToString(cst: cInfo.status)
        cell.statusLabel.textColor = cInfo.getCstColor(cst: cInfo.status)
        
        // 충전기 타입
        cell.setChargerTypeImage(type: cInfo.chargerType)
        
        // 최근 충전일
	
//            if cInfo.status == Const.CHARGER_STATE_CHARGING {
//                cell.dateKind.text = "경과시간"
//                cell.lastDate.text = cInfo.getChargingDuration()
//            } else {
//                cell.dateKind.text = "충전완료"
//                cell.lastDate.text = cInfo.getRecentDateSimple()
//            }
		if cInfo.status == Const.CHARGER_STATE_CHARGING {
			let waitTime = Int(statusInfo?.remain_time ?? -1)
			var waitText = ""
			if(waitTime == -1){
				cell.dateKind.text = "경과시간"
				waitText = cInfo.getChargingDuration()
			}else{
				if(waitTime > 0){
					cell.dateKind.text = "예상대기"
					waitText = "\(waitTime)분"
				}else{
					waitText = "충전중"
					cell.dateKind.text = "80% 이상"
				}
			}
			cell.lastDate.text = waitText
		} else {
			if cInfo.recentDate != nil && ((cInfo.recentDate?.count)! > 0) {
				cell.dateKind.text = "충전완료"
				cell.lastDate.text = cInfo.getRecentDateSimple()
			} else {
				cell.dateKind.text = ""
				cell.lastDate.text = ""
			}
		}
        
        
        if let pw = cInfo.power, pw > 0 {
            cell.powerLable.text = String(pw) + "kW"
        } else {
            cell.powerLable.text = ""
        }
        
        return cell
    }
}

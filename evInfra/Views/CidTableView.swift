//
//  CidTableView.swift
//  evInfra
//
//  Created by Shin Park on 2018. 3. 16..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

class CidTableView: UITableView, UITableViewDataSource, UITableViewDelegate{

	
    struct Constants {
       // static let cellHeight: CGFloat = 60
     static let cellHeight: CGFloat = 60
	 static let	expandedcellHeight:CGFloat = 100
	}
    
    var cidList = [CidInfo]()
    var waitTimeStatus = Array<WaitTimeStatus>()
	var clickedNum = 0
	var clickedIndex = Array<Int>()
	var tableDelegate:TableDelegate? = nil
	
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        self.autoresizingMask = UIViewAutoresizing.flexibleHeight
        
        reloadData()
    }
    
	func setDelegate(delegate:TableDelegate){
		self.tableDelegate = delegate
	}
	
	func setCidList(chargerList: [CidInfo], waitTimeStatus:[WaitTimeStatus]) {
        cidList = chargerList
		self.waitTimeStatus = waitTimeStatus
    }

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell:CidTableViewCell = tableView.cellForRow(at: indexPath) as! CidTableViewCell
		let cInfo = cidList[indexPath.row]
		var statusInfo:WaitTimeStatus? = nil
		for item in waitTimeStatus{
			if(cInfo.cid == item.cid){
				statusInfo = item
				break
			}
		}
		cell.statusLabel.highlightedTextColor = cInfo.getCstColor(cst: cInfo.status)
		
		if cInfo.status == Const.CHARGER_STATE_CHARGING {
			let waitTime = Int(statusInfo?.remain_time ?? -1)
			cell.lastDate.contentEdgeInsets = UIEdgeInsets(
				top : 0,
				left : 10,
				bottom : 0, right :10
			)
			if(waitTime <= 0 && waitTime != -1){
				DispatchQueue.main.async {
					if(self.clickedIndex.contains(indexPath.row)){
						self.clickedIndex = self.clickedIndex.filter(){
							$0 as Int != indexPath.row}
						cell.waitTimeView.isHidden = true
						cell.waitTimeView.frame = CGRect(x:0, y: 0, width: cell.waitTimeView.frame.width, height: 0)
					}else{
						self.clickedIndex.append(indexPath.row)
						cell.waitTimeView.isHidden = false
						cell.waitTimeView.frame = CGRect(x:0, y: 0, width: cell.waitTimeView.frame.width, height: 40)
					}
					tableView.beginUpdates()
					tableView.endUpdates()
					cell.waitTimeView.setNeedsDisplay()
					self.tableDelegate?.updateHeight(allNum: self.cidList.count, clickedNum: self.clickedIndex.count)
				}
			}
		}
	}
	
    // MARK: - TableView DataSource and Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cidList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if(clickedIndex.contains(indexPath.row)){
			return Constants.expandedcellHeight
		}else {
			return Constants.cellHeight
		}
    }
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		print("ejlim set data \(indexPath.row)")
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
		print("ejlim color \(indexPath.row) \(cell.statusLabel.textColor)")
		
        // 충전기 타입
        cell.setChargerTypeImage(type: cInfo.chargerType)
        
		cell.lastDate.isUserInteractionEnabled = false;
		
		cell.waitTimeView.bringSubview(toFront: cell.mainView)
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
					cell.lastDate.semanticContentAttribute = UIApplication.shared
					.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
					cell.lastDate.setImage(UIImage(named: "help_text_btn"), for:.normal)
					//cell.above80Image.isHidden = false
				}
			}
			cell.lastDate.setTitle(waitText, for: UIControlState.normal)
		} else {
			if cInfo.recentDate != nil && ((cInfo.recentDate?.count)! > 0) {
				cell.dateKind.text = "충전완료"
				cell.lastDate.setTitle(cInfo.getRecentDateSimple(), for: UIControlState.normal)
			} else {
				cell.dateKind.text = ""
				cell.lastDate.setTitle("", for: UIControlState.normal)
			}
		}
		cell.lastDate.titleLabel?.textAlignment = .center
        
        if let pw = cInfo.power, pw > 0 {
            cell.powerLable.text = String(pw) + "kW"
        } else {
            cell.powerLable.text = ""
        }
        return cell
    }
}

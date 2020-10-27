//
//  ReportBoardViewController.swift
//  evInfra
//
//  Created by 이신광 on 2018. 9. 18..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
import Motion
import SwiftyJSON

class ReportBoardViewController: UIViewController {
   
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var rList = Array<ReportChargeItem>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareInitView()
        
        getReporInfoList(key:0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(onClickBackBtn), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "나의 제보 내역"
        navigationController?.isNavigationBarHidden = false
    }
    
    func prepareInitView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.tableView.separatorColor = UIColor(rgb: 0xE4E4E4)
        self.tableView.tableFooterView = UIView() // empty list의 separator 보이지 않도록 함
        self.emptyLabel.isHidden = true
        self.tableView.isHidden = true
    }
    
    @objc
    fileprivate func onClickBackBtn() {
        self.navigationController?.pop()
    }

    func getReporInfoList(key: Int) {
        if key == 0 {
            self.rList.removeAll()
        }
        
        Server.getReportList(key: key) { (isSuccess, responseData) in
            if isSuccess {
                if let data = responseData {
                    let info = try! JSONDecoder().decode(ReportChargeInfoList.self, from: data)
                    if let _ = info.lists {
                        for item in info.lists! {
                            let row = ReportChargeItem.init(item: item)
                            self.rList.append(row)
                        }
                        if (info.lists?.count)! > 0 {
                            self.tableView.reloadData()
                        }
                    }
                    
                    if self.rList.count <= 0 {
                        self.emptyLabel.isHidden = false
                        self.tableView.isHidden = true
                    } else {
                        self.emptyLabel.isHidden = true
                        self.tableView.isHidden = false
                    }
                }
            }
        }
    }
}

extension ReportBoardViewController : ReportChargeViewDelegate {
    func goToReportChargerPage(index:Int) {
        let reportChargeVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportChargeViewController") as! ReportChargeViewController
        reportChargeVC.delegate = self
        reportChargeVC.info.from = Const.REPORT_CHARGER_FROM_LIST
        reportChargeVC.info.report_id = self.rList[index].pkey
        reportChargeVC.info.type_id = self.rList[index].type_id
        reportChargeVC.info.lat = self.rList[index].latitude
        reportChargeVC.info.lon = self.rList[index].longitude
        reportChargeVC.info.status_id = self.rList[index].status_id
        reportChargeVC.info.adr = self.rList[index].address
        reportChargeVC.info.snm = self.rList[index].station_name
        reportChargeVC.info.charger_id = self.rList[index].charger_id
        
        if let chargerId = self.rList[index].charger_id {
            if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerId){
                reportChargeVC.info.company_id = charger.mStationInfoDto?.mCompanyId
            }
        }
        
        self.present(AppSearchBarController(rootViewController: reportChargeVC), animated: true, completion: nil)
    }
    
    func getReportInfo() {
        self.getReporInfoList(key: 0)
    }
}

extension ReportBoardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToReportChargerPage(index:indexPath.row)
    }
}

extension ReportBoardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.rList.count <= 0 {
            return 0
        }
        return self.rList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath) as! ReportBoardTableViewCell
        let item = self.rList[indexPath.row]
        
        cell.stationName.text = item.station_name
        cell.rType.text = item.type
        cell.status.text = item.status
        cell.rDate.text = item.reg_date
        cell.adminCommnet.text = ""

        if(item.status_id == Const.REPORT_CHARGER_STATUS_REJECT) {
            if let msg = item.adminComment, !msg.isEmpty {
                cell.adminCommnet.text = msg
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if maximumOffset - currentOffset <= scrollView.frame.size.height {
            if self.rList.count > 0 {
                if let pkey = self.rList[self.rList.count-1].pkey {
                    getReporInfoList(key: pkey)
                } else {
                    getReporInfoList(key: 0)
                }
            } else {
                getReporInfoList(key: 0)
            }
        }
    }
}

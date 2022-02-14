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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var reportList = Array<ReportCharger>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareInitView()
        
        getReportList(reportId:0)
    }

    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(onClickBackBtn), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
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

    func getReportList(reportId: Int) {
        if reportId <= 0 {
            self.reportList.removeAll()
        }
        
        Server.getReportList(reportId: reportId) { (isSuccess, value) in

            if isSuccess {
                let json = JSON(value)
                if json["code"].intValue == 1000 {
                    let list = json["list"]
                    if list.count > 0 {
                        for item in list.arrayValue {
                            self.reportList.append(ReportCharger(json: item))
                        }
                        self.tableView.reloadData()
                    }
                }

                if self.reportList.count <= 0 {
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

extension ReportBoardViewController: ReportChargeViewDelegate {
    func goToReportChargerPage(index:Int) {
        let reportChargeVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportChargeViewController") as! ReportChargeViewController
        reportChargeVC.delegate = self
        reportChargeVC.info.charger_id = self.reportList[index].charger_id
        
        self.present(AppSearchBarController(rootViewController: reportChargeVC), animated: true, completion: nil)
    }
    
    func getReportInfo() {
        getReportList(reportId: 0)
    }
}

extension ReportBoardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToReportChargerPage(index:indexPath.row)
    }
}

extension ReportBoardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath) as! ReportBoardTableViewCell
        let item = reportList[indexPath.row]
        
        cell.selectionStyle = .none
        cell.stationName.text = item.snm
        cell.rType.text = String(item.type!)
        cell.status.text = String(item.status!)
        cell.rDate.text = item.reg_date
        cell.adminCommnet.text = ""
        if item.status_id == ReportCharger.REPORT_CHARGER_STATUS_REJECT {
            if let msg = item.admin_cmt, !msg.isEmpty {
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
            if reportList.count > 0 {
                let lastId = self.reportList[self.reportList.count - 1].report_id
                getReportList(reportId: lastId)
            } else {
                getReportList(reportId: 0)
            }
        }
    }
}

//
//  ReportBoardViewController.swift
//  evInfra
//
//  Created by 이신광 on 2018. 9. 18..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Motion
import SwiftyJSON

internal final class ReportBoardViewController: UIViewController {
    
    private lazy var customNavibar = CommonNaviView().then {
        $0.naviTitleLbl.text = "나의 제보 내역"
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    private var reportList = Array<ReportCharger>()
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(customNavibar)
        customNavibar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareInitView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
            guard let self = self else { return }
            if isLogin {
                self.getReportList(reportId:0)
            } else {
                MemberManager.shared.showLoginAlert()
            }
        }
    }
    
    func prepareInitView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.separatorColor = UIColor(rgb: 0xE4E4E4)
        self.tableView.tableFooterView = UIView() // empty list의 separator 보이지 않도록 함
        self.emptyLabel.isHidden = true
        self.tableView.isHidden = true
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

extension ReportBoardViewController { //: ReportChargeViewDelegate {
    func goToReportChargerPage(index:Int) {
        let viewcon = UIStoryboard(name : "Report", bundle: nil).instantiateViewController(ofType: ReportChargeViewController.self)
        viewcon.info.charger_id = self.reportList[index].charger_id
        self.present(viewcon, animated: true)
        
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
        return UITableView.automaticDimension
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

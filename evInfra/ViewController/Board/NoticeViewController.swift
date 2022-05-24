//
//  NoticeViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 3. 2..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON

class NoticeViewController: UIViewController {
    var boardList: JSON!
    
    @IBOutlet weak var tableView: UITableView!
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareActionBar()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.tableView.separatorColor = UIColor(rgb: 0xE4E4E4)
        self.tableView.estimatedRowHeight = 102
        
        self.getNoticeData()
    }
}

extension NoticeViewController {
    func prepareActionBar() {
        var backButton: IconButton!
        backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "공지사항"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }

    func getNoticeData() {
        Server.getNoticeList() { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if let code = json["code"].int {
                    if code == 1000 {
                        self.boardList = json["list"]
                        
                        // 최신글 id update
                        if self.boardList.count > 0 {
                            let id = self.boardList.arrayValue[0]["id"].intValue
                            UserDefault().saveInt(key: UserDefault.Key.LAST_NOTICE_ID, value: id)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
}

extension NoticeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.boardList == nil {
            return 0
        }

        if (self.boardList.arrayValue.count == 0 || self.boardList == JSON.null) {
            return 0
        }
        
        return self.boardList.arrayValue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath) as! NoticeTableViewCell
        let noticeValue = self.boardList.arrayValue[indexPath.row]

        cell.noticeTitle?.text = noticeValue["title"].stringValue
        cell.dateTime?.text = Date().toStringToMinute(data: noticeValue["datetime"].stringValue)
        return cell
    }
    
    func tableView(_ tableView : UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let noticeContentVC = self.storyboard?.instantiateViewController(withIdentifier: "NoticeContentViewController") as! NoticeContentViewController
        noticeContentVC.boardId = self.boardList.arrayValue[indexPath.row]["id"].intValue
        self.navigationController?.push(viewController: noticeContentVC)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

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
import RxSwift
import SnapKit
import Then

internal class NoticeViewController: BaseViewController {
    var boardList: JSON!
    
    private lazy var tableView = UITableView().then {
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = UITableViewAutomaticDimension
        $0.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        $0.separatorColor = UIColor(rgb: 0xE4E4E4)
        $0.estimatedRowHeight = 102
        $0.register(NoticeTableViewCell.self, forCellReuseIdentifier: "noticeCell")
    }
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareActionBar(with: "공지사항")
        layout()

        
        
        
        // reactor 파일로 이동
        self.getNoticeData()
    }
}

extension NoticeViewController {
    private func layout() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
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

        cell.noticeTitleLbl.text = noticeValue["title"].stringValue
        cell.dateTimeLbl.text = Date().toStringToMinute(data: noticeValue["datetime"].stringValue)

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

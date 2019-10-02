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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var boardList: JSON!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareActionBar()

        self.getNoticeData()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.tableView.separatorColor = UIColor(rgb: 0xE4E4E4)
        self.tableView.estimatedRowHeight = 102
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension NoticeViewController {
    func prepareActionBar() {
        var backButton: IconButton!
        backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "공지사항"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }

    func getNoticeData() {
        Server.getBoard(category: BoardData.BOARD_CATEGORY_NOTICE) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                self.boardList = json["lists"]
                if let id = self.boardList.arrayValue[0]["id"].int {
                    UserDefault().saveInt(key: UserDefault.Key.LAST_NOTICE_ID, value: id)
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
        
        cell.nickName?.text = noticeValue["nick_name"].stringValue
        cell.noticeTitle?.text = noticeValue["subject"].stringValue
        cell.dateTime?.text = Date().toStringToMinute(data: noticeValue["datetime"].stringValue)
        return cell
    }
    
    func tableView(_ tableView : UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let ndVC:NoticeDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "NoticeDetailViewController") as! NoticeDetailViewController
        ndVC.boardList = self.boardList
        ndVC.noticeIndex = indexPath.row
        self.navigationController?.push(viewController: ndVC)
        //Todo: Function for Click
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

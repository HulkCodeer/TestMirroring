//
//  NoticeContentViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 20..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON

class NoticeContentViewController: UIViewController {

    @IBOutlet weak var content: UITextView!
    
    var boardId = -1
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        
        content.textContainerInset = UIEdgeInsetsMake(16, 16, 16, 16)
        content.isEditable = false
        content.dataDetectorTypes = .link
        content.sizeToFit()
        
        getNoticeContent()
    }
    
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
    
    private func getNoticeContent() {
        if self.boardId > -1 {
            Server.getNoticeContent(noticeId: self.boardId) { (isSuccess, value) in
                if isSuccess {
                    let json = JSON(value)
                    let code = json["code"].intValue
                    if code == 1000 {
                        self.navigationItem.titleLabel.text = json["title"].stringValue
                        self.content.text = json["content"].stringValue
                    }
                }
            }
        }
    }
}

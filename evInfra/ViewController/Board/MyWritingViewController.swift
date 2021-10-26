//
//  MyWritingViewController.swift
//  evInfra
//
//  Created by bulacode on 30/10/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import UIKit
import Material
import Motion
import SwiftyJSON

class MyWritingViewController: UIViewController {
    
    @IBOutlet weak var boardTableView: BoardTableView!
    
    var currentPage = 0
    var preReadPage = 0
    var lastPage: Bool = false
    var boardList: Array<BoardItem> = Array<BoardItem>()
    var boardCategory = ""
    var scrollIndexPath = IndexPath(row: 0, section: 0)
    var visibleSection: UITableViewCell? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTabItem()
        getFirstBoardData()

        boardTableView.tableViewDelegate = self
        boardTableView.rowHeight = UITableViewAutomaticDimension
        boardTableView.estimatedRowHeight = UITableViewAutomaticDimension
        boardTableView.separatorColor = UIColor(rgb: 0xE4E4E4)
        boardTableView.separatorInset = .zero
        boardTableView.separatorStyle = .none
        boardTableView.allowsSelection = false
        
        boardTableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        boardTableView.estimatedSectionHeaderHeight = 25;

        boardTableView.layoutIfNeeded()
        boardTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Recalculates height
        boardTableView.layoutIfNeeded()
    }
}

extension MyWritingViewController {
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)

        let editButton = IconButton(image: Icon.cm.edit)
        editButton.tintColor = UIColor(named: "content-primary")
        editButton.addTarget(self, action: #selector(handleEditButton), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        
        if (boardCategory.elementsEqual(Board.BOARD_CATEGORY_FREE)) {
            navigationItem.rightViews = [editButton]
        }
        
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "내글보기"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareTabItem() {
        if (boardCategory.elementsEqual(Board.BOARD_CATEGORY_FREE)) {
            tabItem.title = "자유게시판"
        } else if (boardCategory.elementsEqual(Board.BOARD_CATEGORY_CHARGER)) {
            tabItem.title = "충전소게시판"
        }
        tabItem.setTitleColor(UIColor(named: "content-primary")!, for: .selected)
        tabItem.setTitleColor(Color.grey.base, for: .normal)
    
//        tabItem.addTarget(self, action: #selector(handleBackButton) for: .selected)
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    @objc
    fileprivate func handleEditButton() {
        let editVC:EditViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        editVC.mode = EditViewController.BOARD_NEW_MODE
        editVC.editViewDelegate = self
        self.navigationController?.push(viewController: editVC)
    }
}

extension MyWritingViewController: BoardTableViewDelegate {
    
    func getFirstBoardData() {
        self.currentPage = 0
        self.lastPage = false
        let pageCount = BoardTableView.PAGE_DATA_COUNT + (BoardTableView.PAGE_DATA_COUNT * self.preReadPage)
        Server.getBoard(category: boardCategory, page: currentPage, count: pageCount, mine: true) { (isSuccess, value) in
            if isSuccess {
                self.boardList.removeAll()
                let json = JSON(value)
                let boardJson = json["list"]
                for json in boardJson.arrayValue {
                    let boardData = BoardItem(bJson: json)
                    self.boardList.append(boardData)
                }
                
                self.boardTableView.boardList = self.boardList
                self.boardTableView.category = self.boardCategory
                self.boardTableView.reloadData()
                if self.preReadPage > 0 {
                    self.boardTableView.scrollToRow(at: self.scrollIndexPath , at: UITableViewScrollPosition.top, animated: true)
                    self.scrollIndexPath = IndexPath(row: 0, section: 0)
                    self.currentPage = self.preReadPage
                    self.preReadPage = 0
                }
            }
        }
    }
    
    func getNextBoardData() {
        if lastPage == false {
            self.currentPage = self.currentPage + 1
            Server.getBoard(category: boardCategory, page: currentPage, count: BoardTableView.PAGE_DATA_COUNT, mine: true) { (isSuccess, value) in
                if isSuccess {
                    let json = JSON(value)
                    let updateList = json["list"]
                    if updateList.count == 0 {
                        self.lastPage = true
                        return
                    }
                    
                    for json in updateList.arrayValue{
                        let boardData = BoardItem(bJson: json)
                        self.boardList.append(boardData)
                    }
                    self.boardTableView.boardList = self.boardList
                    self.boardTableView.layoutIfNeeded()
                    self.boardTableView.reloadData()
                }
            }
        }
    }
    
    func boardEdit(tag: Int) {
        let editVC:EditViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        editVC.mode = EditViewController.BOARD_EDIT_MODE
        editVC.originBoardData = self.boardList[tag]
        editVC.editViewDelegate = self
        self.navigationController?.push(viewController: editVC)
    }
    
    func boardDelete(tag: Int) {
        let dialogMessage = UIAlertController(title: "Notice", message: "게시글을 삭제하시겠습니까?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {(ACTION) -> Void in
            Server.deleteBoard(category: self.boardCategory, boardId: self.boardList[tag].boardId!) { (isSuccess, value) in
                if isSuccess {
                    self.preReadPage = self.currentPage
                    
                    if let lastVisibleRow = self.boardTableView.indexPathsForVisibleRows!.last{
                        self.scrollIndexPath = IndexPath(row: 0, section: lastVisibleRow.section)
                    }else{
                        self.scrollIndexPath = IndexPath(row: 0, section: 0)
                    }
                    self.getFirstBoardData()
                }
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:{ (ACTION) -> Void in
            print("Cancel button tapped")
        })
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func makeReply(tag: Int) {
        let editVC:EditViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        editVC.mode = EditViewController.REPLY_NEW_MODE
        editVC.originBoardId = tag
        editVC.editViewDelegate = self
        self.navigationController?.push(viewController: editVC)
    }
    
    func replyEdit(tag: Int) {
        let section = tag / 1000
        let row = tag % 1000
        let replyValue = self.boardList[section].reply![row]
        
        let editVC:EditViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        editVC.mode = EditViewController.REPLY_EDIT_MODE
        editVC.originReplyData = replyValue
        editVC.editViewDelegate = self
        
        self.navigationController?.push(viewController: editVC)
    }
    
    func replyDelete(tag: Int) {
        let dialogMessage = UIAlertController(title: "Notice", message: "댓글을 삭제하시겠습니까?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {(ACTION) -> Void in
            let section = tag / 1000
            let row = tag % 1000
            let replyValue = self.boardList[section].reply![row]
            Server.deleteReply(category: self.boardCategory, boardId: replyValue.replyId!) { (isSuccess, value) in
                if isSuccess {
                    self.preReadPage = self.currentPage
                    if let lastVisibleRow = self.boardTableView.indexPathsForVisibleRows!.last {
                        self.scrollIndexPath = IndexPath(row: 0, section: lastVisibleRow.section)
                    } else {
                        self.scrollIndexPath = IndexPath(row: 0, section: 0)
                    }
                    self.getFirstBoardData()
                }
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:{ (ACTION) -> Void in
            print("Cancel button tapped")
        })
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func goToStation(tag: Int) {
        let detailStoryboard = UIStoryboard(name : "Detail", bundle: nil)
        let detailVC:DetailViewController = detailStoryboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        if let chargerId = self.boardList[tag].chargerId {
            if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerId) {
                detailVC.charger = charger
                self.navigationController?.push(viewController: detailVC, subtype: kCATransitionFromTop)
            }
        }
    }
}

extension MyWritingViewController: EditViewDelegate {
    
    func postBoardData(content: String, hasImage: Int, picture: Data?) {
        Server.postBoard(category: boardCategory, bmId: -1, content: content, hasImage: hasImage) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if hasImage == 1 {
                    let filename =  json["file_name"].stringValue
                    if let data = picture{
                        Server.uploadImage(data: data, filename: "\(filename).jpg", kind: Const.CONTENTS_BOARD_IMG, targetId: json["board_id"].stringValue, completion: { (isSuccess, value) in
                            let json = JSON(value)
                            if(isSuccess){
                                self.preReadPage = 0
                                self.getFirstBoardData()
                            }else{
                                print("upload image Error : \(json)")
                            }
                            
                        })
                    }
                } else {
                    self.preReadPage = 0
                    self.getFirstBoardData()
                }
            }
        }
    }
    
    func editBoardData(content: String, boardId: Int, editImage: Int, picture: Data?) {
        Server.editBoard(category: boardCategory, boardId: boardId, content: content, editImage: editImage) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if editImage == 1 {
                    let filename =  json["file_name"].stringValue
                    if let data = picture {
                        Server.uploadImage(data: data, filename: "\(filename).jpg", kind: Const.CONTENTS_BOARD_IMG, targetId: json["board_id"].stringValue, completion: { (isSuccess, value) in
                            let json = JSON(value)
                            if isSuccess {
                                self.preReadPage = 0
                                self.getFirstBoardData()
                            } else {
                                print("upload image Error : \(json)")
                            }
                        })
                    }
                } else {
                    self.preReadPage = self.currentPage
                    if let lastVisibleRow = self.boardTableView.indexPathsForVisibleRows!.last {
                        self.scrollIndexPath = IndexPath(row: 0, section: lastVisibleRow.section)
                    } else {
                        self.scrollIndexPath = IndexPath(row: 0, section: 0)
                    }
                    self.getFirstBoardData()
                }
            }
        }
    }
    
    func postReplyData(content: String,  boardId: Int) {
        Server.postReply(category: boardCategory, boardId: boardId, content: content) { (isSuccess, value) in
            if isSuccess {
                self.preReadPage = self.currentPage
                if let lastVisibleRow = self.boardTableView.indexPathsForVisibleRows!.last {
                    self.scrollIndexPath = IndexPath(row: 0, section: lastVisibleRow.section)
                } else {
                    self.scrollIndexPath = IndexPath(row: 0, section: 0)
                }
                self.getFirstBoardData()
            }
        }
    }
    
    func editReplyData(content: String, replyId: Int) {
        Server.editReply(category: boardCategory, replyId: replyId, content: content) { (isSuccess, value) in
            if isSuccess {
                self.preReadPage = self.currentPage
                if let lastVisibleRow = self.boardTableView.indexPathsForVisibleRows!.last {
                    self.scrollIndexPath = IndexPath(row: 0, section: lastVisibleRow.section)
                } else {
                    self.scrollIndexPath = IndexPath(row: 0, section: 0)
                }
                self.getFirstBoardData()
            }
        }
    }
    
    func showImageViewer(url: URL) {
        let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
        let imageVC:EIImageViewerViewController = boardStoryboard.instantiateViewController(withIdentifier: "EIImageViewerViewController") as! EIImageViewerViewController
        imageVC.mImageURL = url;
    
        self.navigationController?.push(viewController: imageVC)
    }
}

extension MyWritingViewController: AppTabsControllerDelegate {
    func changeTab() {
//        if self.boardTableView.scrollValue > 0 {
//            self.boardTableView.setContentOffset(CGPoint(x: 0, y: self.boardTableView.scrollValue), animated: false)
//        }
    }
}

//
//  CardBoardViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 17..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Motion
import Material
import SwiftyJSON
import SnapKit

class CardBoardViewController: UIViewController {
    
    @IBOutlet weak var boardTableView: BoardTableView!
    
    var category = Board.BOARD_CATEGORY_FREE // default 자유게시판
    
    var bmId:Int = -1
    var brdTitle:String = ""
    
    var currentPage = 0
    var preReadPage = 0
    var lastPage: Bool = false
    var boardList: Array<BoardItem> = Array<BoardItem>()
    
    var scrollIndexPath = IndexPath(row: 0, section: 0)
    
    let boardWriteButton = BoardWriteButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        
        self.getFirstBoardData()
        
        self.boardTableView.tableViewDelegate = self
        self.boardTableView.category = self.category

        self.boardTableView.separatorColor = UIColor(rgb: 0xE4E4E4)
        self.boardTableView.separatorInset = .zero
        self.boardTableView.separatorStyle = .none
        self.boardTableView.allowsSelection = false
        
        if #available(iOS 15.0, *) {
            self.boardTableView.sectionHeaderTopPadding = 0
        }
        
        self.view.addSubview(boardWriteButton)
        
        boardWriteButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-74)
            $0.trailing.equalToSuperview().offset(-24)
            $0.width.equalTo(101)
            $0.height.equalTo(36)
        }
        
//        boardTableView.register(UINib.init(nibName: "BoardTableViewCell", bundle: nil), forCellReuseIdentifier: "BoardTableViewCell")
//        boardTableView.register(UINib.init(nibName: "BoardTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "BoardTableViewHeader")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Recalculates height
        self.boardTableView.beginUpdates()
        self.boardTableView.endUpdates()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.boardTableView.setNeedsDisplay()
        self.boardTableView.reloadData()
    }
}

extension CardBoardViewController {
    
    func prepareActionBar() {
        self.navigationController?.isNavigationBarHidden = false
        
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        // 글작성 버튼
        if !self.category.elementsEqual(Board.BOARD_CATEGORY_CHARGER) {
            var postButton: IconButton!
            postButton = IconButton(image: Icon.cm.edit)
            postButton.tintColor = UIColor(named: "content-primary")
            postButton.addTarget(self, action: #selector(handlePostButton), for: .touchUpInside)
            
            self.navigationItem.rightViews = [postButton]
        }
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftViews = [backButton]
        self.navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        
        if self.category.elementsEqual(Board.BOARD_CATEGORY_CHARGER) {
            self.navigationItem.titleLabel.text = "충전소 게시판"
        } else if self.category.elementsEqual(Board.BOARD_CATEGORY_COMPANY) {
            if !self.brdTitle.isEmpty{
                self.navigationItem.titleLabel.text = self.brdTitle + " 게시판"
            }else{
                self.navigationItem.titleLabel.text = "사업자 게시판"
            }
        } else {
            self.navigationItem.titleLabel.text = "자유게시판"
        }
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    @objc
    fileprivate func handlePostButton() {
        let editVC:EditViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        editVC.mode = EditViewController.BOARD_NEW_MODE
        editVC.editViewDelegate = self
        self.navigationController?.push(viewController: editVC)
    }
}

extension CardBoardViewController: BoardTableViewDelegate {
    
    func getFirstBoardData() {
        self.currentPage = 0
        self.lastPage = false
        let pageCount = BoardTableView.PAGE_DATA_COUNT + (BoardTableView.PAGE_DATA_COUNT * self.preReadPage)
        
        Server.getBoard(category: self.category, bmId: self.bmId , page: currentPage, count: pageCount, mine: false, ad: false) { [self] (isSuccess, value) in
            if isSuccess {
                self.boardList.removeAll()
                
                let json = JSON(value)
                let boardJson = json["list"]
                for json in boardJson.arrayValue {
                    let boardData = BoardItem(bJson: json)
                    self.boardList.append(boardData)
                }
                
                self.boardTableView.boardList = self.boardList
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
            Server.getBoard(category: self.category, bmId: self.bmId, page: currentPage, count: BoardTableView.PAGE_DATA_COUNT) { (isSuccess, value) in
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
                    self.boardTableView.reloadData()
                }
            }
        }
    }
    
    // 수정 테스트 ok
    func boardEdit(tag: Int) {
        let editVC:EditViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        editVC.mode = EditViewController.BOARD_EDIT_MODE
        editVC.originBoardData = self.boardList[tag]
        editVC.editViewDelegate = self
        
        self.navigationController?.push(viewController: editVC)
    }
    
    // 삭제 테스트 ok
    func boardDelete(tag: Int) {
        let dialogMessage = UIAlertController(title: "Notice", message: "게시글을 삭제하시겠습니까?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {(ACTION) -> Void in
            Server.deleteBoard(category: self.category, boardId: self.boardList[tag].boardId!) { (isSuccess, value) in
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
    
    // 댓글 작성 ok
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
    
    // 댓글 삭제 ok
    func replyDelete(tag: Int) {
        let dialogMessage = UIAlertController(title: "Notice", message: "댓글을 삭제하시겠습니까?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {(ACTION) -> Void in
            let section = tag / 1000
            let row = tag % 1000
            let replyValue = self.boardList[section].reply![row]
            Server.deleteReply(category: self.category, boardId: replyValue.replyId!) { (isSuccess, value) in
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
    
    func makeReply(tag: Int) {
        let editVC:EditViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        editVC.mode = EditViewController.REPLY_NEW_MODE
        editVC.originBoardId = tag
        editVC.editViewDelegate = self
        self.navigationController?.push(viewController: editVC)
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

extension CardBoardViewController: EditViewDelegate {
    
    func postBoardData(content: String, hasImage: Int, picture: Data?) {
        Server.postBoard(category: self.category, bmId: self.bmId, content: content, hasImage: hasImage) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if hasImage == 1 {
                    let filename = json["file_name"].stringValue
                    if let data = picture {
                        Server.uploadImage(data: data, filename: "\(filename).jpg", kind: Const.CONTENTS_BOARD_IMG, targetId: json["board_id"].stringValue, completion: { (isSuccess, value) in
                            let json = JSON(value)
                            if (isSuccess) {
                                self.preReadPage = 0
                                self.getFirstBoardData()
                            } else {
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
        Server.editBoard(category: self.category, boardId: boardId, content: content, editImage: editImage) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if editImage == 1 {
                    let filename =  json["file_name"].stringValue
                    if let data = picture {
                        Server.uploadImage(data: data, filename: "\(filename).jpg", kind: Const.CONTENTS_BOARD_IMG, targetId: json["board_id"].stringValue, completion: { (isSuccess, value) in
                            let json = JSON(value)
                            if (isSuccess) {
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
        Server.postReply(category: self.category, boardId: boardId, content: content) { (isSuccess, value) in
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
        Server.editReply(category: self.category, replyId: replyId, content: content) { (isSuccess, value) in
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

//
//  MyArticleViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 6. 5..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Motion
import SwiftyJSON

class MyArticleViewController: UIViewController {

    private lazy var customNavibar = CommonNaviView().then {
        $0.naviTitleLbl.text =  "내글보기"
    }
    private lazy var boardTableView = BoardTableView()
    
    var boardList: Array<BoardItem> = Array<BoardItem>()
    
    var scrollIndexPath = IndexPath(row: 0, section: 0)

    var category: String? = nil
    var boardId: Int = 0
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func loadView() {
        super.loadView()
        
        customNavibar.backClosure = {
            GlobalDefine.shared.mainNavi?.pop()
        }
        
        view.addSubview(customNavibar)
        customNavibar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
        
        view.addSubview(boardTableView)
        boardTableView.snp.makeConstraints {
            $0.top.equalTo(customNavibar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.getFirstBoardData()
//        self.boardTableView.tableViewDelegate = self
        self.boardTableView.rowHeight = UITableView.automaticDimension
        self.boardTableView.estimatedRowHeight = UITableView.automaticDimension
        self.boardTableView.separatorColor = UIColor(rgb: 0xE4E4E4)
        self.boardTableView.separatorInset = .zero
        self.boardTableView.separatorStyle = .none
        self.boardTableView.allowsSelection = false
        
        self.boardTableView.sectionHeaderHeight = UITableView.automaticDimension;
        self.boardTableView.estimatedSectionHeaderHeight = 25;
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true

        // Recalculates height
        self.boardTableView.beginUpdates()
        self.boardTableView.endUpdates()
    }
}

//
//extension MyArticleViewController: BoardTableViewDelegate {
//    func fetchFirstBoard(mid: String, sort: Board.SortType) {
//
//    }
//
//    func fetchNextBoard(mid: String, sort: Board.SortType) {
//
//    }
//
//    func didSelectItem(at index: Int) {
//
//    }
//
//
//    func getFirstBoardData() {
//        Server.getBoardContent(category: category!, boardId: boardId) { (isSuccess, value) in
//            if isSuccess {
//                self.boardList.removeAll()
//
//                let json = JSON(value)
//                let boardJson = json["list"]
//                for json in boardJson.arrayValue{
//                    let boardData = BoardItem(bJson: json)
//                    self.boardList.append(boardData)
//                }
//                self.boardTableView.boardList = self.boardList
//                self.boardTableView.reloadData()
//            }
//        }
//    }
//
//    func getNextBoardData() {
//
//    }
//
//    func boardEdit(tag: Int) {
//        let editVC:EditViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
//        editVC.mode = EditViewController.BOARD_EDIT_MODE
//        editVC.originBoardData = self.boardList[tag]
//        editVC.editViewDelegate = self
//
//        self.navigationController?.push(viewController: editVC)
//    }
//
//    func boardDelete(tag: Int) {
//        let dialogMessage = UIAlertController(title: "Notice", message: "게시글을 삭제하시겠습니까?", preferredStyle: .alert)
//        let ok = UIAlertAction(title: "OK", style: .default, handler: {(ACTION) -> Void in
//            Server.deleteBoard(category: self.category!, boardId: self.boardList[tag].boardId!) { (isSuccess, value) in
//                if isSuccess {
//                    self.scrollIndexPath = IndexPath(row: 0, section: self.boardTableView.indexPathsForVisibleRows!.last!.section)
//                    self.getFirstBoardData()
//                }
//            }
//        })
//
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:{ (ACTION) -> Void in
//            print("Cancel button tapped")
//        })
//        dialogMessage.addAction(ok)
//        dialogMessage.addAction(cancel)
//
//        self.present(dialogMessage, animated: true, completion: nil)
//    }
//
//    func replyEdit(tag: Int) {
//        let section = tag / 1000
//        let row = tag % 1000
//        let replyValue = self.boardList[section].reply![row]
//
//        let editVC:EditViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
//        editVC.mode = EditViewController.REPLY_EDIT_MODE
//        editVC.originReplyData = replyValue
//        editVC.editViewDelegate = self
//
//        self.navigationController?.push(viewController: editVC)
//    }
//
//    func replyDelete(tag: Int) {
//        let dialogMessage = UIAlertController(title: "Notice", message: "댓글을 삭제하시겠습니까?", preferredStyle: .alert)
//        let ok = UIAlertAction(title: "OK", style: .default, handler: {(ACTION) -> Void in
//            let section = tag / 1000
//            let row = tag % 1000
//            let replyValue = self.boardList[section].reply![row]
//            Server.deleteReply(category: self.category!, boardId: replyValue.replyId!) { (isSuccess, value) in
//                if isSuccess {
//                    self.scrollIndexPath = IndexPath(row: 0, section: self.boardTableView.indexPathsForVisibleRows!.last!.section)
//                    self.getFirstBoardData()
//                }
//            }
//        })
//
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:{ (ACTION) -> Void in
//            print("Cancel button tapped")
//        })
//        dialogMessage.addAction(ok)
//        dialogMessage.addAction(cancel)
//
//        self.present(dialogMessage, animated: true, completion: nil)
//    }
//
//    func makeReply(tag: Int) {
//        let editVC:EditViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
//        editVC.mode = EditViewController.REPLY_NEW_MODE
//        editVC.originBoardId = tag
//        editVC.editViewDelegate = self
//        self.navigationController?.push(viewController: editVC)
//    }
//
//    func goToStation(tag: Int) {}
//}
//
//extension MyArticleViewController: EditViewDelegate {
//
//    func postBoardData(content: String, hasImage: Int, picture: Data?) {
//
//    }
//
//    func editBoardData(content: String, boardId: Int, editImage: Int, picture: Data?) {
//        Server.editBoard(category: self.category!, boardId: boardId, content: content, editImage: editImage) { (isSuccess, value) in
//            if isSuccess {
//                let json = JSON(value)
//                if editImage == 1 {
//                    let filename =  json["file_name"].stringValue
//                    if let data = picture {
//                        Server.uploadImage(data: data, filename: "\(filename).jpg", kind: Const.CONTENTS_BOARD_IMG, targetId: "\(MemberManager.getMbId())", completion: { (isSuccess, value) in
//                            let json = JSON(value)
//                            if isSuccess {
//                                self.scrollIndexPath = IndexPath(row: 0, section: self.boardTableView.indexPathsForVisibleRows!.last!.section)
//                                self.getFirstBoardData()
//                            } else {
//                                print("upload image Error : \(json)")
//                            }
//                        })
//                    }
//                } else {
//                    if let lastRow = self.boardTableView.indexPathsForVisibleRows!.last {
//                        self.scrollIndexPath = IndexPath(row: 0, section: lastRow.section)
//                    }
//                    self.getFirstBoardData()
//                }
//            }
//        }
//    }
//
//    func postReplyData(content: String,  boardId: Int) {
//        Server.postReply(category: self.category!, boardId: boardId, content: content) { (isSuccess, value) in
//            if isSuccess {
//                if let lastRow = self.boardTableView.indexPathsForVisibleRows!.last {
//                    self.scrollIndexPath = IndexPath(row: 0, section: lastRow.section)
//                }
//                self.getFirstBoardData()
//            }
//        }
//    }
//
//    func editReplyData(content: String, replyId: Int) {
//        Server.editReply(category: self.category!, replyId: replyId, content: content) { (isSuccess, value) in
//            if isSuccess {
//                if let lastRow = self.boardTableView.indexPathsForVisibleRows!.last {
//                    self.scrollIndexPath = IndexPath(row: 0, section: lastRow.section)
//                }
//                self.getFirstBoardData()
//            }
//        }
//    }
//
//    func showImageViewer(url: URL) {
//        let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
//        let imageVC:EIImageViewerViewController = boardStoryboard.instantiateViewController(withIdentifier: "EIImageViewerViewController") as! EIImageViewerViewController
//        imageVC.mImageURL = url;
//
//        self.navigationController?.push(viewController: imageVC)
//        //self.present.push(viewController: imageVC, subtype: kCATransitionFromTop)
//    }
//}

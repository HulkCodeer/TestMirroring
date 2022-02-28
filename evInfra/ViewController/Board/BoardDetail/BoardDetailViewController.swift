//
//  BoardDetailViewController.swift
//  evInfra
//
//  Created by PKH on 2022/01/20.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit
import Material
import PanModal

class BoardDetailViewController: BaseViewController, UINavigationControllerDelegate {
    
    @IBOutlet var detailTableView: UITableView!
    
    var category = Board.CommunityType.FREE.rawValue
    var document_srl: String = ""
    var detail: BoardDetailResponseData? = nil
    lazy var keyboardInputView: KeyboardInputView? = nil
    var recomment: Recomment?
    var isFromStationDetailView: Bool = false
    
    let boardDetailViewModel = BoardDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        setConfiguration()
        prepareActionBar()
        setKeyboardInputView()
        setKeyboardTapGesture()
        setSendButtonCompletion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func prepareActionBar() {
        self.navigationController?.isNavigationBarHidden = false
        
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "nt-9")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
    }
    
    private func fetchData() {
        boardDetailViewModel.fetchBoardDetail(mid: category, document_srl: document_srl)
        boardDetailViewModel.listener = { [weak self] detail in
            guard let self = self else { return }
            
            self.detail = detail
            
            DispatchQueue.main.async {
                self.detailTableView.reloadData()
            }
        }
    }
    
//    private func reloadData(_ row: Int) {
//        detailTableView.reloadData()
//
//        DispatchQueue.main.async {
//            let indexPath = IndexPath(row: row - 1, section: 1)
//            self.detailTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//        }
//    }
    /*
    private func scrollToBottom() {
        guard let countOfComments = detail?.comments?.count,
        countOfComments > 0 else { return }
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: countOfComments - 1, section: 1)
            self.detailTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    private func scrollToRow(row: Int) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: row - 1, section: 1)
            self.detailTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    */
    private func setConfiguration() {
        view.addSubview(activityIndicator)
        keyboardInputView = KeyboardInputView()
        keyboardInputView?.delegate = self
        picker.delegate = self
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.register(UINib(nibName: "BoardDetailTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "BoardDetailTableViewHeader")
        detailTableView.register(UINib(nibName: "BoardDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "BoardDetailTableViewCell")
        detailTableView.register(EmptyTableViewCell.classForCoder(), forCellReuseIdentifier: "EmptyTableViewCell")
        detailTableView.estimatedRowHeight = 100
        detailTableView.rowHeight = UITableViewAutomaticDimension
        
        if #available(iOS 15.0, *) {
            self.detailTableView.sectionHeaderTopPadding = 0
        }
    }
    
    private func setKeyboardInputView() {
        guard let keyboardInputView = keyboardInputView else {
            return
        }
        self.view.addSubview(keyboardInputView)
        
        keyboardInputView.snp.updateConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setKeyboardTapGesture() {
        let tapTouch = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapTouch)
    }
    
    private func setSendButtonCompletion() {
        keyboardInputView?.sendButtonCompletionHandler = { [weak self] text, selectedRow, isModify, isRecomment in
            guard let self = self,
                    let detail = self.detail else { return }
            guard let comments = detail.comments else { return }
            
            let selectedImage = self.keyboardInputView?.selectedImageView.image
            
            var commentParamters = CommentParameter(mid: self.category,
                                                    documentSRL: detail.document!.document_srl!,
                                                    comment: nil,
                                                    text: text,
                                                    image: selectedImage,
                                                    selectedCommentRow: selectedRow,
                                                    isRecomment: isRecomment)
            
            if !comments.isEmpty {
                commentParamters.comment = comments[selectedRow]
            }
            self.activityIndicator.startAnimating()
            if isModify {
                // 댓글/대댓글 수정
                self.boardDetailViewModel.modifyBoardComment(commentParameter: commentParamters) { isSuccess in
                    self.activityIndicator.stopAnimating()
                    if isSuccess {
                        self.fetchData()
                    } else {
                        // show error
                    }
                }
            } else {
                // 댓글/대댓글 신규
                self.boardDetailViewModel.postComment(commentParameter: commentParamters) { isSuccess in
                    self.activityIndicator.stopAnimating()
                    if isSuccess {
                        self.fetchData()
                    } else {
                        // show error
                    }
                }
            }
        }
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
}

extension BoardDetailViewController: MediaButtonTappedDelegate {
    func presentModal() {
        let rowVC = GroupViewController()
        rowVC.members = ["갤러리 이동", "사진 촬영"]
        presentPanModal(rowVC)
        
        rowVC.selectedCompletion = { index in
            self.dismiss(animated: true, completion: nil)
            
            switch index {
            case 0:
                self.openPhotoLib()
            case 1:
                self.openCamera()
            default:
                break
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension BoardDetailViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        let selectedImage = editedImage ?? originalImage
        
        keyboardInputView?.selectedImageView.isHidden = false
        keyboardInputView?.selectedImageView.image = selectedImage
        keyboardInputView?.trashButton.isHidden = false
        keyboardInputView?.selectedImageViewHeight.constant = 80
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension BoardDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "BoardDetailTableViewHeader") as? BoardDetailTableViewHeader else { return UIView() }
            
            view.configure(item: boardDetailViewModel.getDetailData(), isFromStationDetailView: isFromStationDetailView)
            view.buttonClickDelegate = self
            
            return view
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return UITableViewAutomaticDimension
        } else {
            if boardDetailViewModel.getDetailData()?.comments?.count == 0 {
                return 64
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: detailTableView.frame.width, height: 4))
            footerView.backgroundColor = UIColor(named: "nt-0")
            return footerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4
    }
}

extension BoardDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            let countOfComments = boardDetailViewModel.counOfComments()
            
            if countOfComments == 0 {
                return 1
            } else {
                return countOfComments
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let countOfComments = boardDetailViewModel.counOfComments()
            
            if countOfComments == 0 {
                guard let emptyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell", for: indexPath) as? EmptyTableViewCell else { return UITableViewCell() }
                emptyTableViewCell.configure(isSearchViewType: false)
                emptyTableViewCell.selectionStyle = .none
                return emptyTableViewCell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "BoardDetailTableViewCell", for: indexPath) as? BoardDetailTableViewCell else { return UITableViewCell() }
                
                cell.configureComment(comment: boardDetailViewModel.getComment(at: indexPath.row), row: indexPath.row)
                cell.buttonClickDelegate = self
                
                return cell
            }
        } else {
            return UITableViewCell.init(frame: .zero)
        }
    }
}

// MARK: - ButtonClickDelegate
extension BoardDetailViewController: ButtonClickDelegate {
    func reportButtonCliked(isHeader: Bool) {
        guard let detail = detail,
        let document = detail.document else { return }
        
        let rowVC = GroupViewController()
        
        if isHeader {
            if boardDetailViewModel.isMyBoard(mb_id: document.mb_id!) {
                rowVC.members = ["수정하기", "삭제하기", "공유하기"]
                presentPanModal(rowVC)
                
                rowVC.selectedCompletion = { [weak self] index in
                    guard let self = self else { return }
                    
                    self.dismiss(animated: true) {
                        switch index {
                        case 0:
                            // 수정하기
                            let storyboard = UIStoryboard.init(name: "BoardWriteViewController", bundle: nil)
                            guard let boardWriteViewController = storyboard.instantiateViewController(withIdentifier: "BoardWriteViewController") as? BoardWriteViewController else { return }
                            
                            boardWriteViewController.category = self.category
                            boardWriteViewController.document = self.boardDetailViewModel.getDetailData()?.document
                            boardWriteViewController.uploadedImages = self.boardDetailViewModel.getDetailData()?.files
                            self.navigationController?.push(viewController: boardWriteViewController)
                            boardWriteViewController.popCompletion = {
                                self.fetchData()
                            }
                        case 1:
                            // 삭제하기
                            let popup = ConfirmPopupViewController(titleText: "삭제", messageText: "게시글을 삭제 하시겠습니까?")
                            popup.addActionToButton(title: "취소", buttonType: .cancel)
                            popup.addActionToButton(title: "삭제", buttonType: .confirm)
                            popup.confirmDelegate = { isDelete in
                                
                                self.boardDetailViewModel.deleteBoard(document_srl: self.document_srl) { isSuccess in
                                    let trasientAlertView = TransientAlertViewController()
                                    
                                    if isSuccess {
                                        trasientAlertView.titlemessage = "게시글이 삭제 되었습니다."
                                        trasientAlertView.dismissCompletion = {
                                            self.navigationController?.pop()
                                        }
                                    } else {
                                        trasientAlertView.titlemessage = "오류가 발생했습니다. 다시 시도해 주세요."
                                    }
                                    self.presentPanModal(trasientAlertView)
                                }
                            }
                            
                            self.present(popup, animated: true, completion: nil)
                        case 2:
                            // 공유하기
                            print("공유하기")
                        default:
                            break
                        }
                    }
                }
            } else {
                rowVC.members = ["공유하기", "신고하기"]
                presentPanModal(rowVC)
                
                rowVC.selectedCompletion = { [weak self] index in
                    guard let self = self else { return }
                    
                    self.dismiss(animated: true) {
                        switch index {
                        case 0:
                            // 공유하기
                            print("공유하기")
                        case 1:
                            // 신고하기
                            self.boardDetailViewModel.reportBoard(document_srl: self.document_srl) { (_, message) in
                                Snackbar().show(message: message)
                            }
                        default:
                            break
                        }
                    }
                }
            }
        } else {
            
        }
    }
    
    func likeButtonCliked(isLiked: Bool, isComment: Bool, srl: String) {
        var title = "좋아요"
        var message = "좋아요 하시겠습니까?"
        
        if isLiked {
            title = "좋아요 취소"
            message = "좋아요 취소하시겠습니까?"
        }
        
        let popup = ConfirmPopupViewController(titleText: title, messageText: message)
        popup.addActionToButton(title: "취소", buttonType: .cancel)
        popup.addActionToButton(title: title, buttonType: .confirm)
        popup.confirmDelegate = { [weak self] isLiked in
            guard let self = self else { return }
            
            self.boardDetailViewModel.setLikeCount(srl: srl, isComment: isComment) { (isSuccess, message) in
                if isSuccess {
                    if let message = message as? String {
                        let trasientAlertView = TransientAlertViewController()
                        trasientAlertView.titlemessage = message
                        self.presentPanModal(trasientAlertView)
                    } else {
                        self.fetchData()
                    }
                }
            }
        }
        
        self.present(popup, animated: true, completion: nil)
    }
    
    func commentButtonCliked(recomment: Comment, selectedRow: Int) {
        keyboardInputView?.becomeResponder(comment: recomment,
                                           isModify: false,
                                           isRecomment: true,
                                           selectedRow: selectedRow)
    }
    
    func deleteButtonCliked(documentSRL: String, commentSRL: String) {
        let popup = ConfirmPopupViewController(titleText: "삭제", messageText: "댓글을 삭제하시겠습니까?")
        popup.addActionToButton(title: "취소", buttonType: .cancel)
        popup.addActionToButton(title: "삭제", buttonType: .confirm)
        popup.confirmDelegate = { [weak self] isDeleted in
            guard let self = self else { return }
            self.boardDetailViewModel.deleteBoardComment(documentSRL: documentSRL, commentSRL: commentSRL) { isSuccess in
                let trasientAlertView = TransientAlertViewController()
                if isSuccess {
                    trasientAlertView.titlemessage = "삭제되었습니다."
                } else {
                    trasientAlertView.titlemessage = "오류가 발생했습니다. 잠시 후 다시 시도해주세요."
                }
                self.presentPanModal(trasientAlertView)
                self.fetchData()
            }
        }
        
        self.present(popup, animated: true, completion: nil)
    }
    
    func modifyButtonCliked(comment: Comment, selectedRow: Int) {
        let popup = ConfirmPopupViewController(titleText: "수정", messageText: "댓글을 수정하시겠습니까?")
        popup.addActionToButton(title: "취소", buttonType: .cancel)
        popup.addActionToButton(title: "수정", buttonType: .confirm)
        popup.confirmDelegate = { [weak self] isDeleted in
            guard let self = self else { return }
            
            let isRecomment = !comment.parent_srl!.equals("0")
            
            if isDeleted {
                self.keyboardInputView?.becomeResponder(comment: comment, isModify: true, isRecomment: isRecomment, selectedRow: selectedRow)
            }
        }
        
        self.present(popup, animated: true, completion: nil)
    }
    
    func moveToStation(with chargerId: String) {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        guard let detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        
        if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerId) {
            detailViewController.charger = charger
            self.navigationController?.push(viewController: detailViewController, subtype: kCATransitionFromTop)
        }
    }
}

// MARK: - EndEditing
extension BoardDetailViewController {
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}


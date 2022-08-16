//
//  BoardDetailViewController.swift
//  evInfra
//
//  Created by PKH on 2022/01/20.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit
import PanModal

class BoardDetailViewController: BaseViewController, UINavigationControllerDelegate {
    
    @IBOutlet var detailTableView: UITableView!
    
    var category: Board.CommunityType = .FREE
    var document_srl: String = ""
    var detail: BoardDetailResponseData? = nil
    var recomment: Recomment?
    var isFromStationDetailView: Bool = false
    var isModified: Bool = false
    var popCompletion: ((Bool) -> Void)?
    let ReloadData: Notification.Name = Notification.Name("ReloadData")
    lazy var keyboardInputView: KeyboardInputView? = nil
    let boardDetailViewModel = BoardDetailViewModel()
    let trasientAlertView = TransientAlertViewController()
    let linkShareManager = LinkShareManager.shared
    private var adminList: [Admin] = [Admin]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "게시판 상세 화면"
        fetchData()
        setConfiguration()
        prepareActionBar(with: "")
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
    
    private func fetchData() {
        boardDetailViewModel.fetchBoardDetail(mid: category.rawValue, document_srl: document_srl)
        boardDetailViewModel.listener = { [weak self] detail in
            guard let self = self else { return }
            
            self.detail = detail
            
            DispatchQueue.main.async {
                self.detailTableView.reloadData()
            }
        }
        getAdminList { adminList in
            self.adminList = adminList
        }
    }
    
    private func getAdminList(completion: @escaping ([Admin]) -> Void) {
        Server.getAdminList { (isSuccess, data) in
            guard let data = data as? Data else { return }
            let decoder = JSONDecoder()
            
            do {
                let result = try decoder.decode([Admin].self, from: data)
                completion(result)
            } catch {
                completion([])
            }
        }
    }

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
            
            MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
                guard isLogin, let self = self else {
                    MemberManager.shared.showLoginAlert(completion: { [weak self] (result) -> Void in
                        guard let self = self else { return }
                        if !result {
                            self.navigationController?.pop()
                        }
                    })
                    return
                }
                
                let selectedImage = self.keyboardInputView?.selectedImageView.image
                
                var commentParamters = CommentParameter(mid: self.category.rawValue,
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
                            NotificationCenter.default.post(name: self.ReloadData, object: nil, userInfo: nil)
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
                            NotificationCenter.default.post(name: self.ReloadData, object: nil, userInfo: nil)
                        } else {
                            // show error
                        }
                    }
                }
            }
        }
    }
    
    private func showImageViewer(url: URL, isProfileImageMode: Bool) {
        let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
        guard let imageVC: EIImageViewerViewController = boardStoryboard.instantiateViewController(withIdentifier: "EIImageViewerViewController") as? EIImageViewerViewController else { return }
        imageVC.mImageURL = url
        imageVC.isProfileImageMode = isProfileImageMode
    
        self.navigationController?.push(viewController: imageVC)
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
            
            if #available(iOS 14.0, *) {
                view.backgroundConfiguration?.backgroundColor = UIColor(named: "nt-white")
            }
            view.configure(item: boardDetailViewModel.getDetailData(), isFromStationDetailView: isFromStationDetailView)
            view.buttonClickDelegate = self
            view.imageTapped = { [weak self] imageUrl, isProfile in
                self?.showImageViewer(url: imageUrl, isProfileImageMode: isProfile)
            }
            
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
                emptyTableViewCell.configure(isSearchViewType: .Board)
                emptyTableViewCell.selectionStyle = .none
                return emptyTableViewCell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "BoardDetailTableViewCell", for: indexPath) as? BoardDetailTableViewCell else { return UITableViewCell() }
                
                cell.adminList = adminList
                cell.configureComment(comment: boardDetailViewModel.getComment(at: indexPath.row), row: indexPath.row)
                cell.buttonClickDelegate = self
                cell.imageTapped = { [weak self] imageUrl in
                    self?.showImageViewer(url: imageUrl, isProfileImageMode: false)
                }
                
                return cell
            }
        } else {
            return UITableViewCell.init(frame: .zero)
        }
    }
}

// MARK: - 게시글/댓글 수정+삭제+신고 기능
extension BoardDetailViewController {
    private func prepareSharingForKakao(with document: Document) {
        linkShareManager.sendToKakaoWithBoard(with: document)
    }
    
    private func deleteBoard() {
        let popupModel = PopupModel(title: "삭제",
                                    message:"게시글을 삭제 하시겠습니까?",
                                    confirmBtnTitle: "삭제",
                                    cancelBtnTitle: "취소",
                                    confirmBtnAction: { [weak self] in
            guard let self = self else { return }
            self.boardDetailViewModel.deleteBoard(document_srl: self.document_srl) { [weak self] isSuccess in
                guard let self = self else { return }
                guard isSuccess else {
                    Snackbar().show(message: "오류가 발생했습니다. 다시 시도해 주세요.")
                    return
                }
                Snackbar().show(message: "게시글이 삭제 되었습니다.")
                NotificationCenter.default.post(name: self.ReloadData, object: nil, userInfo: nil)
                GlobalDefine.shared.mainNavi?.pop()
            }
        })
        
        let popup = ConfirmPopupViewController(model: popupModel)
        
        self.present(popup, animated: true, completion: nil)
    }
    
    private func modifyBoard() {
        let storyboard = UIStoryboard.init(name: "BoardWriteViewController", bundle: nil)
        guard let boardWriteViewController = storyboard.instantiateViewController(withIdentifier: "BoardWriteViewController") as? BoardWriteViewController else { return }
        
        boardWriteViewController.category = self.category
        boardWriteViewController.document = self.boardDetailViewModel.getDetailData()?.document
        boardWriteViewController.uploadedImages = self.boardDetailViewModel.getDetailData()?.files
        
        boardWriteViewController.popCompletion = {
            NotificationCenter.default.post(name: self.ReloadData, object: nil, userInfo: nil)
            self.fetchData()
        }
        
        self.navigationController?.push(viewController: boardWriteViewController)
    }
    
    private func reportBoard() {
        let popupModel = PopupModel(title: "신고",
                                    message:"게시글을 신고하시겠습니까?",
                                    confirmBtnTitle: "신고하기",
                                    cancelBtnTitle: "취소",
                                    confirmBtnAction: { [weak self] in
            guard let self = self else { return }
            self.boardDetailViewModel.reportBoard(document_srl: self.document_srl) { [weak self] (isSuccess, message) in
                guard let self = self else { return }
                if isSuccess {
                    Snackbar().show(message: message)
                    NotificationCenter.default.post(name: self.ReloadData, object: nil, userInfo: nil)
                    GlobalDefine.shared.mainNavi?.pop()
                }
            }
        })
        
        let popup = ConfirmPopupViewController(model: popupModel)

        self.present(popup, animated: true, completion: nil)
    }
    
    private func deleteComment(documentSRL: String, commentSRL: String) {
        
        let popupModel = PopupModel(title: "삭제",
                                    message:"댓글을 삭제하시겠습니까?",
                                    confirmBtnTitle: "삭제",
                                    cancelBtnTitle: "취소",
                                    confirmBtnAction: { [weak self] in
            guard let self = self else { return }
            self.boardDetailViewModel.deleteBoardComment(documentSRL: documentSRL, commentSRL: commentSRL) { isSuccess, message in
                Snackbar().show(message: message)
                self.fetchData()
            }
        })
        
        let popup = ConfirmPopupViewController(model: popupModel)
        
        self.present(popup, animated: true, completion: nil)
    }
    
    private func modifyComment(comment: Comment, selectedRow: Int) {
        
        let popupModel = PopupModel(title: "수정",
                                    message:"댓글을 수정하시겠습니까?",
                                    confirmBtnTitle: "수정",
                                    cancelBtnTitle: "취소",
                                    confirmBtnAction: { [weak self] in
            guard let self = self, let _parentSrl = comment.parent_srl else { return }
            let isRecomment = !_parentSrl.equals("0")
            self.keyboardInputView?.becomeResponder(comment: comment, isModify: true, isRecomment: isRecomment, selectedRow: selectedRow)
        })
        
        let popup = ConfirmPopupViewController(model: popupModel)
        
        self.present(popup, animated: true, completion: nil)
    }
    
    private func reportComment(comment: Comment) {
        let popupModel = PopupModel(title: "신고",
                                    message:"댓글을 신고하시겠습니까?",
                                    confirmBtnTitle: "신고하기",
                                    cancelBtnTitle: "취소",
                                    confirmBtnAction: { [weak self] in
            guard let self = self else { return }
            self.boardDetailViewModel.reportComment(commentSrl: comment.comment_srl!) { (_, message) in
                Snackbar().show(message: message)
                self.fetchData()
            }
        })
        
        let popup = ConfirmPopupViewController(model: popupModel)
                        
        self.present(popup, animated: true, completion: nil)
    }
}

// MARK: - ButtonClickDelegate
extension BoardDetailViewController: ButtonClickDelegate {
    func threeDotButtonClicked(isHeader: Bool, row: Int) {
        guard let detail = detail,
        let document = detail.document else { return }
        let rowVC = GroupViewController()
                
        if isHeader {
            
            MemberManager.shared.tryToLoginCheck { [weak self] isLogin in
                guard isLogin, let self = self else {
                    rowVC.members = ["공유하기"]
                    self?.presentPanModal(rowVC)
                    
                    rowVC.selectedCompletion = { [weak self] index in
                        guard let self = self else { return }
                        
                        self.dismiss(animated: true) {
                            switch index {
                            case 0:
                                // 공유하기
                                self.prepareSharingForKakao(with: document)
                            default:
                                break
                            }
                        }
                    }
                    return
                }
                
                if self.boardDetailViewModel.isMyBoard(mb_id: document.mb_id!) {
                    rowVC.members = ["수정하기", "삭제하기", "공유하기"]
                    self.presentPanModal(rowVC)
                    
                    rowVC.selectedCompletion = { [weak self] index in
                        guard let self = self else { return }
                        
                        self.dismiss(animated: true) {
                            switch index {
                            case 0:
                                // 수정하기
                                self.modifyBoard()
                            case 1:
                                // 삭제하기
                                self.deleteBoard()
                            case 2:
                                // 공유하기
                                self.prepareSharingForKakao(with: document)
                            default:
                                break
                            }
                        }
                    }
                } else {
                    rowVC.members = ["신고하기", "공유하기"]
                    self.presentPanModal(rowVC)
                    
                    rowVC.selectedCompletion = { [weak self] index in
                        guard let self = self else { return }
                        
                        self.dismiss(animated: true) {
                            switch index {
                            case 0:
                                // 신고하기
                                self.reportBoard()
                            case 1:
                                // 공유하기
                                self.prepareSharingForKakao(with: document)
                            default:
                                break
                            }
                        }
                    }
                }
            }
                                               
        } else {
            MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
                guard isLogin, let self = self else {
                    MemberManager.shared.showLoginAlert()
                    return
                }
                
                guard let comments = detail.comments else { return }
                let comment = comments[row]
                
                if self.boardDetailViewModel.isMyBoard(mb_id: comment.mb_id!) {
                    rowVC.members = ["수정하기", "삭제하기"]
                    self.presentPanModal(rowVC)
                    
                    rowVC.selectedCompletion = { [weak self] index in
                        guard let self = self else { return }
                        
                        self.dismiss(animated: true) {
                            switch index {
                            case 0:
                                // 댓글 수정하기
                                self.modifyComment(comment: comment, selectedRow: row)
                            case 1:
                                // 댓글 삭제하기
                                self.deleteComment(documentSRL: comment.document_srl!, commentSRL: comment.comment_srl!)
                            default:
                                break
                            }
                        }
                    }
                } else {
                    rowVC.members = ["신고하기"]
                    self.presentPanModal(rowVC)
                    
                    rowVC.selectedCompletion = { [weak self] index in
                        guard let self = self else { return }
                        
                        self.dismiss(animated: true) {
                            switch index {
                            case 0:
                                // 신고하기
                                self.reportComment(comment: comment)
                            default:
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    func likeButtonCliked(isLiked: Bool, isComment: Bool, srl: String) {
        MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
            guard isLogin, let self = self else {
                MemberManager.shared.showLoginAlert()
                return
            }
            
            var title: String = "좋아요"
            var message: String = "좋아요 하시겠습니까?"
            
            if isLiked {
                title = "좋아요 취소"
                message = "좋아요 취소하시겠습니까?"
            }
            
            let popupModel = PopupModel(title: title,
                                        message:message,
                                        confirmBtnTitle: title,
                                        cancelBtnTitle: "취소",
                                        confirmBtnAction: { [weak self] in
                guard let self = self else { return }
                self.boardDetailViewModel.setLikeCount(srl: srl, isComment: isComment) { (isSuccess, message) in
                    if isSuccess {
                        if let message = message as? String {
                            Snackbar().show(message: message)
                        } else {
                            self.fetchData()
                        }
                    }
                }
            })
            
            let popup = ConfirmPopupViewController(model: popupModel)
            
            self.present(popup, animated: true, completion: nil)
        }                        
    }
    
    func commentButtonCliked(recomment: Comment, selectedRow: Int) {
        keyboardInputView?.becomeResponder(comment: recomment,
                                           isModify: false,
                                           isRecomment: true,
                                           selectedRow: selectedRow)
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


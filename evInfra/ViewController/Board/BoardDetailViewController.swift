//
//  BoardDetailViewController.swift
//  evInfra
//
//  Created by PKH on 2022/01/20.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit

class BoardDetailViewController: UIViewController {
    
    @IBOutlet var detailTableView: UITableView!
    @IBOutlet var keyboardInputView: KeyboardInputView!
    @IBOutlet var selectedImageShowView: UIView!
    @IBOutlet var keyboardInputViewBottomMargin: NSLayoutConstraint!
    
    var category = Board.CommunityType.FREE.rawValue
    var document_srl: String = ""
    let boardDetailViewModel = BoardDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardDetailViewModel.fetchBoardDetail(mid: category, document_srl: document_srl)
        boardDetailViewModel.listener = { [weak self] detail in
            DispatchQueue.main.async {
                self?.detailTableView.reloadData()
            }
        }
        
        self.detailTableView.delegate = self
        self.detailTableView.dataSource = self
        self.detailTableView.register(UINib(nibName: "BoardDetailTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "BoardDetailTableViewHeader")
        self.detailTableView.register(UINib(nibName: "BoardDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "BoardDetailTableViewCell")
        if #available(iOS 15.0, *) {
            self.detailTableView.sectionHeaderTopPadding = 0
        }
        
        setSelectedImageView()
        setKeyboardObserver()
    }
    
    private func setSelectedImageView() {
//        selectedImageShowView.isHidden = true
    }
    
    private func setKeyboardObserver() {
        let tapTouch = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapTouch)
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}

extension BoardDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "BoardDetailTableViewHeader") as? BoardDetailTableViewHeader else { return UIView() }
            
            view.configure(item: boardDetailViewModel.getDetailData())
            view.setUI()
            return view
        } else {
            // 댓글이 없을 경우, empty view 표시
            if boardDetailViewModel.getDetailData()?.comments?.count == 0 {
                let emptyView: BoardEmptyView = BoardEmptyView()
                
                return emptyView
            } else {
                return nil
            }
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
                return 200
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
        // 대댓글이 있을 경우 그 갯수 만큼
        if section == 0 {
            return 0
        } else {
            return boardDetailViewModel.counOfComments()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BoardDetailTableViewCell", for: indexPath) as? BoardDetailTableViewCell else { return UITableViewCell() }
            
            cell.configureComment(comment: boardDetailViewModel.getComment(at: indexPath.row))
            cell.buttonClickDelegate = self
            
            return cell
        } else {
            return UITableViewCell.init(frame: .zero)
        }
    }
}

// MARK: - ButtonClickDelegate
extension BoardDetailViewController: ButtonClickDelegate {
    
    
    func reportButtonCliked() {
        
    }
    
    func likeButtonCliked(isLiked: Bool, document_srl: String) {
        let popup = ConfirmPopupViewController(titleText: "좋아요", messageText: "좋아요 하시겠습니까?")
        popup.addActionToButton(title: "취소", buttonType: .cancel)
        popup.addActionToButton(title: "좋아요", buttonType: .confirm)
        popup.confirmDelegate = { [weak self] isLiked in
            self?.boardDetailViewModel.setLikeCount(document_srl: document_srl) { [weak self] isSuccess in
                if isSuccess {
                    DispatchQueue.main.async {
                        self?.detailTableView.reloadData()
                    }
                }
            }
        }
        
        self.present(popup, animated: true, completion: nil)
    }
    
    func commentButtonCliked() {
        
    }
    
    func deleteButtonCliked() {
        
    }
}


// MARK: - Keyboard
extension BoardDetailViewController {
    @objc private func adjustInputView(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        if notification.name == NSNotification.Name.UIKeyboardWillShow {
            let adjustmentHeight = keyboardFrame.height - self.view.safeAreaInsets.bottom
            
            UIView.animate(withDuration: animationDuration) {
                self.keyboardInputViewBottomMargin.constant = -adjustmentHeight
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: animationDuration) {
                self.keyboardInputViewBottomMargin.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

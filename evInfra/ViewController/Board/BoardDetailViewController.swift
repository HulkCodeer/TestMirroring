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
import AVFoundation
import Material

class BoardDetailViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet var detailTableView: UITableView!
    
    var category = Board.CommunityType.FREE.rawValue
    var document_srl: String = ""
    let boardDetailViewModel = BoardDetailViewModel()
    let picker = UIImagePickerController()
    
    var keyboardInputView = KeyboardInputView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        setDelegate()
        setKeyboardInputView()
        setKeyboardTapGesture()
        setSendButtonCompletion()
    }
    private func fetchData() {
        boardDetailViewModel.fetchBoardDetail(mid: category, document_srl: document_srl)
        boardDetailViewModel.listener = { [weak self] detail in
            DispatchQueue.main.async {
                self?.detailTableView.reloadData()
            }
        }
    }
    
    private func setDelegate() {
        picker.delegate = self
        keyboardInputView.delegate = self
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.register(UINib(nibName: "BoardDetailTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "BoardDetailTableViewHeader")
        detailTableView.register(UINib(nibName: "BoardDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "BoardDetailTableViewCell")
        if #available(iOS 15.0, *) {
            self.detailTableView.sectionHeaderTopPadding = 0
        }
    }
    
    private func setKeyboardInputView() {
        self.view.addSubview(keyboardInputView)
        
        keyboardInputView.snp.makeConstraints {
            $0.left.right.equalToSuperview().offset(0)
            $0.bottom.equalToSuperview().offset(0)
        }
    }
    
    private func setKeyboardTapGesture() {
        let tapTouch = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapTouch)
    }
    
    private func setSendButtonCompletion() {
        keyboardInputView.sendButtonCompletionHandler = { text in
            print(text)
            
            
        }
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
    
    func openPhotoLib() {
        picker.sourceType = .photoLibrary
        self.present(picker, animated: false, completion: nil)
    }
    
    func openCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined || status == .denied {
            // 권한 요청
            AVCaptureDevice.requestAccess(for: .video) { grated in
                if !grated {
                    self.showAuthAlert()
                }
            }
        } else if status == .authorized {
            picker.sourceType = .camera
            self.present(picker, animated: false, completion: nil)
        }
    }
    
    private func showAuthAlert() {
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            Snackbar().show(message: "카메라 기능이 활성화되지 않았습니다.")
            self.navigationController?.pop()
        }
        
        let openAction = UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        var actions = Array<UIAlertAction>()
        actions.append(cancelAction)
        actions.append(openAction)
        
        UIAlertController.showAlert(title: "카메라 기능이 활성화되지 않았습니다", message: "사진추가를 위해 카메라 권한이 필요합니다", actions: actions)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension BoardDetailViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        let selectedImage = editedImage ?? originalImage
        
        keyboardInputView.selectedImageView.isHidden = false
        keyboardInputView.selectedImageView.image = selectedImage
        keyboardInputView.trashButton.isHidden = false
        keyboardInputView.selectedImageViewHeight.constant = 80
        
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
            
            view.configure(item: boardDetailViewModel.getDetailData())
            view.setUI()
            view.buttonClickDelegate = self
            return view
        } else {
            // 댓글이 없을 경우, empty view 표시
            if boardDetailViewModel.getDetailData()?.comments?.count == 0 {
                return BoardEmptyView()
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
    func reportButtonCliked(isHeader: Bool) {
        if isHeader {
            let rowVC = GroupViewController()
            rowVC.members = ["공유하기", "신고하기"]
            presentPanModal(rowVC)
            
            rowVC.selectedCompletion = { index in
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
        } else {
            
        }
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

// MARK: - EndEditing
extension BoardDetailViewController {
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}


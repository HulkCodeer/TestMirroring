//
//  BoardWriteViewController.swift
//  evInfra
//
//  Created by PKH on 2022/01/10.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import AVFoundation
import PanModal

class BoardWriteViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet var chargeStationStackView: UIStackView!
    @IBOutlet var stationSearchButton: UIButton!
    @IBOutlet var titleTextView: UITextView!
    @IBOutlet var contentsView: UIView!
    @IBOutlet var contentsTextView: UITextView!
    @IBOutlet var countOfWordsLabel: UILabel!
    @IBOutlet var completeButton: UIButton!
    
    @IBOutlet var photoCollectionView: UICollectionView!

    private var selectedImages: [UIImage] = []
    var category = Board.CommunityType.FREE.rawValue
    var boardWriteViewModel = BoardWriteViewModel()
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        
        boardWriteViewModel.validateCompletion { [weak self] status in
            if status {
                self?.completeButton.isEnabled = true
                self?.completeButton.setTitleColor(UIColor(named: "nt-9"), for: .normal)
                self?.completeButton.backgroundColor = UIColor(named: "gr-5")
            } else {
                self?.completeButton.isEnabled = false
                self?.completeButton.setTitleColor(UIColor(named: "nt-3"), for: .normal)
                self?.completeButton.backgroundColor = UIColor(named: "nt-0")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !MemberManager().isLogin() {
            MemberManager().showLoginAlert(vc: self, completion: { (result) -> Void in
                if !result {
                    self.navigationController?.pop()
                }
            })
        }
    }
    
    @IBAction func completeButtonClick(_ sender: Any) {
        boardWriteViewModel.registerBoard(category,
                                          titleTextView.text,
                                          contentsTextView.text) { [weak self] isSuccess in
            if isSuccess {
                self?.navigationController?.pop()
                Snackbar().show(message: "게시글 등록이 완료되었습니다.")
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 잠시후 다시 시도해 주세요.")
            }
        }
    }
    
    private func setUI() {
        self.navigationItem.titleLabel.text = "글쓰기"
        
        // 충전소 검색 버튼
        if category.equals(Board.CommunityType.CHARGER.rawValue) {
            chargeStationStackView.isHidden = false
            stationSearchButton.layer.borderWidth = 1
            stationSearchButton.layer.borderColor = UIColor(named: "nt-2")?.cgColor
            stationSearchButton.layer.cornerRadius = 4
            stationSearchButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 4)
        }
        
        // 제목
        titleTextView.delegate = self
        titleTextView.text = Const.BoardConstants.titlePlaceHolder
        titleTextView.textColor = UIColor(named: "nt-5")
        titleTextView.layer.borderWidth = 1
        titleTextView.layer.borderColor = UIColor(named: "nt-2")?.cgColor
        titleTextView.layer.cornerRadius = 4
        titleTextView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        
        // 내용
        contentsTextView.delegate = self
        contentsTextView.text = Const.BoardConstants.contentsPlaceHolder
        contentsTextView.textColor = UIColor(named: "nt-5")
        contentsTextView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        contentsView.layer.borderWidth = 1
        contentsView.layer.borderColor = UIColor(named: "nt-2")?.cgColor
        contentsView.layer.cornerRadius = 6
        
        // 사진 등록
        photoCollectionView.register(UINib(nibName: "PhotoRegisterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoRegisterCollectionViewCell")
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.layer.cornerRadius = 16
        
        // 작성 완료 버튼
        completeButton.isEnabled = false
        completeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        picker.delegate = self
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureReconizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureReconizer)
        
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
    
    @objc
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func searchButtonClick(_ sender: Any) {
        stationSearchButton.setTitle("테스트", for: .normal)
    }
}

// MARK: - UICollectionView Delegate
extension BoardWriteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == selectedImages.count {
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

        } else {            
            let popup = ConfirmPopupViewController(titleText: "삭제 안내", messageText: "선택하신 사진을 삭제 하시겠습니까?")
            popup.addActionToButton(title: "취소", buttonType: .cancel)
            popup.addActionToButton(title: "삭제", buttonType: .confirm)
            popup.confirmDelegate = { [weak self] canDelete in
                if canDelete {
                    self?.selectedImages.remove(at: indexPath.row)

                    DispatchQueue.main.async {
                        self?.photoCollectionView.reloadData()
                    }
                }
            }
            
            self.present(popup, animated: true, completion: nil)
        }
    }
}

// MARK: - UICollectionView DataSource
extension BoardWriteViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoRegisterCollectionViewCell", for: indexPath) as? PhotoRegisterCollectionViewCell else { return UICollectionViewCell() }
        
        if indexPath.item == selectedImages.count {
            cell.photoImageView.image = UIImage(named: "buttonAddPicture.png")
        } else {
            cell.photoImageView.image = selectedImages[indexPath.row]
        }

        return cell
    }
}

// MARK: - TextView Delegate
extension BoardWriteViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(named: "nt-5") {
            textView.text = nil
            textView.textColor = UIColor(named: "nt-9")
        }
        
        switch textView.tag {
        case 0:
            titleTextView.layer.borderColor = UIColor(named: "nt-9")?.cgColor
        case 1:
            contentsView.layer.borderColor = UIColor(named: "nt-9")?.cgColor
        default:
            break
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView.tag {
        case 0:
            titleTextView.layer.borderColor = UIColor(named: "nt-2")?.cgColor
            
            if titleTextView.text.isEmpty {
                titleTextView.text = "제목을 입력해주세요."
                titleTextView.textColor = UIColor(named: "nt-5")
            }
        case 1:
            contentsView.layer.borderColor = UIColor(named: "nt-2")?.cgColor
            
            if contentsTextView.text.isEmpty {
                contentsTextView.text = "내용을 입력해주세요."
                contentsTextView.textColor = UIColor(named: "nt-5")
            }
        default:
            break
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        switch textView.tag {
        case 0:
            print("")
        case 1:
            countOfWordsLabel.text = "\(contentsTextView.text.count) / 1200"
        default:
            break
        }
        
        boardWriteViewModel.validateInput(titleTextView.text, contentsTextView.text)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension BoardWriteViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("didFinishPickingMediaWithInfo : \(info)")
        
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        let selectedImage = editedImage ?? originalImage
        
        selectedImages.append(selectedImage)
        
        DispatchQueue.main.async {
            self.photoCollectionView.reloadData()
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

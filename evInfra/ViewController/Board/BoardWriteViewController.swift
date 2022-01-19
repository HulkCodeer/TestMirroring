//
//  BoardWriteViewController.swift
//  evInfra
//
//  Created by PKH on 2022/01/10.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import AVFoundation

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
                print("성공")
            } else {
                self?.completeButton.isEnabled = false
                self?.completeButton.setTitleColor(UIColor(named: "nt-3"), for: .normal)
                self?.completeButton.backgroundColor = UIColor(named: "nt-0")
                print("실패")
            }
        }
    }
    
    @IBAction func completeButtonClick(_ sender: Any) {
        print("클릭")
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
        titleTextView.layer.borderWidth = 1
        titleTextView.layer.borderColor = UIColor(named: "nt-2")?.cgColor
        titleTextView.layer.cornerRadius = 4
        titleTextView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        
        // 내용
        contentsTextView.delegate = self
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
//        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tapGestureReconizer)
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
            self.picker.sourceType = .camera
            self.present(self.picker, animated: false, completion: nil)
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
            self.openCamera()
        } else {
            let popup = ConfirmPopupViewController()
            popup.modalPresentationStyle = .overFullScreen
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
        case 1:
            contentsView.layer.borderColor = UIColor(named: "nt-2")?.cgColor
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

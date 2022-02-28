//
//  BoardWriteViewController.swift
//  evInfra
//
//  Created by PKH on 2022/01/10.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SDWebImage
import UIImageCropper
import SwiftyJSON
import PanModal

class BoardWriteViewController: BaseViewController, UINavigationControllerDelegate {

    @IBOutlet var chargeStationStackView: UIStackView!
    @IBOutlet var stationSearchButton: UIButton!
    @IBOutlet var titleTextView: UITextView!
    @IBOutlet var contentsView: UIView!
    @IBOutlet var contentsTextView: UITextView!
    @IBOutlet var countOfWordsLabel: UILabel!
    @IBOutlet var completeButton: UIButton!
    @IBOutlet var photoCollectionView: UICollectionView!

    var selectedImages: [UIImage] = []
    var uploadedImages: [FilesItem]? = []
    var chargerInfo: [String: String] = [:]
    var category = Board.CommunityType.FREE.rawValue
    var document: Document?
    var boardWriteViewModel = BoardWriteViewModel()
    var popCompletion: (() -> Void)?
//    let picker = UIImagePickerController()
    let cropper = UIImageCropper(cropRatio: 100/115)
    let trasientAlertView = TransientAlertViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        stationCheck()
        
        boardWriteViewModel.subscribe { [weak self] isEnable in
            guard let self = self else { return }

            self.completeButton.isEnabled = isEnable
            
            if isEnable {
                self.completeButton.tintColor = UIColor(named: "nt-9")
                self.completeButton.backgroundColor = UIColor(named: "gr-5")
            } else {
                self.completeButton.tintColor = UIColor(named: "nt-3")
                self.completeButton.backgroundColor = UIColor(named: "nt-0")
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func completeButtonClick(_ sender: Any) {
        guard let title = titleTextView.text,
                let contents = contentsTextView.text else { return }
        
        if let document = document {
            
            
            let popup = ConfirmPopupViewController(titleText: "수정", messageText: "게시물을 수정 하시겠습니까?")
            popup.addActionToButton(title: "취소", buttonType: .cancel)
            popup.addActionToButton(title: "수정", buttonType: .confirm)
            popup.confirmDelegate = { [weak self] canModify in
                guard let self = self else { return }
                
                
                self.activityIndicator.startAnimating()
                
                if canModify {
                    self.boardWriteViewModel.updateBoard(self.category,
                                                         document.document_srl!,
                                                         title,
                                                         contents,
                                                         self.chargerInfo["chargerId"] ?? "",
                                                         self.uploadedImages,
                                                         self.selectedImages) { isSuccess in
                        
                        self.activityIndicator.stopAnimating()
                        
                        if isSuccess {
                            self.trasientAlertView.titlemessage = "게시글 수정이 완료되었습니다."
                            self.trasientAlertView.dismissCompletion = {
                                self.popCompletion?()
                                self.navigationController?.pop()
                            }
                        } else {
                            self.trasientAlertView.titlemessage = "서버와 통신이 원활하지 않습니다. 잠시후 다시 시도해 주세요."
                        }
                        DispatchQueue.main.async {
                            self.presentPanModal(self.trasientAlertView)
                        }
                    }
                }
            }
            
            self.present(popup, animated: true, completion: nil)
        } else {
            // 신규 등록
            let popup = ConfirmPopupViewController(titleText: "등록", messageText: "게시물을 등록 하시겠습니까?")
            popup.addActionToButton(title: "취소", buttonType: .cancel)
            popup.addActionToButton(title: "등록", buttonType: .confirm)
            popup.confirmDelegate = { [weak self] canRegist in
                guard let self = self else { return }
                
                self.activityIndicator.startAnimating()
                
                if canRegist {
                    self.boardWriteViewModel.postBoard(self.category,
                                                       title,
                                                       contents,
                                                       self.chargerInfo["chargerId"] ?? "",
                                                       self.selectedImages) { isSuccess in
                        self.activityIndicator.stopAnimating()
                        
                        if isSuccess {
                            self.trasientAlertView.titlemessage = "게시글 등록이 완료되었습니다."
                            self.trasientAlertView.dismissCompletion = {
                                self.navigationController?.pop()
                            }
                        } else {
                            self.trasientAlertView.titlemessage = "서버와 통신이 원활하지 않습니다. 잠시후 다시 시도해 주세요."
                        }
                        DispatchQueue.main.async {
                            self.presentPanModal(self.trasientAlertView)
                        }
                    }
                }
            }
            
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    private func stationCheck() {
        if category.equals(Board.CommunityType.CHARGER.rawValue) {
            let stationName = stationSearchButton.titleLabel?.text
            boardWriteViewModel.bindInputText(titleTextView.text, contentsTextView.text, stationName)
        } else {
            boardWriteViewModel.bindInputText(titleTextView.text, contentsTextView.text, nil)
        }
    }
    
    private func setUI() {
        view.addSubview(activityIndicator)
        self.navigationItem.titleLabel.text = "글쓰기"
        
        self.cropper.picker = picker
        self.cropper.delegate = self
        
        // 충전소 검색 버튼
        if category.equals(Board.CommunityType.CHARGER.rawValue) {
            chargeStationStackView.isHidden = false
        } else {
            chargeStationStackView.isHidden = true
        }
        
        stationSearchButton.layer.borderWidth = 1
        stationSearchButton.layer.borderColor = UIColor(named: "nt-2")?.cgColor
        stationSearchButton.layer.cornerRadius = 4
        stationSearchButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 4)
        
        if let document = document {
            titleTextView.text = document.title ?? Const.BoardConstants.titlePlaceHolder
            contentsTextView.text = document.content ?? Const.BoardConstants.contentsPlaceHolder
            countOfWordsLabel.text = "\(contentsTextView.text?.count ?? 0) / 1200"
            
            let tags = JSON(parseJSON: document.tags!)
            if let chargerId = tags["charger_id"].string, let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerId) {
                
                guard let chargerStaionInfoDto = charger.mStationInfoDto else { return }
                
                chargerInfo["chargerId"] = chargerId
                chargerInfo["chargerName"] = chargerStaionInfoDto.mSnm!
                
                stationSearchButton.setTitle(chargerStaionInfoDto.mSnm, for: .normal)
            }
        } else {
            titleTextView.text = Const.BoardConstants.titlePlaceHolder
            contentsTextView.text = Const.BoardConstants.contentsPlaceHolder
            countOfWordsLabel.text = "0 / 1200"
        }
        
        // 제목
        titleTextView.delegate = self
        titleTextView.textColor = UIColor(named: "nt-5")
        titleTextView.layer.borderColor = UIColor(named: "nt-2")?.cgColor
        titleTextView.layer.borderWidth = 1
        titleTextView.layer.cornerRadius = 4
        titleTextView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        
        // 내용
        contentsTextView.delegate = self
        contentsTextView.textColor = UIColor(named: "nt-5")
        contentsView.layer.borderColor = UIColor(named: "nt-2")?.cgColor
        contentsView.layer.borderWidth = 1
        contentsView.layer.cornerRadius = 6
        contentsTextView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        
        
        // 사진 등록
        photoCollectionView.register(UINib(nibName: "PhotoRegisterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoRegisterCollectionViewCell")
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.layer.cornerRadius = 16
        
        let filenames = uploadedImages?.compactMap({ item in item.uploaded_filename })
        if let uploadedImages = filenames {
            for image in uploadedImages {
                let uiImage = image.urlToImage()!
                selectedImages.append(uiImage)
            }
        }
        
        // 작성 완료 버튼
        completeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureReconizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureReconizer)
    }
    
    @objc
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func searchButtonClick(_ sender: Any) {
        let mapStoryboard = UIStoryboard(name : "Map", bundle: nil)
        guard let searchViewController: SearchViewController = mapStoryboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else { return }
        searchViewController.delegate = self
        
        self.present(AppSearchBarController(rootViewController: searchViewController), animated: true, completion: nil)
    }
}

// MARK: - ChargerSelectDelegate
extension BoardWriteViewController: ChargerSelectDelegate {
    func moveToSelected(chargerId: String) {
        if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerId) {
            guard let chargerStaionInfoDto = charger.mStationInfoDto else { return }
            
            chargerInfo["chargerId"] = chargerId
            chargerInfo["chargerName"] = chargerStaionInfoDto.mSnm!
            
            stationSearchButton.setTitle(chargerStaionInfoDto.mSnm, for: .normal)
        }
    }
    
    func moveToSelectLocation(lat: Double, lon: Double) {
        
    }
}

// MARK: - UICollectionView Delegate
extension BoardWriteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == selectedImages.count {
            guard selectedImages.count < 5 else {
                trasientAlertView.titlemessage = "사진을 최대 5장 등록 가능합니다."
                DispatchQueue.main.async {
                    self.presentPanModal(self.trasientAlertView)
                }
                return
            }
            
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
                guard let self = self else { return }
                
                if canDelete {
                    self.selectedImages.remove(at: indexPath.row)
                    
                    DispatchQueue.main.async {
                        self.photoCollectionView.reloadData()
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
        textView.layer.borderColor = UIColor(named: "nt-9")?.cgColor
        textView.textColor = UIColor(named: "nt-9")
        
        if let _ = document {
            
        } else {
            textView.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderColor = UIColor(named: "nt-2")?.cgColor
        textView.textColor = UIColor(named: "nt-5")
        
        switch textView.tag {
        case 0:
            if titleTextView.text.isEmpty {
                titleTextView.text = Const.BoardConstants.titlePlaceHolder
            }
        case 1:
            if contentsTextView.text.isEmpty {
                contentsTextView.text = Const.BoardConstants.contentsPlaceHolder
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
        
        if category.equals(Board.CommunityType.CHARGER.rawValue) {
            let stationName = stationSearchButton.titleLabel?.text
            boardWriteViewModel.bindInputText(titleTextView.text, contentsTextView.text, stationName)
        } else {
            boardWriteViewModel.bindInputText(titleTextView.text, contentsTextView.text, nil)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate(Cropped)
extension BoardWriteViewController: UIImageCropperProtocol {
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
        guard let croppedImage = croppedImage else { return }
        selectedImages.append(croppedImage)

        DispatchQueue.main.async {
            self.photoCollectionView.reloadData()
        }

        didCancel()
    }

    func didCancel() {
        picker.dismiss(animated: true, completion: nil)
    }
}

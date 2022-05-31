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
    
    let ReloadData: Notification.Name = Notification.Name("ReloadData")
    var boardWriteViewModel = BoardWriteViewModel()
    var selectedImages: [UIImage] = [] 
    var uploadedImages: [FilesItem]? = []
    var chargerInfo: [String: String] = [:]
    var category = Board.CommunityType.FREE.rawValue
    var document: Document?
    var popCompletion: (() -> Void)?
    let cropper = UIImageCropper(cropRatio: 100/115)
    let trasientAlertView = TransientAlertViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        prepareActionBar(with: "글쓰기")
        
        boardWriteViewModel.subscribe { [weak self] isEnable in
            guard let self = self else { return }

            self.completeButton.isEnabled = isEnable
            
            if isEnable {
                self.completeButton.backgroundColor = UIColor(named: "gr-5")
            } else {
                self.completeButton.backgroundColor = UIColor(named: "nt-0")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !MemberManager.shared.isLogin {
            MemberManager.shared.showLoginAlert(completion: { (result) -> Void in
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
            let popupModel = PopupModel(title: "수정",
                                        message: "게시물을 수정 하시겠습니까?",
                                        confirmBtnTitle: "수정",
                                        cancelBtnTitle: "취소",
                                        confirmBtnAction: { [weak self] in
                guard let self = self else { return }
                self.activityIndicator.startAnimating()
                self.completeButton.isEnabled = false
                self.completeButton.backgroundColor = UIColor(named: "nt-0")
                                
                self.boardWriteViewModel.updateBoard(self.category,
                                                     document.document_srl!,
                                                     title,
                                                     contents,
                                                     self.chargerInfo["chargerId"] ?? "",
                                                     self.uploadedImages,
                                                     self.selectedImages) { isSuccess in
                    
                    self.activityIndicator.stopAnimating()
                                                            
                    var message: String = "게시글 수정이 완료되었습니다."
                    
                    if !isSuccess {
                        message = "서버와 통신이 원활하지 않습니다. 잠시후 다시 시도해 주세요."
                    }
                    
                    Snackbar().show(message: message)
                    
                    self.popCompletion?()
                    NotificationCenter.default.post(name: self.ReloadData, object: nil, userInfo: nil)
                    self.navigationController?.pop()                    
                }
            })

            let popup = ConfirmPopupViewController(model: popupModel)
            
            self.present(popup, animated: true, completion: nil)
        } else {
            // 신규 등록
            let popupModel = PopupModel(title: "등록",
                                        message: "게시물을 등록 하시겠습니까?",
                                        confirmBtnTitle: "등록",
                                        cancelBtnTitle: "취소", confirmBtnAction: { [weak self] in
                    guard let self = self else { return }
                    
                    self.activityIndicator.startAnimating()
                    self.completeButton.isEnabled = false
                    self.completeButton.backgroundColor = UIColor(named: "nt-0")
                                        
                    self.boardWriteViewModel.postBoard(self.category,
                                                       title,
                                                       contents,
                                                       self.chargerInfo["chargerId"] ?? "",
                                                       self.selectedImages) { isSuccess in
                        self.activityIndicator.stopAnimating()
                        
                        var message: String = "게시글 등록이 완료되었습니다."
                        if !isSuccess {
                            message = "서버와 통신이 원활하지 않습니다. 잠시후 다시 시도해 주세요."
                        }
                        Snackbar().show(message: message)
                        
                        self.popCompletion?()
                        NotificationCenter.default.post(name: self.ReloadData, object: nil, userInfo: nil)
                        self.navigationController?.pop()
                    }
            })
            
            let popup = ConfirmPopupViewController(model: popupModel)

            self.present(popup, animated: true, completion: nil)
        }
    }
    
    private func setUI() {
        view.addSubview(activityIndicator)
        
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
        
        if !chargerInfo.isEmpty {
            stationSearchButton.setTitle(chargerInfo["chargerName"], for: .normal)
        }
        
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
        completeButton.setTitleColor(UIColor(named: "nt-9"), for: .normal)
        completeButton.setTitleColor(UIColor(named: "nt-3"), for: .disabled)
        completeButton.setBackgroundColor(UIColor(named: "gr-5")!, for: .normal)
        completeButton.setBackgroundColor(UIColor(named: "nt-0")!, for: .disabled)
        
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
        searchViewController.removeAddressButton = true
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
            
            boardWriteViewModel.bindInputText(titleTextView.text, contentsTextView.text, chargerStaionInfoDto.mSnm)
            stationSearchButton.setTitle(chargerStaionInfoDto.mSnm, for: .normal)
        }
    }
    
    func moveToSelectLocation(lat: Double, lon: Double) {}
}

// MARK: - UICollectionView Delegate
extension BoardWriteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == selectedImages.count {
            guard selectedImages.count < 5 else {
                trasientAlertView.titlemessage = "사진을 최대 5장 등록 가능합니다."
                self.presentPanModal(self.trasientAlertView)
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
            let popupModel = PopupModel(title: "삭제 안내",
                                        message: "선택하신 사진을 삭제 하시겠습니까?",
                                        confirmBtnTitle: "삭제",
                                        cancelBtnTitle: "취소",
                                        confirmBtnAction: { [weak self] in
                guard let self = self else { return }
                self.selectedImages.remove(at: indexPath.row)
                
                DispatchQueue.main.async {
                    self.photoCollectionView.reloadData()
                }
                
                if self.category.equals(Board.CommunityType.CHARGER.rawValue) {
                    let stationName = self.stationSearchButton.titleLabel?.text
                    self.boardWriteViewModel.bindInputText(self.titleTextView.text, self.contentsTextView.text, stationName)
                } else {
                    self.boardWriteViewModel.bindInputText(self.titleTextView.text, self.contentsTextView.text, nil)
                }
                
            })

            let popup = ConfirmPopupViewController(model: popupModel)
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
        if selectedImages.count == 5 {
            return selectedImages.count
        } else {
            return selectedImages.count + 1
        }
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
            titleTextView.textColor = UIColor(named: "nt-9")
            
            if titleTextView.text.contains(Const.BoardConstants.titlePlaceHolder) {
                titleTextView.text = nil
            }
        case 1:
            contentsView.layer.borderColor = UIColor(named: "nt-9")?.cgColor
            contentsTextView.textColor = UIColor(named: "nt-9")
            
            if contentsTextView.text.contains(Const.BoardConstants.contentsPlaceHolder) {
                contentsTextView.text = nil
            }
        default:
            break
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView.tag {
        case 0:
            titleTextView.layer.borderColor = UIColor(named: "nt-2")?.cgColor
            titleTextView.textColor = UIColor(named: "nt-5")
            if titleTextView.text.isEmpty {
                titleTextView.text = Const.BoardConstants.titlePlaceHolder
            }
        case 1:
            contentsView.layer.borderColor = UIColor(named: "nt-2")?.cgColor
            contentsTextView.textColor = UIColor(named: "nt-5")
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
            break
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
        
        if category.equals(Board.CommunityType.CHARGER.rawValue) {
            let stationName = stationSearchButton.titleLabel?.text
            boardWriteViewModel.bindInputText(titleTextView.text, contentsTextView.text, stationName)
        } else {
            boardWriteViewModel.bindInputText(titleTextView.text, contentsTextView.text, nil)
        }

        didCancel()
    }

    func didCancel() {
        picker.dismiss(animated: true, completion: nil)
    }
}

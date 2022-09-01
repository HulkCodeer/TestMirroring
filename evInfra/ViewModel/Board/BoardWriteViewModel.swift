//
//  BoardWriteViewModel.swift
//  evInfra
//
//  Created by PKH on 2022/01/18.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

struct BoardWriteViewModel {
    
    var listener: ((Bool) -> Void)?
    var isModified: Bool = false
    var isValid: Bool = false {
        didSet {
            self.listener?(isValid)
        }
    }
    internal var isFromDetailView: Bool = false
    
    mutating func subscribe(listener: @escaping (Bool) -> Void) {
        listener(isValid)
        self.listener = listener
    }
    
    mutating func bindInputText(_ title: String, _ contents: String, _ stationName: String?) {
        // 수정
        if let stationName = stationName {
            guard isValidateTitle(with: title) else {
                isValid = false
                return
            }
            guard isValidateContents(with: contents) else {
                isValid = false
                return
            }
            guard isValidateStation(with: stationName) else {
                isValid = false
                return
            }
            isValid = true
        } else {
            guard isValidateTitle(with: title) else {
                isValid = false
                return
            }
            guard isValidateContents(with: contents) else {
                isValid = false
                return
            }
            isValid = true
        }
    }
    
    private func isValidateTitle(with str: String) -> Bool {
        guard !str.contains(Const.BoardConstants.titlePlaceHolder) else { return false }
        return str.count <= 100 && str.count > 0
    }
    
    private func isValidateContents(with str: String) -> Bool {
        guard !str.contains(Const.BoardConstants.contentsPlaceHolder) else { return false }
        return str.count <= 1200 && str.count > 0
    }
    
    private func isValidateStation(with stationName: String) -> Bool {
        guard !stationName.contains(Const.BoardConstants.chargerPlaceHolder) else { return false }
        return !stationName.isEmpty
    }
    
    private func validationTitleWithContents(title str1: String, content str2: String) -> Bool {
        if str1.contains(Const.BoardConstants.titlePlaceHolder) || str2.contains(Const.BoardConstants.contentsPlaceHolder) {
            return false
        }
        
        return str1.count <= 100 &&
        str1.count > 0 &&
        str2.count <= 1200 &&
        str2.count > 0
    }
    
    private func validationStation(with stationName: String) -> Bool {
        return !stationName.isEmpty && !stationName.contains(Const.BoardConstants.chargerPlaceHolder)
    }
    
    func postBoard(_ mid: String, _ title: String, _ content: String, _ chargerId: String, _ images: [UIImage] , completion: @escaping (Bool) -> Void) {
        
        Server.postBoardData(mid: mid, title: title, content: content, charger_id: chargerId) { (isSuccess, value) in
            if isSuccess {
                if let results = value as? Dictionary<String, String>,
                   let documentSRL = results["document_srl"] {
                    
                    let ampBoardModel = AmpBoardModel(mid: mid, chargerId: chargerId, documentSrl: documentSRL, isFromDetailView: isFromDetailView)
                    self.logEvent(with: .completeWriteBoardPost, model: ampBoardModel)
                    
                    guard images.count != 0 else {
                        completion(true)
                        return
                    }
                    
                    var completedUpload = 0
                    for (index, image) in images.enumerated() {
                        Server.boardImageUpload(mid: mid, document_srl: documentSRL, image: image, seq: "\(index)") { isSuccess, response in
                            if isSuccess {
                                completedUpload = completedUpload + 1
                                if completedUpload == images.count {
                                    completion(true)
                                }
                            } else {
                                completion(false)
                            }
                        }
                    }
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    func updateBoard(_ mid: String, _ documentSRL: String, _ title: String, _ content: String, _ chargerId: String, _ files: [FilesItem]?, _ selectedImages: [UIImage] , completion: @escaping (Bool) -> Void) {
        Server.updateBoardData(mid: mid, documentSRL: documentSRL, title: title, content: content, charger_id: chargerId) { isSuccess, value in
            if isSuccess {
                if let results = value as? Dictionary<String, String>,
                   let documentSRL = results["document_srl"] {
                    // image 삭제
                    guard let _files = files else { return completion(false) }
                    let deleteDispatchGroup = DispatchGroup()
                    var deleteSuccessResult:[Bool] = []
                                        
                    for imageFile in _files {
                        deleteDispatchGroup.enter()
                        guard let _srl = imageFile.file_srl, let _coverImage = imageFile.cover_image else { return completion(false)}
                        Server.deleteDocumnetFile(documentSRL: documentSRL, fileSRL: _srl, isCover: _coverImage) { isSuccess, response in
                            if isSuccess {
                                deleteSuccessResult.append(true)
                            } else {
                                deleteSuccessResult.append(false)
                            }
                            deleteDispatchGroup.leave()
                        }
                    }
                    
                    deleteDispatchGroup.notify(queue: .main, execute: {
                        guard deleteSuccessResult.count == _files.count else {
                            return
                        }
                        completion(deleteSuccessResult.filter({ $0 == true }).count == _files.count)
                    })
                                            
                    guard selectedImages.count != 0 else {
                        completion(true)
                        return
                    }

                    // image 등록
                    var uploadSuccessResult:[Bool] = []
                    let uploadDispatchGroup = DispatchGroup()
                    
                    for (index, image) in selectedImages.enumerated() {
                        uploadDispatchGroup.enter()
                        Server.boardImageUpload(mid: mid, document_srl: documentSRL, image: image, seq: "\(index)") { isSuccess, response in
                            if isSuccess {
                                uploadSuccessResult.append(true)
                            } else {
                                uploadSuccessResult.append(false)
                            }
                            uploadDispatchGroup.leave()
                        }
                    }
                    
                    uploadDispatchGroup.notify(queue: .main) {
                        if uploadSuccessResult.count == selectedImages.count {
                            completion(uploadSuccessResult.filter({ $0 == true }).count == selectedImages.count)
                        }
                    }
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
}

// MARK: - Amplitude Logging 이벤트
extension BoardWriteViewModel {
    private func logEvent(with event: EventType.BoardEvent, model: AmpBoardModel) {
        switch event {
        case .completeWriteBoardPost:
            AmplitudeManager.shared.logEvent(type: .board(event), property: model.toProperty)
        default: break
        }
    }
}

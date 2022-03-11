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
    
    mutating func subscribe(listener: @escaping (Bool) -> Void) {
        listener(isValid)
        self.listener = listener
    }
    
    mutating func bindInputText(_ isModifyStatus: Document?, _ title: String, _ contents: String, _ stationName: String?) {
        if let _ = isModifyStatus {
            if let stationName = stationName {
                if (validationTitleWithContents(title: title, content: contents) &&
                    validationStation(with: stationName)) ||
                    isModified {
                    self.isValid = true
                } else {
                    self.isValid = false
                }
            } else {
                if validationTitleWithContents(title: title, content: contents) || isModified {
                    self.isValid = true
                } else {
                    self.isValid = false
                }
            }
        } else {
            if let stationName = stationName {
                if validationTitleWithContents(title: title, content: contents) &&
                    validationStation(with: stationName) {
                    self.isValid = true
                } else {
                    self.isValid = false
                }
            } else {
                if validationTitleWithContents(title: title, content: contents) {
                    self.isValid = true
                } else {
                    self.isValid = false
                }
            }
        }
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
                    
                    guard selectedImages.count != 0 else {
                        completion(true)
                        return
                    }
                    // image 삭제
                    if let files = files {
                        for file in files {
                            Server.deleteDocumnetFile(documentSRL: documentSRL, fileSRL: file.file_srl!, isCover: file.cover_image!) { isSuccess, response in
                                if isSuccess {
                                    if let value = response as? String,
                                        value.contains("success") {
                                        
                                    } else {
                                        completion(false)
                                    }
                                } else {
                                    completion(false)
                                }
                            }
                        }
                    }
                    // image 등록
                    var completedUpload = 0
                    for (index, image) in selectedImages.enumerated() {
                        Server.boardImageUpload(mid: mid, document_srl: documentSRL, image: image, seq: "\(index)") { isSuccess, response in
                            if isSuccess {
                                completedUpload = completedUpload + 1
                                if completedUpload == selectedImages.count {
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
}

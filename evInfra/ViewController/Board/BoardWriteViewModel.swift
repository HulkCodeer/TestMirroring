//
//  BoardWriteViewModel.swift
//  evInfra
//
//  Created by PKH on 2022/01/18.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

struct BoardWriteViewModel {
    
    var callback: ((Bool) -> Void)?
    
    func validateInput(_ title: String, _ contents: String) {
        if title.count <= 50 &&
            !title.contains(Const.BoardConstants.titlePlaceHolder) &&
            contents.count <= 1200 &&
            !contents.contains(Const.BoardConstants.contentsPlaceHolder) {
            self.callback?(true)
        } else {
            self.callback?(false)
        }
    }
    
    func registerBoard(_ mid: String, _ title: String, _ content: String, _ images: [UIImage] , completion: @escaping (Bool) -> Void) {
        
        Server.postBoardData(mid: mid, title: title, content: content, tags: "", charger_id: "") { (isSuccess, value) in
            if isSuccess {
                if let results = value as? Dictionary<String, String>,
                   let documentSRL = results["document_srl"] {
                    
                    guard images.count != 0 else {
                        completion(true)
                        return
                    }
                    
                    for (index, image) in images.enumerated() {
                        Server.boardImageUpload(mid: mid, document_srl: documentSRL, image: image, seq: "\(index)") { isSuccess, response in
                            if isSuccess {
                                completion(true)
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
    
    mutating func validateCompletion(callback: @escaping (_ status: Bool) -> Void) {
        self.callback = callback
    }
}

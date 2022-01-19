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
        if title.count <= 10 && contents.count <= 600  {
            self.callback?(true)
        } else {
            self.callback?(false)
        }
    }
    
    func registerBoard(_ mid: String, _ title: String, _ content: String, completion: @escaping (Bool) -> Void) {
        Server.postBoardData(mid: mid, title: title, content: content, tags: "", charger_id: "") { (isSuccess, value) in
            if isSuccess {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    mutating func validateCompletion(callback: @escaping (_ status: Bool) -> Void) {
        self.callback = callback
    }
}

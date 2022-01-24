//
//  BoardDetailViewModel.swift
//  evInfra
//
//  Created by PKH on 2022/01/24.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

struct BoardDetailViewModel {
    
    func fetchBoardDetail() {
        Server.fetchBoardDetail(mid: "", document_srl: "") { data in
            guard let data = data as? Data else { return }
            let decoder = JSONDecoder()
            
            do {
                let result = try decoder.decode(BoardResponseData.self, from: data)
                
            } catch {
                debugPrint("error")
            }
        }
    }
}

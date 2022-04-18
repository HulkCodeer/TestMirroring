//
//  EIAdManager.swift
//  evInfra
//
//  Created by Shin Park on 2021/11/19.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

class EIAdManager {
    
    static let AD_TYPE_END = 0
    static let AD_TYPE_START = 1
    static let AD_TYPE_COMMON = 2
    
    static let ACTION_VIEW = 0
    static let ACTION_CLICK = 1
    
    static let sharedInstance = EIAdManager()
    
    private init() {
    }
    
    // 광고 action 정보 수집
    func increase(adId: String, action: Int) {
        if !adId.isEmpty {
            Server.countAdAction(adId: adId, action: action)
        }
    }
    
    // 전면 광고 정보
    func getPageAd(completion: @escaping (Ad) -> Void) {
        var adInfo = Ad()
        
        Server.getAdLargeInfo(type: EIAdManager.AD_TYPE_START) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let code = json["code"].stringValue
                if code.equals("1000") {
                    adInfo.ad_id = String(json["ad_id"].intValue)
                    adInfo.ad_url = json["ad_url"].stringValue
                    adInfo.ad_image = json["ad_img"].stringValue
                    
                    // logging view count
                    self.increase(adId: adInfo.ad_id!, action: EIAdManager.ACTION_VIEW)
                }
            }
            completion(adInfo)
        }
    }
    
    func fetchBoardAdsToBoardListItem(completion: @escaping ([BoardListItem]) -> Void) {
        let client_id = "0"
        Server.getBoardAds(client_id: client_id) { (isSuccess, value) in
            if isSuccess {
                guard let data = value else { return }
                let decoder = JSONDecoder()
                
                var boardAdsList = [BoardListItem]()
                
                do {
                    let results = try decoder.decode([Ad].self, from: data)
                    
                    for adItem in results {
                        let boardAdItem = BoardListItem(title: adItem.ad_url,
                                                        content: adItem.ad_description,
                                                        nick_name: adItem.client_name,
                                                        module_srl: nil,
                                                        mb_id: adItem.client_id,
                                                        document_srl: adItem.ad_id,
                                                        last_update: nil,
                                                        regdate: nil,
                                                        is_notice: nil,
                                                        title_bold: nil,
                                                        title_color: nil,
                                                        readed_count: nil,
                                                        report_count: nil,
                                                        like_count: nil,
                                                        hate_count: nil,
                                                        comment_count: nil,
                                                        uploaded_count: nil,
                                                        tags: nil,
                                                        cover_filename: adItem.ad_image,
                                                        mb_profile: adItem.ad_logo,
                                                        blind: nil,
                                                        board_id: "ad",
                                                        files: nil)
                        boardAdsList.append(boardAdItem)
                    }
                    
                    completion(boardAdsList)
                } catch {
                    completion([])
                }
            } else {
                completion([])
            }
        }
    }
}

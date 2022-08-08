//
//  EIAdManager.swift
//  evInfra
//
//  Created by Shin Park on 2021/11/19.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

internal final class EIAdManager {
    
//    static let AD_TYPE_END = 0
//    static let AD_TYPE_START = 1
//    static let AD_TYPE_COMMON = 2
    
//    static let ACTION_VIEW = 0
//    static let ACTION_CLICK = 1
    enum Page: Int {
        case start = 1
        case end = 3
        case notice = 51
        case free = 52
        case charging = 53
        case gsc = 61
        case est = 62
    }
    
    enum Layer: Int {
        case top = 1
        case mid = 2
        case bottom = 3
        case popup = 4
    }
    
    enum EventAction: Int {
        case view = 0
        case click = 1
    }
    
    static let sharedInstance = EIAdManager()
    internal var boardAdList = [BoardListItem]()
    internal var topBannerList = [Ad]()
    
    private init() {
        getBoardAdsToBoardListItem { [weak self] adList in
            self?.boardAdList = adList
        }
    }
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    // 광고 action 정보 수집
    internal func increase(adId: String, action: Int) {
        guard !adId.isEmpty else { return }
        Server.countAdAction(adId: adId, action: action)
    }
    
    // 전면 광고 정보
    internal func getPageAd(completion: @escaping (Ad) -> Void) {
        var adInfo = Ad()
        
        Server.getAdLargeInfo(type: EIAdManager.Page.start.rawValue) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let code = json["code"].stringValue
                if code.equals("1000") {
                    adInfo.ad_id = String(json["ad_id"].intValue)
                    adInfo.ad_url = json["ad_url"].stringValue
                    adInfo.ad_image = json["ad_img"].stringValue
                    
                    // logging view count
                    self.increase(adId: adInfo.ad_id!, action: EIAdManager.EventAction.view.rawValue)
                }
            }
            completion(adInfo)
        }
    }
    
    // 커뮤니티 중간 광고
    private func getBoardAdsToBoardListItem(completion: @escaping ([BoardListItem]) -> Void) {
        let client_id = "0"
        Server.getBoardAds(client_id: client_id) { (isSuccess, value) in
            guard let data = value else { return }
            guard isSuccess else {
                completion([])
                return
            }
            
            let adList = JSON(data).arrayValue.map { Ad($0) }
            adList.forEach {
                self.boardAdList.append(BoardListItem($0))
            }
            
            completion(self.boardAdList)
        }
    }
    
    // 커뮤니티 상단 광고
    internal func getTopBannerInBoardList() {
        
    }
}

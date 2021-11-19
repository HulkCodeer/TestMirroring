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
    func increase(ad: EIAdInfo, action: Int) {
        Server.countAdAction(adId: ad.adId!, action: action)
    }
    
    // 전면 광고 정보
    func getPageAd(completion: @escaping (EIAdInfo) -> Void) {
        let adInfo = EIAdInfo()
        
        Server.getAdLargeInfo(type: EIAdManager.AD_TYPE_START) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let code = json["code"].stringValue
                if code.equals("1000") {
                    adInfo.adId = json["ad_id"].intValue
                    adInfo.adUrl = json["ad_url"].stringValue
                    adInfo.adImage = json["ad_img"].stringValue
                    
                    // logging view count
                    self.increase(ad: adInfo, action: EIAdManager.ACTION_VIEW)
                }
            }
            completion(adInfo)
        }
    }
}

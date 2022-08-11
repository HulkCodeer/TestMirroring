//
//  EIAdManager.swift
//  evInfra
//
//  Created by Shin Park on 2021/11/19.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

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
    
    private let disposebag = DisposeBag()
    
    private init() {}
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    // 광고 action 정보 수집
    internal func increase(adId: String, action: Int) {
        guard !adId.isEmpty else { return }
        Server.countAdAction(adId: adId, action: action)
    }
    
    internal func logEvent(adIds: [String], action: Int) {
        guard !adIds.isEmpty else { return }        
        RestApi().countEventAction(eventId: adIds, action: action)
            .disposed(by: self.disposebag)
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
    
    // MARK: - 커뮤니티 중간 광고
    internal func getBoardAdsToBoardListItem(completion: @escaping ([BoardListItem]) -> Void) {
        let client_id = "0"
        Server.getBoardAds(client_id: client_id) { (isSuccess, value) in
            guard let data = value else { return }
            guard isSuccess else {
                completion([])
                return
            }
            
            let adList = JSON(data).arrayValue.map { Ad($0) }
            var boardAdList = [BoardListItem]()
            adList.forEach {
                boardAdList.append(BoardListItem($0))
            }
            
            completion(boardAdList)
        }
    }
    
    // MARK: - 커뮤니티 상단 광고
    internal func getTopBannerInBoardList(page: Int, layer: Int, completion: @escaping ([AdsInfo]) -> Void) {
        RestApi().getAdsList(page: EIAdManager.Page.start.rawValue, layer: EIAdManager.Layer.top.rawValue)
                .convertData()
                .compactMap { result -> [AdsInfo]? in
                    switch result {
                    case .success(let data):
                        let json = JSON(data)
                        let adList = json["data"].arrayValue.map { AdsInfo($0) }
                        printLog(out: ":: PKH TEST ::")
                        printLog(out: "광고갯수: \(adList.count)")
                        printLog(out: "광고: \(adList)")
                        return adList
                        
                    case .failure(let errorMessage):
                        printLog(out: "Error Message : \(errorMessage)")
                        Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
                        return []
                    }
                }
                .subscribe(onNext: { adList in
                    completion(adList)
                })
                .disposed(by: self.disposebag)
    }
}

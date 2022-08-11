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

internal struct Promotion {
    enum Page: Int {
        case start = 1
        case end = 3
        case notice = 51
        case free = 52
        case charging = 53
        case gsc = 61
        case est = 62
        case jeju = 63
        case evinra = 64
        case event = 81
    }

    enum Layer: Int {
        case top = 1
        case mid = 2
        case bottom = 3
        case popup = 4
        case list = 9
        case none = 0
    }

    enum Action: Int {
        case view = 0
        case click = 1
    }
}

internal final class EIAdManager {
    
//    static let AD_TYPE_END = 0
//    static let AD_TYPE_START = 1
//    static let AD_TYPE_COMMON = 2
    
//    static let ACTION_VIEW = 0
//    static let ACTION_CLICK = 1
    
    static let sharedInstance = EIAdManager()
    
    private let disposebag = DisposeBag()
    
    private init() {}
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }

    // MARK: - 광고(배너) 뷰,클릭 로깅
    internal func logEvent(adIds: [String], action: Promotion.Action, page: Promotion.Page, layer: Promotion.Layer?) {
        guard !adIds.isEmpty else { return }
        Server.countEventAction(eventId: adIds, action: action, page: page, layer: layer ?? .none)
    }
    
    // MARK: - 광고(배너)/이벤트 조회
    internal func getAdsList(page: Promotion.Page, layer: Promotion.Layer, completion: @escaping ([AdsInfo]) -> Void) {
        Server.getAdsList(page: page, layer: layer) { isSuccess, value in
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

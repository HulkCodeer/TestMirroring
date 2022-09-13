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
        
        internal var toValue: Int {
            return self.rawValue
        }
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

    // MARK: - AWS 프로모션(광고/이벤트) click/view event 전송
    internal func logEvent(adIds: [String], action: Promotion.Action, page: Promotion.Page, layer: Promotion.Layer) {
        guard !adIds.isEmpty else { return }
        RestApi().countEventAction(eventId: adIds, action: action, page: page, layer: layer)
            .disposed(by: disposebag)
    }
    
    // MARK: - 광고(배너)/이벤트 조회
    internal func getAdsList(page: Promotion.Page, layer: Promotion.Layer, completion: @escaping ([AdsInfo]) -> Void) {
        RestApi().getAdsList(page: page, layer: layer)
                .convertData()
                .compactMap { result -> [AdsInfo]? in
                    switch result {
                    case .success(let data):
                        let json = JSON(data)
                        let adList = json["data"].arrayValue.map { AdsInfo($0) }
                        printLog(out: ":: PKH TEST ::")
                        printLog(out: "광고갯수: \(adList.count)")
                        printLog(out: "광고: \(adList)")
                        
                        var _adList = [AdsInfo]()
                        adList.forEach {
                            var _ad = $0
                            _ad.promotionPage = page
                            _ad.promotionLayer = layer
                            _adList.append(_ad)
                        }
                        return _adList
                        
                    case .failure(let errorMessage):
                        printLog(out: "Error Message : \(errorMessage)")
                        return []
                    }
                }
                .subscribe(onNext: { adList in
                    completion(adList)
                })
                .disposed(by: self.disposebag)
    }
    
    // MARK: - 기존 서버 프로모션(광고/이벤트) click/view event 전송
    /**
    Description: 이벤트 데이터 AWS 마이그레이션 완료 시, 삭제 예정
    */
    internal func logEvent(eventId: [String], action: Promotion.Action) {
        DispatchQueue.global(qos: .background).async {
            Server.countAdAction(eventId: eventId, action: action.rawValue)
        }
    }
}

//
//  DeepLinkModel.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/18.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import UIKit

internal final class DeepLinkModel: NSObject {
    internal static var shared = DeepLinkModel()
    
    // 앱링크 추가 될때마다 추가
    // true = 비로그인 상태로 진입 가능
    // false = 비로그인 상태로 진입 불가
    enum DeepLinkType: CaseIterable {
        case faqPayment
        case faqDetail
        case eventDetail // 이벤트 상세 바로가기
        case chargePrice
        case feeInfoAll
                
        var toValue: (deepLinkUrl: String, isLogin: Bool) {
            switch self {
            case .faqPayment:
                return ("faq_payment", true)
            case .faqDetail:
                return ("faq_detail", true)
            case .eventDetail:
                return ("event_url", true)
            case .chargePrice:
                return ("charge_price", true)
            case .feeInfoAll:
                return ("fee_info_all", true)
            }
        }
    }
    
    internal func openSchemeURL(urlstring: String, completionHandler: ((Bool) -> Void)? = nil) {
        printLog(out: "deepLink : \(urlstring)")
        guard let urlComponents = URLComponents(string: urlstring),
              let _queryItems = urlComponents.queryItems else { return }
        
        if _queryItems.contains(where: { item in
            return DeepLinkType.allCases.contains(where: { $0.toValue.deepLinkUrl == item.name })
        }) {
            guard let _vc = GlobalFunctionSwift.getLastPushVC(), !(_vc is PermissionsGuideViewController) else {
                GlobalDefine.shared.tempDeepLink = urlstring
                return
            }
            
            GlobalDefine.shared.tempDeepLink = ""
            
            switch _queryItems[0].name {
            case DeepLinkType.faqPayment.toValue.deepLinkUrl:
                let viewcon = UIStoryboard(name : "Info", bundle: nil).instantiateViewController(ofType: TermsViewController.self)
                viewcon.tabIndex = .faqTop
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                
            case DeepLinkType.faqDetail.toValue.deepLinkUrl:
                let viewcon = UIStoryboard(name : "Info", bundle: nil).instantiateViewController(ofType: TermsViewController.self)
                viewcon.tabIndex = .faqDetail
                guard let _queryParam = _queryItems["faq_detail"] else { return }
                viewcon.subURL = "type=\(_queryParam)"
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                
            case DeepLinkType.eventDetail.toValue.deepLinkUrl:
                let viewcon = NewEventDetailViewController()
                
                if let _eventDetailUrl = _queryItems["event_id"] {
                    var urlCompnents = URLComponents(string: _eventDetailUrl)
                    let mbId = URLQueryItem(name: "mbId", value: "\(MemberManager.shared.mbId)")
                    urlCompnents?.queryItems = [mbId]
                    viewcon.eventUrl = urlCompnents?.url?.absoluteString ?? ""
                }
                if let _title = _queryItems["title"] {
                    viewcon.naviTitle = _title
                }
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                                                
            case "fee_info_all", "charge_price":
                let viewcon = UIStoryboard(name : "Info", bundle: nil).instantiateViewController(ofType: TermsViewController.self)
                viewcon.tabIndex = .priceInfo
                
            default: break
            }
            
        }
    }
}

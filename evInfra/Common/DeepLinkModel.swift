//
//  DeepLinkModel.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/18.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

internal final class DeepLinkModel: NSObject {
    static var shared = DeepLinkModel()
    
    // 앱링크 추가 될때마다 추가
    // true = 비로그인 상태로 진입 가능
    // false = 비로그인 상태로 진입 불가
    enum DeepLinkType: CaseIterable {
        case faqPayment
        case faqDetail
                
        var rawValue: (deepLinkUrl: String, isLogin: Bool) {
            switch self {
            case .faqPayment:
                return ("faq_payment", true)
                
            case .faqDetail:
                return ("faq_detail", true)
            }
        }
    }
    
    internal func openSchemeURL(navi: UINavigationController, urlstring: String, completionHandler: ((Bool) -> Void)? = nil) {
        printLog(out: "deepLink : \(urlstring)")
        guard let urlComponents = URLComponents(string: urlstring),
              let _queryItems = urlComponents.queryItems else { return }
        
        if _queryItems.contains(where: { item in
            return DeepLinkType.allCases.contains(where: { $0.rawValue.deepLinkUrl == item.name })
        }) {
            
            let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
            let termsViewControll = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
                
            switch _queryItems[0].name {
            case "faq_payment":
                termsViewControll.tabIndex = .FAQTop
                
            case "faq_detail":
                termsViewControll.tabIndex = .FAQDetail
                guard let _queryParam = _queryItems["faq_detail"] else { return }
                termsViewControll.subURL = "type=\(_queryParam)"
                
            default: break
            }
            navi.push(viewController: termsViewControll)
        }
    }
}

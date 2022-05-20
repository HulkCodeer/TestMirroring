//
//  DeepLinkPath.swift
//  evInfra
//
//  Created by SH on 2021/10/22.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import UIKit

internal final class DeepLinkPath {
    static let sharedInstance = DeepLinkPath()
    
    // MARK: VARIABLE
    
    internal var linkPath: String
    internal var linkParameter: [URLQueryItem]?
    internal var isReady: Bool = false
    
    // Dynamic link -> Deep Link
    private let URL_PATH_MEMBERSHIP = "/membership_card"
    private let URL_PATH_PAYMENT = "/payment"
    private let URL_PATH_POINT = "/point"
    private let URL_PATH_FILTER = "/filter"
    private let URL_PATH_EVENT = "/event"
    private let URL_PATH_TERMS = "/webview"
    
    private let URL_PARAM_WEBVIEW_FAQ_TOP = "10"
    private let URL_PARAM_WEBVIEW_FAQ_DETAIL = "11"
    
    public init() {
        linkPath = ""
    }
    
    public func runDeepLink() {
        if !isReady {
            return
        }
        
        let storyboard: UIStoryboard
        var viewcon: UIViewController = UIViewController()
        
        guard let _mainNavi = GlobalDefine.shared.mainNavi, !linkPath.isEmpty else { return }
        
        switch linkPath {
        case URL_PATH_MEMBERSHIP:
            storyboard = UIStoryboard(name : "Membership", bundle: nil)
            viewcon = storyboard.instantiateViewController(ofType: MembershipCardViewController.self)
            
        case URL_PATH_PAYMENT :
            storyboard = UIStoryboard(name : "Member", bundle: nil)
            viewcon = storyboard.instantiateViewController(ofType: MyPayinfoViewController.self)
            
        case URL_PATH_POINT :
            storyboard = UIStoryboard(name : "Charge", bundle: nil)
            viewcon = storyboard.instantiateViewController(ofType: PointViewController.self)
            
        case URL_PATH_FILTER :
            storyboard = UIStoryboard(name : "Filter", bundle: nil)
            viewcon = storyboard.instantiateViewController(ofType: ChargerFilterViewController.self)
            
        case URL_PATH_EVENT :
            storyboard = UIStoryboard(name : "Event", bundle: nil)
            viewcon = storyboard.instantiateViewController(ofType: EventViewController.self)
                        
        case URL_PATH_TERMS :
            guard let paramItems = linkParameter else { return }
            if let type = paramItems.first(where: { $0.name == "type"})?.value {
                storyboard = UIStoryboard(name : "Info", bundle: nil)
                let termsViewControll = storyboard.instantiateViewController(ofType: TermsViewController.self)
                if (type == URL_PARAM_WEBVIEW_FAQ_TOP) {
                    termsViewControll.tabIndex = .FAQTop
                } else if (type == URL_PARAM_WEBVIEW_FAQ_DETAIL){
                    termsViewControll.tabIndex = .FAQDetail
                    if let page = paramItems.first(where: { $0.name == "page"})?.value {
                        termsViewControll.subURL = "type=" + page
                    }
                }
            }
        default: break
        }
        _mainNavi.push(viewController: viewcon)
    }
}

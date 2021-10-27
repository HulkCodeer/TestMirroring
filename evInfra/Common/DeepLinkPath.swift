//
//  DeepLinkPath.swift
//  evInfra
//
//  Created by SH on 2021/10/22.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import UIKit

class DeepLinkPath {
    static let sharedInstance = DeepLinkPath()
    var linkPath: String
    var linkParameter: [URLQueryItem]?
    var isReady: Bool = false
    
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
    
    public func runDeepLink(navigationController: UINavigationController) {
        if !isReady {
            return
        }
        switch linkPath {
        case URL_PATH_MEMBERSHIP:
            let mbsStoryboard = UIStoryboard(name : "Membership", bundle: nil)
            let mbscdVC = mbsStoryboard.instantiateViewController(withIdentifier: "MembershipCardViewController") as! MembershipCardViewController
            navigationController.push(viewController: mbscdVC)
            break
            
        case URL_PATH_PAYMENT :
            let memberStoryboard = UIStoryboard(name : "Member", bundle: nil)
            let myPayInfoVC = memberStoryboard.instantiateViewController(withIdentifier: "MyPayinfoViewController") as! MyPayinfoViewController
            navigationController.push(viewController: myPayInfoVC)
            break
            
        case URL_PATH_POINT :
            let chargeStoryboard = UIStoryboard(name : "Charge", bundle: nil)
            let pointVC = chargeStoryboard.instantiateViewController(withIdentifier: "PointViewController") as! PointViewController
            navigationController.push(viewController: pointVC)
            break
            
        case URL_PATH_FILTER :
            let filterStoryboard = UIStoryboard(name : "Filter", bundle: nil)
            let chargerFilterVC:ChargerFilterViewController = filterStoryboard.instantiateViewController(withIdentifier: "ChargerFilterViewController") as! ChargerFilterViewController
//            chargerFilterVC.delegate =
            navigationController.push(viewController: chargerFilterVC)
            break
            
        case URL_PATH_EVENT :
            let eventStoryboard = UIStoryboard(name : "Event", bundle: nil)
            let eventBoardVC = eventStoryboard.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
            navigationController.push(viewController: eventBoardVC)
            break
            
        case URL_PATH_TERMS :
            guard let paramItems = linkParameter else { return }
            if let type = paramItems.first(where: { $0.name == "type"})?.value {
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let termsViewControll = infoStoryboard.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
                if (type == URL_PARAM_WEBVIEW_FAQ_TOP) {
                    termsViewControll.tabIndex = .FAQTop
                } else if (type == URL_PARAM_WEBVIEW_FAQ_DETAIL){
                    termsViewControll.tabIndex = .FAQDetail
                    if let page = paramItems.first(where: { $0.name == "type"})?.value {
                        termsViewControll.subURL = "type=" + page
                    }
                }
                navigationController.push(viewController: termsViewControll)
            }
            break
            
        default:
            break
        }
        
    }
}

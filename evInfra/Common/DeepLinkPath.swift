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
    
    enum DynamicLinkUrlPathType {
        case membership
        case payment
        case point
        case filter
        case event
        case terms
        case event_detail
        case kakaolink(KakaoLinkType)
        
        enum KakaoLinkType: String {
            case charger = "charger"
            case board = "communityBoard"
            
            internal var toValue: String { self.rawValue }
        }
        
        internal var value: String {
            switch self {
            case .membership:
                return "/membership_card"
                
            case .payment:
                return "/payment"
                
            case .point:
                return "/point"
                
            case .filter:
                return "/filter"
                
            case .event:
                return "/event"
                
            case .terms:
                return "/webview"
                
            case .event_detail:
                return "/event_detail"
                
            case .kakaolink(let type):
                switch type {
                case .charger:
                    return "/charger"
                case .board:
                    return "/communityBoard"
                }
            }
        }
    }
    
    private enum URLParam: String, CaseIterable {
        case chargePrice = "7"
        case faqTop = "10"
        case faqDetail = "11"
        
        internal var toValue: String { return self.rawValue }
    }
    
    public init() {
        linkPath = ""
    }
    
    public func runDeepLink() {
        if !isReady {
            return
        }
        
        let storyboard: UIStoryboard
        
        guard let _mainNavi = GlobalDefine.shared.mainNavi, !linkPath.isEmpty else { return }
        
        switch linkPath {
        case DynamicLinkUrlPathType.membership.value:
            storyboard = UIStoryboard(name : "Membership", bundle: nil)
            let viewcon = storyboard.instantiateViewController(ofType: MembershipCardViewController.self)
            _mainNavi.push(viewController: viewcon)
            
        case DynamicLinkUrlPathType.payment.value:
            storyboard = UIStoryboard(name : "Member", bundle: nil)
            let viewcon = storyboard.instantiateViewController(ofType: MyPayinfoViewController.self)
            _mainNavi.push(viewController: viewcon)
            
        case DynamicLinkUrlPathType.point.value:
            storyboard = UIStoryboard(name : "Charge", bundle: nil)
            let viewcon = storyboard.instantiateViewController(ofType: PointViewController.self)
            _mainNavi.push(viewController: viewcon)
            
        case DynamicLinkUrlPathType.filter.value:
            storyboard = UIStoryboard(name : "Filter", bundle: nil)
            let viewcon = storyboard.instantiateViewController(ofType: ChargerFilterViewController.self)
            _mainNavi.push(viewController: viewcon)
            
        case DynamicLinkUrlPathType.event.value:
            storyboard = UIStoryboard(name : "Event", bundle: nil)
            let viewcon = storyboard.instantiateViewController(ofType: EventViewController.self)
            _mainNavi.push(viewController: viewcon)
                        
        case DynamicLinkUrlPathType.terms.value:
            guard let paramItems = linkParameter else { return }
            if let type = paramItems.first(where: { $0.name == "type"})?.value {
                storyboard = UIStoryboard(name : "Info", bundle: nil)
                let termsViewControll = storyboard.instantiateViewController(ofType: TermsViewController.self)                
                guard let value = URLParam.allCases.filter({ $0.toValue == type }).first else { return }

                switch value {
                case .faqTop:
                    termsViewControll.tabIndex = .faqTop
                case .faqDetail:
                    termsViewControll.tabIndex = .faqDetail
                    if let page = paramItems.first(where: { $0.name == "page"})?.value {
                        termsViewControll.subURL = "type=" + page
                    }
                case .chargePrice:
                    termsViewControll.tabIndex = .priceInfo
                }
                _mainNavi.push(viewController: termsViewControll)
            }
              
        case DynamicLinkUrlPathType.event_detail.value:
            if let _mainNav = GlobalDefine.shared.mainNavi {
                if _mainNav.containsViewController(ofKind: EventViewController.self) ||
                    _mainNav.containsViewController(ofKind: NewEventDetailViewController.self) {
                    let _viewControllers = _mainNav.viewControllers
//                    for vc in _viewControllers.reversed() {
//                        if let _vc = vc as? AppNavigationDrawerController {
//                            _mainNav.popToViewControllerWithHandler(vc: _vc, completion: { [weak self] in
//                                guard let self = self else { return }
//                                self.moveEventViewController()
//                            })
//                            return
//                        }
                        
                        // permissionVC 에서 main 진입한 경우
                        // self.moveEventVC()
                        
//                    }
                } else {
                    self.moveEventViewController()
                }
            }
            
        case DynamicLinkUrlPathType.kakaolink(.board).value:
            guard let paramItems = linkParameter else { return }
            guard let mid = paramItems.first(where: { $0.name == "mid" })?.value,
                  let documentSrl = paramItems.first(where: { $0.name == "documentSrl" })?.value else { return }
            
            storyboard = UIStoryboard(name : "BoardDetailViewController", bundle: nil)
            let viewcon = storyboard.instantiateViewController(ofType: BoardDetailViewController.self)
            let category = Board.CommunityType.allCases.filter { $0.rawValue == mid }.first ?? .FREE

            viewcon.category = category
            viewcon.document_srl = documentSrl
            viewcon.isFromStationDetailView = false
            _mainNavi.push(viewController: viewcon)
        default: break
        }
    }
    
    private func moveEventViewController() {
        guard let paramItems = linkParameter, let eventID = paramItems.first(where: { $0.name == "event_id"})?.value else { return }
        let viewcon = UIStoryboard(name : "Event", bundle: nil).instantiateViewController(ofType: EventViewController.self)
        viewcon.externalEventParam = paramItems.first(where: { $0.name == "param" })?.value?.description
        viewcon.externalEventID = Int(eventID)
        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
    }
}

//
//  SceneDelegate.swift
//  evInfra
//
//  Created by SH on 2021/10/22.
//  Copyright © 2021 soft-berry. All rights reserved.

import UIKit
import CoreData
import Material
import Firebase
import FirebaseDynamicLinks
import UserNotifications
import AuthenticationServices

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private let DYNAMIC_LINK_PREFIX = "https://com.soft-berry.ev-infra/"

    // first run
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        printLog(out: "scene:willConnectTo:options")
        
        // setup Deeplink instance if app started by Dynamic Link
        if let userActivity = connectionOptions.userActivities.first {
            self.handleUserActivity(userActivity: userActivity)
        }
        
        if let url = connectionOptions.urlContexts.first?.url, let deepLinkType = url.valueOf("kakaoLinkType") {
            switch deepLinkType {
            case DeepLinkPath.DynamicLinkUrlPathType.KakaoLinkType.charger.toValue:
                guard let chargerId = url.valueOf("charger_id") else { return }
                GlobalDefine.shared.sharedChargerIdFromDynamicLink = chargerId
                
            case DeepLinkPath.DynamicLinkUrlPathType.KakaoLinkType.board.toValue:
                guard let mid = url.valueOf("mid"), let documentSrl = url.valueOf("document_srl") else { return }
                DeepLinkPath.sharedInstance.linkPath = DeepLinkPath.DynamicLinkUrlPathType.kakaolink(.board).value
                DeepLinkPath.sharedInstance.linkParameter = [URLQueryItem(name: "mid", value: mid),
                                                             URLQueryItem(name: "documentSrl", value: documentSrl)]
                DeepLinkPath.sharedInstance.runDeepLink()
                
            default: break
            }
        } else {
            self.processToDeeplink(connectionOptions.urlContexts.first?.url.absoluteString ?? "", isSave: true)
        }
        
        setupEntryController(scene)
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        printLog(out: "sceneDidBecomeActive")
        guard let _mainViewcon = GlobalDefine.shared.mainViewcon else { return }
        _mainViewcon.sceneDidBecomeActiveCall()
    }

    // background
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        printLog(out: "scene:userActivity")
        // Dynamic Link
        self.handleUserActivity(userActivity: userActivity)
    }        
            
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        printLog(out: "scene:openURLContexts")
        // kakao auto login
        guard let _urlContentx = URLContexts.first else { return }
        let url = _urlContentx.url
        if KOSession.isKakaoAccountLoginCallback(url.absoluteURL) {
            KOSession.handleOpen(url)
        }

        if let deepLinkType = url.valueOf("kakaoLinkType") {
            switch deepLinkType {
            case DeepLinkPath.DynamicLinkUrlPathType.KakaoLinkType.charger.toValue:
                guard let chargerId = url.valueOf("charger_id") else { return }
                NotificationCenter.default.post(name: Notification.Name("kakaoScheme"), object: nil, userInfo: ["sharedid": chargerId])
                
            case DeepLinkPath.DynamicLinkUrlPathType.KakaoLinkType.board.toValue:
                guard let mid = url.valueOf("mid"), let documentSrl = url.valueOf("document_srl") else { return }
                DeepLinkPath.sharedInstance.linkPath = DeepLinkPath.DynamicLinkUrlPathType.kakaolink(.board).value
                DeepLinkPath.sharedInstance.linkParameter = [URLQueryItem(name: "mid", value: mid),
                                                             URLQueryItem(name: "documentSrl", value: documentSrl)]
                DeepLinkPath.sharedInstance.runDeepLink()
                
            default: break
            }
        }
                
        let deepLinkStr: String = url.absoluteString
        if !deepLinkStr.isEmpty {
            printLog(out: "DeepLink URL : \(deepLinkStr)")
            self.processToDeeplink(deepLinkStr)
        }
    }
    
    private func processToDeeplink(_ deepLinkStr: String, isSave: Bool = false) {
        printLog(out: "scene:processToDeeplink")
        if isSave {
            GlobalDefine.shared.tempDeepLink = deepLinkStr
        } else {
            DeepLinkModel.shared.openSchemeURL(urlstring: deepLinkStr)
        }
    }
    
    private func setupEntryController(_ scene: UIScene) {
        // init initial view controller
        let viewcon = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(ofType: IntroViewController.self)
        let reactor = IntroReactor(provider: RestApi())
        viewcon.reactor = reactor
        
        if !MemberManager.shared.memberId.isEmpty {
            FCMManager.sharedInstance.originalMemberId = MemberManager.shared.memberId
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
        if let windowScene = scene as? UIWindowScene {
            window = UIWindow(windowScene: windowScene)
            let navigationController = AppNavigationController(rootViewController: viewcon)
            GlobalDefine.shared.mainNavi = navigationController
            navigationController.navigationBar.isHidden = true
            
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor(named: "nt-white")
            appearance.shadowColor = nil
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.compactAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance
            
            window!.rootViewController = navigationController
            window!.makeKeyAndVisible()
        }
    }
    
    func handleUserActivity(userActivity: NSUserActivity){
        if let incomingURL = userActivity.webpageURL {
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) {
                (dynamicLink, error) in
                guard error == nil else {
                    print("found error")
                    return
                }
                                                
                if let dynamicLink = dynamicLink {
                    self.handleIncomingDynamicLink(dynamicLink)
                }
            }
            if !linkHandled {
                print("deep link does not contain valid required parameter ")
                return
            }
        }
    }
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            printLog(out: "has no url")
            return
        
        }
        printLog(out: "handleIncomingDynamicLink : \(url.absoluteString)") // dynamiclink -> deeplink
        // evinfra.page.link -> com.soft-berry.ev-infra
        if url.absoluteString.startsWith(DYNAMIC_LINK_PREFIX) { // filter URL by Prefix
            runLinkDirectly(url: url)
        }
    }
    
    func runLinkDirectly(url: URL) {
        let path = url.path        
        DeepLinkPath.sharedInstance.linkPath = url.path
        if let component = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            DeepLinkPath.sharedInstance.linkParameter = component.queryItems
        }
        DeepLinkPath.sharedInstance.runDeepLink()
    }        
}

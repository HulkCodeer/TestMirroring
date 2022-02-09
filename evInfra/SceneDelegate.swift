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
    var navigationController: AppNavigationController?
    
    private let DYNAMIC_LINK_PREFIX = "https://com.soft-berry.ev-infra/"

    // first run
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("scene:willConnectTo:options")
        
        // setup Deeplink instance if app started by Dynamic Link
        if let userActivity = connectionOptions.userActivities.first {
            self.handleUserActivity(userActivity: userActivity)
        }
        
        setupEntryController(scene)
    }

    // background
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print("scene:userActivity")
        // Dynamic Link
        self.handleUserActivity(userActivity: userActivity)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // kakao auto login
        if let url = URLContexts.first?.url {
            if KOSession.isKakaoAccountLoginCallback(url.absoluteURL) {
                KOSession.handleOpen(url)
            }
        }
    }
    
    private func setupEntryController(_ scene: UIScene) {
        // init initial view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let introViewController = storyboard.instantiateViewController(withIdentifier: "IntroViewController") as! IntroViewController
        
        guard let _ = (scene as? UIWindowScene) else { return }
        if let windowScene = scene as? UIWindowScene {
            window = UIWindow(windowScene: windowScene)
            navigationController = AppNavigationController(rootViewController: introViewController)//
            navigationController?.navigationBar.isHidden = true
            window!.rootViewController = navigationController
            window!.makeKeyAndVisible()
        }
    }
    
    func handleUserActivity(userActivity: NSUserActivity){
        if let incomingURL = userActivity.webpageURL {
            print("Incoming : \(incomingURL)")
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
            print("has no url")
            return
        
        }
        print("url : \(url.absoluteString)")
        if url.absoluteString.startsWith(DYNAMIC_LINK_PREFIX) { // filter URL by Prefix
            runLinkDirectly(url: url)
        }
    }
    
    func runLinkDirectly(url: URL) {
        let path = url.path
        print("path : \(path)")
        
        DeepLinkPath.sharedInstance.linkPath = url.path
        if let component = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            DeepLinkPath.sharedInstance.linkParameter = component.queryItems
        }
        DeepLinkPath.sharedInstance.runDeepLink(navigationController: navigationController!)
    }
}

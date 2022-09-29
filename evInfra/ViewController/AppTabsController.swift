//
//  AppTabBarController.swift
//  evInfra
//
//  Created by bulacode on 05/11/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

//import UIKit
//import Material
//
//class AppTabsController: TabsController {
////    var appTabControllerDelegate: AppTabsControllerDelegate? = nil
//    var appTabsControllerDelegates = [AppTabsControllerDelegate]()
//    var actionTitle: String? = ""
//    
//    open override func prepare() {
//        super.prepare()
//        view.backgroundColor = Color.blueGrey.lighten5
//        self.isUserInteractionEnabled = true
//        prepareActionBar()
//        preparePageTabBar()
//        delegate = self
//    }
//}
//
//extension AppTabsController: TabsControllerDelegate {
//    func tabsController(tabsController: TabsController, willSelect viewController: UIViewController) {
//        
//    }
//    
//    func tabsController(tabsController: TabsController, didSelect viewController: UIViewController){
//        appTabsControllerDelegates[tabsController.selectedIndex].changeTab()
//    }
//}
//
//extension AppTabsController {
//    fileprivate func preparePageTabBar() {
//        tabBar.isDividerHidden = true
//        tabBar.backgroundColor = Color.grey.lighten5
////        tabBar.setLineColor(UIColor(named: "content-primary")!, for: .selected)
//        tabBar.setLineColor(UIColor(named: "gr-5")!, for: .selected)
//    }
//}
//
//extension AppTabsController {
//    
//    func prepareActionBar() {
//        var backButton: IconButton!
//        backButton = IconButton(image: Icon.cm.arrowBack)
//        backButton.tintColor = UIColor(named: "content-primary")
//        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
//        
//        navigationItem.hidesBackButton = true
//        navigationItem.leftViews = [backButton]
//        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
//        if let titleText = actionTitle{
//            navigationItem.titleLabel.text = titleText
//        }
//        self.navigationController?.isNavigationBarHidden = false
//    }
//    
//    @objc
//    fileprivate func handleBackButton() {
//        self.navigationController?.pop()
//    }
//}
//
//protocol AppTabsControllerDelegate: class {
//    func changeTab()
//}

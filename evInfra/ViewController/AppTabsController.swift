//
//  AppTabBarController.swift
//  evInfra
//
//  Created by bulacode on 05/11/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import UIKit
import Material

class AppTabsController: TabsController {
//    var appTabControllerDelegate: AppTabsControllerDelegate? = nil
    var appTabsControllerDelegates = [AppTabsControllerDelegate]()
    var actionTitle: String? = ""
    
    private lazy var safelayoutView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    internal lazy var customNavi = CommonNaviView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
    open override func prepare() {
        super.prepare()
        view.backgroundColor = Color.blueGrey.lighten5
        self.isUserInteractionEnabled = true
        preparePageTabBar()
        delegate = self
  
        let containerHeight = UIScreen.main.bounds.height - (tabBar.frame.height + Constants.view.naviBarHeight)
        container.frame.size.height = containerHeight
        container.frame.origin.y = Constants.view.naviBarHeight
        rootViewController.view.frame = container.bounds
        
        view.addSubview(safelayoutView)
        safelayoutView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constants.view.naviBarHeight)
        }
        
        view.addSubview(customNavi)
        customNavi.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
}

extension AppTabsController: TabsControllerDelegate {
    func tabsController(tabsController: TabsController, willSelect viewController: UIViewController) {
        
    }
    
    func tabsController(tabsController: TabsController, didSelect viewController: UIViewController){
        appTabsControllerDelegates[tabsController.selectedIndex].changeTab()
    }
}

extension AppTabsController {
    fileprivate func preparePageTabBar() {
        tabBar.isDividerHidden = true
        tabBar.backgroundColor = Color.grey.lighten5
//        tabBar.setLineColor(UIColor(named: "content-primary")!, for: .selected)
        tabBar.setLineColor(UIColor(named: "gr-5")!, for: .selected)
    }
}

extension AppTabsController {
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
}

protocol AppTabsControllerDelegate: AnyObject {
    func changeTab()
}

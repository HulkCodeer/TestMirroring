//
//  AppTabBarController.swift
//  evInfra
//
//  Created by bulacode on 05/11/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import UIKit
import Material

class AppTabsController: TabsController{
    var actionTitle: String? = ""
    open override func prepare() {
        super.prepare()
        view.backgroundColor = Color.blueGrey.lighten5
        prepareActionBar()
        preparePageTabBar()
        delegate = self
    }
}

extension AppTabsController: TabsControllerDelegate{
    func tabsController(tabsController: TabsController, didSelect viewController: UIViewController){
        let vc = viewController as! MyWritingViewController
        vc.changedTab()
    }
}
extension AppTabsController {
    fileprivate func preparePageTabBar() {
        tabBar.isDividerHidden = true
        tabBar.backgroundColor = Color.grey.lighten5
        tabBar.setLineColor(UIColor(rgb: 0x15435C), for: .selected)
    }
}


extension AppTabsController {
    
    func prepareActionBar() {
        var backButton: IconButton!
        backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        if let titleText = actionTitle{
            navigationItem.titleLabel.text = titleText
        }
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
}

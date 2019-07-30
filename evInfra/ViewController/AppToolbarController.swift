//
//  AppToolbarController.swift
//  evInfra
//
//  Created by bulacode on 2018. 2. 19..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material

protocol AppToolbarDelegate {
    func toolBar(didClick iconButton: IconButton, arg: Any?)
}

class AppToolbarController: ToolbarController {
    
    var delegate: AppToolbarDelegate?
    
    fileprivate var menuButton: IconButton!
    fileprivate var searchButton: IconButton!
    fileprivate var mapButton: IconButton!
    fileprivate var isRouteMode: Bool = false
    
    override func prepare() {
        super.prepare()
        
        prepareMenuButton()
        prepareSearchButton()
        preparemapButton()
        prepareStatusBar()
        prepareToolbar()
    }
}

extension AppToolbarController {
    fileprivate func prepareMenuButton() {
        menuButton = IconButton(image: UIImage(named: "ic_menu"))
        menuButton.tintColor = UIColor(rgb: 0x15435C)
        menuButton.addTarget(self, action: #selector(handleMenuButton), for: .touchUpInside)
    }
    
    fileprivate func prepareSearchButton() {
        searchButton = IconButton(image: Icon.search)
        searchButton.tintColor = UIColor(rgb: 0x15435C)
        searchButton.addTarget(self, action: #selector(handleSearchButton), for: .touchUpInside)
        searchButton.tag = 1
    }
    
    fileprivate func preparemapButton() {
        mapButton = IconButton(image: UIImage(named: "ic_map_normal")?.withRenderingMode(.alwaysTemplate))
        mapButton.tintColor = UIColor(rgb: 0x15435C)
        mapButton.addTarget(self, action: #selector(handleMapButton), for: .touchUpInside)
        mapButton.tag = 2
    }
    
    fileprivate func prepareStatusBar() {
        statusBarStyle = .lightContent
        
        // Access the statusBar.
        //        statusBar.backgroundColor = Color.green.base
    }
    
    fileprivate func prepareToolbar() {
        toolbar.titleLabel.textColor = UIColor(rgb: 0x15435C)
        toolbar.titleLabel.textAlignment = .left
        toolbar.title = "EV Infra"
        
        toolbar.leftViews = [menuButton]
        toolbar.rightViews = [searchButton, mapButton]
    }
}

extension AppToolbarController {
    @objc
    fileprivate func handleMenuButton() {
        navigationDrawerController?.toggleLeftView()
    }
    
    @objc
    fileprivate func handleSearchButton() {
        self.delegate?.toolBar(didClick: self.searchButton, arg: nil)
    }
    
    
    @objc
    fileprivate func handleMapButton() {
        enableRouteMode(isRoute: !isRouteMode)
    }
    
    func enableRouteMode(isRoute: Bool) {
        if isRoute {
            mapButton.setImage(UIImage(named: "ic_map_navigation")?.withRenderingMode(.alwaysTemplate), for: .normal)
            isRouteMode = true
        } else {
            mapButton.setImage(UIImage(named: "ic_map_normal")?.withRenderingMode(.alwaysTemplate), for: .normal)//(image: Icon.normalMode, forState: .Normal)
            isRouteMode = false
        }
        self.delegate?.toolBar(didClick: self.mapButton, arg: isRoute)
    }
    
    func showStatusBar() {
        navigationDrawerController?.reShowStatusBar()
    }
    
    func hideStatusBar() {
        if navigationDrawerController!.isOpened {
            navigationDrawerController?.reHideStatusBar()
        }
    }
    
    func setMenuIcon(hasBadge : Bool) {
        if(hasBadge) {
            menuButton.image = UIImage(named: "ic_menu_badge")
        } else {
            menuButton.image = UIImage(named: "ic_menu")
        }
    }
}

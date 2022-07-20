//
//  AppToolbarController.swift
//  evInfra
//
//  Created by bulacode on 2018. 2. 19..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material

protocol AppToolbarDelegate: class {
    func toolBar(didClick iconButton: IconButton, arg: Any?)
}

class AppToolbarController: ToolbarController {
    
    internal weak var delegate: AppToolbarDelegate?
    
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
        menuButton = IconButton(image: UIImage(named: "icon_menu_sm"))
        menuButton.tintColor = UIColor(named: "content-primary")
        menuButton.addTarget(self, action: #selector(handleMenuButton), for: .touchUpInside)
    }
    
    fileprivate func prepareSearchButton() {
        searchButton = IconButton(image: UIImage(named: "icon_search_md"))
        searchButton.tintColor = UIColor(named: "content-primary")
        searchButton.addTarget(self, action: #selector(handleSearchButton), for: .touchUpInside)
        searchButton.tag = 1
    }
    
    fileprivate func preparemapButton() {
        mapButton = IconButton(image: UIImage(named: "icon_map_course_md")?.withRenderingMode(.alwaysTemplate))
        mapButton.tintColor = UIColor(named: "content-primary")
        mapButton.addTarget(self, action: #selector(handleMapButton), for: .touchUpInside)
        mapButton.tag = 2
    }
    
    fileprivate func prepareStatusBar() {
        statusBarStyle = .lightContent
        
        // Access the statusBar.
        //        statusBar.backgroundColor = Color.green.base
    }
    
    fileprivate func prepareToolbar() {
        toolbar.titleLabel.textColor = UIColor(named: "content-primary")
        toolbar.titleLabel.textAlignment = .center
                
        #if DEBUG
        toolbar.title = "EV Infra 테스트"
        #else
        toolbar.title = "EV Infra"
        #endif
    
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
            mapButton.setImage(UIImage(named: "icon_map_course_md")?.withRenderingMode(.alwaysTemplate), for: .normal)
            isRouteMode = true
        } else {
            mapButton.setImage(UIImage(named: "icon_map_course_md")?.withRenderingMode(.alwaysTemplate), for: .normal)//(image: Icon.normalMode, forState: .Normal)
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
            menuButton.image = UIImage(named: "icon_menu_badge")
        } else {
            menuButton.image = UIImage(named: "icon_menu_sm")
        }
    }
}

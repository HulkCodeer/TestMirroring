//
//  AppNavigationDrawerController.swift
//  evInfra
//
//  Created by bulacode on 2018. 2. 19..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material

class AppNavigationDrawerController: NavigationDrawerController {
    open override func prepare() {
        super.prepare()
        
        delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
}

extension AppNavigationDrawerController: NavigationDrawerControllerDelegate {
    func navigationDrawerController(navigationDrawerController: NavigationDrawerController, willOpen position: NavigationDrawerPosition) {
//        printLog(out: "navigationDrawerController willOpen")
    }
    
    func navigationDrawerController(navigationDrawerController: NavigationDrawerController, didOpen position: NavigationDrawerPosition) {
//        printLog(out: "navigationDrawerController didOpen")
    }
    
    func navigationDrawerController(navigationDrawerController: NavigationDrawerController, willClose position: NavigationDrawerPosition) {
//        printLog(out: "navigationDrawerController willClose")
    }
    
    func navigationDrawerController(navigationDrawerController: NavigationDrawerController, didClose position: NavigationDrawerPosition) {
//        printLog(out: "navigationDrawerController didClose")
    }
    
    func navigationDrawerController(navigationDrawerController: NavigationDrawerController, didBeginPanAt point: CGPoint, position: NavigationDrawerPosition) {
//        printLog(out: "navigationDrawerController didBeginPanAt: ", point, "with position:", .left == position ? "Left" : "Right")
    }
    
    func navigationDrawerController(navigationDrawerController: NavigationDrawerController, didChangePanAt point: CGPoint, position: NavigationDrawerPosition) {
//        printLog(out: "navigationDrawerController didChangePanAt: ", point, "with position:", .left == position ? "Left" : "Right")
    }
    
    func navigationDrawerController(navigationDrawerController: NavigationDrawerController, didEndPanAt point: CGPoint, position: NavigationDrawerPosition) {
//        printLog(out: "navigationDrawerController didEndPanAt: ", point, "with position:", .left == position ? "Left" : "Right")
    }
    
    func navigationDrawerController(navigationDrawerController: NavigationDrawerController, didTapAt point: CGPoint, position: NavigationDrawerPosition) {
//        printLog(out: "navigationDrawerController didTapAt: ", point, "with position:", .left == position ? "Left" : "Right")
    }
    
    func navigationDrawerController(navigationDrawerController: NavigationDrawerController, statusBar isHidden: Bool) {
//        printLog(out: "navigationDrawerController statusBar is hidden:", isHidden ? "Yes" : "No")
        guard isHidden else {
            return
        }
        (leftViewController as? LeftViewController)?.appeared()
    }
}

//
//  NavigationDrawerController.swift
//  evInfra
//
//  Created by bulacode on 30/07/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Material
import Motion

extension NavigationDrawerController{
    open func reShowStatusBar() {
        Motion.async { [weak self] in
            guard let v = Application.keyWindow else {
                return
            }
            
            v.windowLevel = UIWindow.Level.normal
            
            guard let `self` = self else {
                return
            }
            
            self.delegate?.navigationDrawerController?(navigationDrawerController: self, statusBar: false)
        }
    }
    
    /// Hides the statusBar.
    open func reHideStatusBar() {
        guard isHiddenStatusBarEnabled else {
            return
        }
        
        Motion.async { [weak self] in
            guard let v = Application.keyWindow else {
                return
            }
            
            v.windowLevel = UIWindow.Level.statusBar + 1
            
            guard let `self` = self else {
                return
            }
            
            self.delegate?.navigationDrawerController?(navigationDrawerController: self, statusBar: true)
        }
    }
}

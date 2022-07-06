//
//  UINavigationController.swift
//  evInfra
//
//  Created by Shin Park on 2018. 8. 24..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

public extension UINavigationController {
    
    /**
     Pop current view controller to previous view controller.
     
     - parameter type:     transition animation type.
     - parameter duration: transition animation duration.
     */
    func pop(transitionType type: String = kCATransitionReveal, subtype: String = kCATransitionFromLeft, duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, subtype: subtype, duration: duration)
        self.popViewController(animated: false)
    }
    
    func popToMain(transitionType type: String = kCATransitionMoveIn, subtype: String = kCATransitionFromLeft, duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, subtype: subtype, duration: duration)
        self.popToRootViewController(animated: true)
    }
    
    /**
     Push a new view controller on the view controllers's stack.
     
     - parameter vc:       view controller to push.
     - parameter type:     transition animation type.
     - parameter duration: transition animation duration.
     */
    func push(viewController vc: UIViewController, transitionType type: String = kCATransitionMoveIn, subtype: String = kCATransitionFromRight, duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, subtype: subtype, duration: duration)
        self.pushViewController(vc, animated: false)
    }
    
    private func addTransition(transitionType type: String, subtype: String, duration: CFTimeInterval) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = type
        transition.subtype = subtype
        self.view.layer.add(transition, forKey: nil)
    }
    
}

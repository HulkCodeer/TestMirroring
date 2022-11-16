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
    func pop(transitionType type: CATransitionType = CATransitionType.reveal, subtype: CATransitionSubtype = CATransitionSubtype.fromLeft, duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, subtype: subtype, duration: duration)
        self.popViewController(animated: false)
    }
    
    func popToMain(transitionType type: CATransitionType = CATransitionType.moveIn, subtype: CATransitionSubtype = CATransitionSubtype.fromLeft, duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, subtype: subtype, duration: duration)
        self.popToRootViewController(animated: true)
    }
    
    /**
     Push a new view controller on the view controllers's stack.
     
     - parameter vc:       view controller to push.
     - parameter type:     transition animation type.
     - parameter duration: transition animation duration.
     */
    func push(viewController vc: UIViewController, transitionType type: CATransitionType = CATransitionType.moveIn, subtype: CATransitionSubtype = CATransitionSubtype.fromRight, duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, subtype: subtype, duration: duration)
        self.pushViewController(vc, animated: false)
    }
    
    private func addTransition(transitionType type: CATransitionType, subtype: CATransitionSubtype, duration: CFTimeInterval) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = type
        transition.subtype = subtype
        self.view.layer.add(transition, forKey: nil)
    }
    
    internal func containsViewController(ofKind kind: AnyClass) -> Bool {
        self.viewControllers.contains(where: { $0.isKind(of: kind) })
    }
    
    internal func containsView(ofKind kind: AnyClass) -> UIViewController? {
        if let vc = self.viewControllers.last(where: { $0.isKind(of: kind) }) {
            return vc
        }
        return nil
    }
                
    internal func popToViewControllerWithHandler(vc: UIViewController, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popToViewController(vc, animated: true)
        CATransaction.commit()
    }
}

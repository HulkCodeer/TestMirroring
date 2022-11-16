//
//  UIViewController+Extension.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/10.
//  Copyright © 2022 soft-berry. All rights reserved.
//

//import Foundation
import UIKit

extension UIViewController {
    class func swizzleMethod() {
        let originalSelector = #selector(viewWillAppear)
        let swizzleSelector = #selector(viewEnterEventInViewWillAppear)
        
        guard let originMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzleMethod = class_getInstanceMethod(UIViewController.self, swizzleSelector) else { return }
        
        method_exchangeImplementations(originMethod, swizzleMethod)
    }
    
    @objc public final func viewEnterEventInViewWillAppear() {
        guard !(self is UIAlertController) else { return }
        let viewName = String(describing: type(of: self))
        EnterViewType().viewEnterLogEvent(viewName: viewName)
    }
}

extension UIViewController: Reusable {}

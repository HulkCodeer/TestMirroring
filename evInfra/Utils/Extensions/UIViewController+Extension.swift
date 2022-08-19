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
    
    @objc public func viewEnterEventInViewWillAppear() {
        guard !type(of: self).isEqual(UIAlertController.self) else { return }
        let viewControllerName = String(describing: type(of: self))
        let propertyName = ViewName.allCases.filter { $0.rawValue.equals(viewControllerName) }.compactMap { $0.propertyName }.first ?? ""
        
        guard !propertyName.isEmpty else { return }
        AmplitudeManager.shared.logEvent(type: .enter(.viewEnter), property: ["type" : propertyName])
    }
}

extension UIViewController: Reusable {}

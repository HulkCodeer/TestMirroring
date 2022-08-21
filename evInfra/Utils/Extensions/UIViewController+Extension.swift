//
//  UIViewController+Extension.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/10.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
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
        guard let title = self.title else { return }
        let property: [String: Any] = ["type" : title]
        AmplitudeManager.shared.logEvent(type: .enter(.viewEnter), property: property)
    }
}

extension UIViewController: Reusable {}

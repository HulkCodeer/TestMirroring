//
//  UIStackView+Extension.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/11/04.
//  Copyright © 2022 soft-berry. All rights reserved.
//


extension UIStackView {
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { allSubviews, subview -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap { $0.constraints })
        
        // Remove the views from self
        removedSubviews.forEach { $0.removeFromSuperview() }
    }
}

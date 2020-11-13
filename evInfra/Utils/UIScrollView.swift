//
//  UIScrollView.swift
//  evInfra
//
//  Created by bulacode on 2018. 5. 21..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation

extension UIScrollView {
    // Scroll to a specific view so that it's top is at the top our scrollview
    func scrollToView(view:UIView) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            
            var bottomOffset = scrollBottomOffset()
            if bottomOffset.y < 0 {
                bottomOffset.y = 0.0
            }
            if (childStartPoint.y > bottomOffset.y) {
                setContentOffset(bottomOffset, animated: true)
            } else {
                setContentOffset(CGPoint(x: 0, y: childStartPoint.y), animated: true)
            }
        }
        
//        if let origin = view.superview {
//            let childStartPoint = origin.convert(view.frame.origin, to: self.scrollView)
//
//            self.scrollView.scrollRectToVisible(CGRect(x:0, y:childStartPoint.y, width: 1,height: self.scrollView.frame.height), animated: false)
//            self.scrollView.setContentOffset(CGPoint(x:0, y:childStartPoint.y), animated: true)
//        }
    }
    
    // Scroll to top
    func scrollToTop() {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: true)
    }
    
    // Scroll to bottom
    func scrollToBottom() {
        let bottomOffset = scrollBottomOffset()
        if(bottomOffset.y > 0) {
            setContentOffset(bottomOffset, animated: true)
        }
    }

    private func scrollBottomOffset() -> CGPoint {
        return CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
    }
    
}



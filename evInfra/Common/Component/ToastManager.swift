//
//  ToastBar.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/10/20.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

extension UIView {
    private struct ToastKeys {
        static var timer        = "com.toast-swift.timer"
        static var duration     = "com.toast-swift.duration"
        static var point        = "com.toast-swift.point"
        static var completion   = "com.toast-swift.completion"
        static var activeToasts = "com.toast-swift.activeToasts"
        static var activityView = "com.toast-swift.activityView"
        static var queue        = "com.toast-swift.queue"
    }
    
    private class ToastCompletionWrapper {
        let completion: ((Bool) -> Void)?
        
        init(_ completion: ((Bool) -> Void)?) {
            self.completion = completion
        }
    }
    
    private enum ToastError: Error {
        case missingParameters
    }
    
    private var activeToasts: NSMutableArray {
        get {
            if let activeToasts = objc_getAssociatedObject(self, &ToastKeys.activeToasts) as? NSMutableArray {
                return activeToasts
            } else {
                let activeToasts = NSMutableArray()
                objc_setAssociatedObject(self, &ToastKeys.activeToasts, activeToasts, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return activeToasts
            }
        }
    }
    
    private var queue: NSMutableArray {
        get {
            if let queue = objc_getAssociatedObject(self, &ToastKeys.queue) as? NSMutableArray {
                return queue
            } else {
                let queue = NSMutableArray()
                objc_setAssociatedObject(self, &ToastKeys.queue, queue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return queue
            }
        }
    }
    
    internal func makeToast(_ message: String?, completion: ((_ didTap: Bool) -> Void)? = nil) {
        do {
            let toast = try toastViewForMessage(message, style: ToastManager.shared.style)
            showToast(toast, duration: ToastManager.shared.duration, position: ToastManager.shared.position, completion: completion)
        } catch ToastError.missingParameters {
            printLog(out: "Error: Message, Image all nil")
        } catch {}
    }
    
    internal func makeToast(_ message: String?, type: ToastImageType? = nil, completion: ((_ didTap: Bool) -> Void)? = nil) {
        do {
            let toast = try toastViewForMessage(message, type: type, style: ToastManager.shared.style)
            showToast(toast, duration: ToastManager.shared.duration, position: ToastManager.shared.position, completion: completion)
        } catch ToastError.missingParameters {
            printLog(out: "Error: Message, Image all nil")
        } catch {}
    }
    
    internal func makeProgressToast(_ message: String?, completion: ((_ didTap: Bool) -> Void)? = nil) {
        do {
            let toast = try toastViewForProgressMessage(message, style: ToastManager.shared.style)
            showToast(toast, duration: ToastManager.shared.duration, position: ToastManager.shared.position, completion: completion)
        } catch ToastError.missingParameters {
            printLog(out: "Error: Message, Image all nil")
        } catch {}
    }
                
    internal func showToast(_ toast: UIView, duration: TimeInterval = ToastManager.shared.duration, position: ToastPosition = ToastManager.shared.position, completion: ((_ didTap: Bool) -> Void)? = nil) {
        let point = position.centerPoint(forToast: toast, inSuperview: self)
        showToast(toast, duration: duration, point: point, completion: completion)
    }
                    
    internal func showToast(_ toast: UIView, duration: TimeInterval = ToastManager.shared.duration, point: CGPoint, completion: ((_ didTap: Bool) -> Void)? = nil) {
        objc_setAssociatedObject(toast, &ToastKeys.completion, ToastCompletionWrapper(completion), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        if ToastManager.shared.isQueueEnabled, activeToasts.count > 0 {
            objc_setAssociatedObject(toast, &ToastKeys.duration, NSNumber(value: duration), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(toast, &ToastKeys.point, NSValue(cgPoint: point), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            queue.add(toast)
        } else {
            showToast(toast, duration: duration, point: point)
        }
    }
        
    internal func hideToast() {
        guard let activeToast = activeToasts.firstObject as? UIView else { return }
        hideToast(activeToast)
    }
        
    internal func hideToast(_ toast: UIView) {
        guard activeToasts.contains(toast) else { return }
        hideToast(toast, fromTap: false)
    }
    
    internal func hideAllToasts(includeActivity: Bool = false, clearQueue: Bool = true) {
        if clearQueue {
            clearToastQueue()
        }
        
        activeToasts.compactMap { $0 as? UIView }
                    .forEach { hideToast($0) }
        
        if includeActivity {
            hideToastActivity()
        }
    }
    
    internal func clearToastQueue() {
        queue.removeAllObjects()
    }
    
    internal func hideToastActivity() {
        if let toast = objc_getAssociatedObject(self, &ToastKeys.activityView) as? UIView {
            UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
                toast.alpha = 0.0
            }) { _ in
                toast.removeFromSuperview()
                objc_setAssociatedObject(self, &ToastKeys.activityView, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    private func makeToastActivity(_ toast: UIView, point: CGPoint) {
        toast.alpha = 0.0
        toast.center = point
        
        objc_setAssociatedObject(self, &ToastKeys.activityView, toast, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        self.addSubview(toast)
        
        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: .curveEaseOut, animations: {
            toast.alpha = 1.0
        })
    }
                    
    private func showToast(_ toast: UIView, duration: TimeInterval, point: CGPoint) {
        toast.center = point
        toast.alpha = 0.0
        
        if ToastManager.shared.isTapToDismissEnabled {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(UIView.handleToastTapped(_:)))
            toast.addGestureRecognizer(recognizer)
            toast.isUserInteractionEnabled = true
            toast.isExclusiveTouch = true
        }
        
        activeToasts.add(toast)
        self.addSubview(toast)
        
        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            toast.alpha = 1.0
        }) { _ in
            let timer = Timer(timeInterval: duration, target: self, selector: #selector(UIView.toastTimerDidFinish(_:)), userInfo: toast, repeats: false)
            RunLoop.main.add(timer, forMode: .common)
            objc_setAssociatedObject(toast, ToastKeys.timer, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func hideToast(_ toast: UIView, fromTap: Bool) {
        if let timer = objc_getAssociatedObject(toast, &ToastKeys.timer) as? Timer {
            timer.invalidate()
        }
        
        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
            toast.alpha = 0.0
        }) { _ in
            toast.removeFromSuperview()
            self.activeToasts.remove(toast)
            
            if let wrapper = objc_getAssociatedObject(toast, &ToastKeys.completion) as? ToastCompletionWrapper, let completion = wrapper.completion {
                completion(fromTap)
            }
            
            if let nextToast = self.queue.firstObject as? UIView, let duration = objc_getAssociatedObject(nextToast, &ToastKeys.duration) as? NSNumber, let point = objc_getAssociatedObject(nextToast, &ToastKeys.point) as? NSValue {
                self.queue.removeObject(at: 0)
                self.showToast(nextToast, duration: duration.doubleValue, point: point.cgPointValue)
            }
        }
    }
    
    // MARK: - Events
    
    @objc
    private func handleToastTapped(_ recognizer: UITapGestureRecognizer) {
        guard let toast = recognizer.view else { return }
        hideToast(toast, fromTap: true)
    }
    
    @objc
    private func toastTimerDidFinish(_ timer: Timer) {
        guard let toast = timer.userInfo as? UIView else { return }
        hideToast(toast)
    }
    
    internal func toastViewForMessage(_ message: String?, style: ToastStyle) throws -> UIView {
        guard message != nil else {
            throw ToastError.missingParameters
        }
                        
        let messageLbl = UILabel().then {
            $0.text = message
            $0.numberOfLines = style.messageNumberOfLines
            $0.font = style.messageFont
            $0.textAlignment = style.messageAlignment
            $0.lineBreakMode = .byTruncatingTail
            $0.textColor = style.messageColor
            $0.backgroundColor = UIColor.clear
                        
            let calcMessageSize = CGSize(width: (self.bounds.size.width * style.maxWidthPercentage) - style.noImgViewMessageLeadingMargin - style.messageTrailingMargin, height: self.bounds.size.height * style.maxHeightPercentage)
            let messageSize = $0.sizeThatFits(calcMessageSize)
            let actualWidth = messageSize.width
            let actualHeight = messageSize.height
            $0.frame = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        }
        
        var messageRect = CGRect.zero
                
        messageRect.origin.x = style.noImgViewMessageLeadingMargin
        messageRect.origin.y = style.verticalMargin
        messageRect.size.width = messageLbl.bounds.size.width
        messageRect.size.height = messageLbl.bounds.size.height
                                
        let wrapperWidth = messageRect.origin.x + messageRect.size.width + style.messageTrailingMargin
        let wrapperHeight = messageRect.origin.y + messageRect.size.height + style.verticalMargin
                
        let wrapperView = UIView()
        wrapperView.backgroundColor = style.backgroundColor
        wrapperView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        wrapperView.layer.cornerRadius = style.cornerRadius
        
        if style.displayShadow {
            wrapperView.layer.shadowColor = UIColor.black.cgColor
            wrapperView.layer.shadowOpacity = style.shadowOpacity
            wrapperView.layer.shadowRadius = style.shadowRadius
            wrapperView.layer.shadowOffset = style.shadowOffset
        }
                                                                                   
        wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
        messageLbl.frame = messageRect
        wrapperView.addSubview(messageLbl)
                                                
        return wrapperView
    }
    
    internal func toastViewForMessage(_ message: String?, type: ToastImageType?, style: ToastStyle) throws -> UIView {
        guard let _message = message, let _type = type else {
            throw ToastError.missingParameters
        }
        
        var imageRect: CGRect = .zero
        
        let imageView = UIImageView().then {
            $0.image = _type.imageWithColor.image
            $0.tintColor = _type.imageWithColor.color
            $0.contentMode = .scaleAspectFit
                        
            imageRect.origin.x = style.imgViewLeadingMargin
            imageRect.origin.y = style.verticalMargin
            imageRect.size.width = style.imageSize.width
            imageRect.size.height = style.imageSize.height
            $0.frame = imageRect
        }
        
        let messageLbl = UILabel().then {
            $0.text = _message
            $0.numberOfLines = style.messageNumberOfLines
            $0.font = style.messageFont
            $0.textAlignment = style.messageAlignment
            $0.lineBreakMode = .byTruncatingTail
            $0.textColor = style.messageColor
            $0.backgroundColor = UIColor.clear
                                                            
            let calcMessageSize = CGSize(width: (self.bounds.size.width * style.maxWidthPercentage) - (imageRect.size.width + imageRect.origin.x) - style.imgViewTrailingMargin - style.messageTrailingMargin, height: self.bounds.size.height * style.maxHeightPercentage)
            let messageSize = $0.sizeThatFits(calcMessageSize)
            let actualWidth = messageSize.width
            let actualHeight = messageSize.height
            $0.frame = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        }
        
        var messageRect = CGRect.zero
        messageRect.origin.x = imageRect.origin.x + imageRect.size.width + style.imgViewTrailingMargin
        messageRect.origin.y = style.verticalMargin
        messageRect.size.width = messageLbl.bounds.size.width
        messageRect.size.height = messageLbl.bounds.size.height
        
                        
        let wrapperWidth = messageRect.origin.x + messageRect.size.width + style.messageTrailingMargin
        let wrapperHeight = messageRect.origin.y + messageRect.size.height + style.verticalMargin
                
        imageView.center.y = wrapperHeight / 2
                
        let wrapperView = UIView()
        wrapperView.backgroundColor = style.backgroundColor
        wrapperView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        wrapperView.layer.cornerRadius = style.cornerRadius
        
        if style.displayShadow {
            wrapperView.layer.shadowColor = UIColor.black.cgColor
            wrapperView.layer.shadowOpacity = style.shadowOpacity
            wrapperView.layer.shadowRadius = style.shadowRadius
            wrapperView.layer.shadowOffset = style.shadowOffset
        }
                                                                                   
        wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
        messageLbl.frame = messageRect
        wrapperView.addSubview(messageLbl)
        wrapperView.addSubview(imageView)
                        
        return wrapperView
    }
    
    internal func toastViewForProgressMessage(_ message: String?, style: ToastStyle) throws -> UIView {
        guard let _message = message else {
            throw ToastError.missingParameters
        }
                        
        let circleProgressBarView = ToastProgressBarView(frame: CGRect(x: 14, y: 0, width: 20, height: 20))
        circleProgressBarView.animation(duration: 5)
        
        let messageLbl = UILabel().then {
            $0.text = _message
            $0.numberOfLines = style.messageNumberOfLines
            $0.font = style.messageFont
            $0.textAlignment = style.messageAlignment
            $0.lineBreakMode = .byTruncatingTail
            $0.textColor = style.messageColor
            $0.backgroundColor = UIColor.clear
                                                            
            let calcMessageSize = CGSize(width: (self.bounds.size.width * style.maxWidthPercentage) - (circleProgressBarView.frame.size.width + circleProgressBarView.frame.origin.x) - style.progressTrailingMargin - style.messageTrailingMargin, height: self.bounds.size.height * style.maxHeightPercentage)
            let messageSize = $0.sizeThatFits(calcMessageSize)
            let actualWidth = messageSize.width
            let actualHeight = messageSize.height
            $0.frame = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        }
        
        var messageRect = CGRect.zero
        messageRect.origin.x = circleProgressBarView.frame.origin.x + circleProgressBarView.frame.size.width + style.progressTrailingMargin
        messageRect.origin.y = style.progressVerticalMargin
        messageRect.size.width = messageLbl.bounds.size.width
        messageRect.size.height = messageLbl.bounds.size.height
        
                        
        let wrapperWidth = messageRect.origin.x + messageRect.size.width + style.messageTrailingMargin
        let wrapperHeight = messageRect.origin.y + messageRect.size.height + style.progressVerticalMargin
                
        circleProgressBarView.center.y = wrapperHeight / 2
                
        let wrapperView = UIView()
        wrapperView.backgroundColor = style.backgroundColor
        wrapperView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        wrapperView.layer.cornerRadius = style.cornerRadius
        
        if style.displayShadow {
            wrapperView.layer.shadowColor = UIColor.black.cgColor
            wrapperView.layer.shadowOpacity = style.shadowOpacity
            wrapperView.layer.shadowRadius = style.shadowRadius
            wrapperView.layer.shadowOffset = style.shadowOffset
        }
                                                                                   
        wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
        messageLbl.frame = messageRect
        wrapperView.addSubview(messageLbl)
        wrapperView.addSubview(circleProgressBarView)
                        
        return wrapperView
    }
        
    var csSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        } else {
            return .zero
        }
    }
}

internal enum ToastImageType {
    typealias ImageTypeWithColor = (image: UIImage, color: UIColor)
    
    case check
    case lock
    case info
    
    internal var imageWithColor: ImageTypeWithColor {
        switch self {
        case .check: return (Icons.iconCheckMd.image, Colors.contentPositive.color)
        case .lock: return (Icons.iconLockMd.image, Colors.rd3.color)
        case .info: return (Icons.iconInfoMd.image, Colors.contentWarning.color)
        }
    }
}

internal struct ToastStyle {

    fileprivate init() {}
    
    fileprivate var backgroundColor: UIColor = Colors.nt8.color    
    fileprivate var messageColor: UIColor = Colors.contentOnColor.color
    fileprivate var maxWidthPercentage: CGFloat = 0.8 {
        didSet {
            maxWidthPercentage = max(min(maxWidthPercentage, 1.0), 0.0)
        }
    }

    fileprivate var maxHeightPercentage: CGFloat = 0.8 {
        didSet {
            maxHeightPercentage = max(min(maxHeightPercentage, 1.0), 0.0)
        }
    }
    
    fileprivate var imgViewLeadingMargin: CGFloat = 12.0
    fileprivate var imgViewTrailingMargin: CGFloat = 8.0
    fileprivate var noImgViewMessageLeadingMargin: CGFloat = 16.0
    fileprivate var verticalMargin: CGFloat = 12.0
    fileprivate var progressTrailingMargin: CGFloat = 10.0
    fileprivate var progressVerticalMargin: CGFloat = 13.0
    fileprivate var messageTrailingMargin: CGFloat = 16.0
    fileprivate var messageBottomMargin: CGFloat = 16.0
    fileprivate var cornerRadius: CGFloat = 8.0
    fileprivate var messageFont: UIFont = .systemFont(ofSize: 14.0)
    fileprivate var messageAlignment: NSTextAlignment = .left
    fileprivate var messageNumberOfLines = 2
    fileprivate var displayShadow = false
    fileprivate var shadowColor: UIColor = .black
    fileprivate var shadowOpacity: Float = 0.8 {
        didSet {
            shadowOpacity = max(min(shadowOpacity, 1.0), 0.0)
        }
    }

    fileprivate var shadowRadius: CGFloat = 6.0
    fileprivate var shadowOffset = CGSize(width: 4.0, height: 4.0)
    fileprivate var imageSize = CGSize(width: 24, height: 24)
    fileprivate var activitySize = CGSize(width: 100.0, height: 100.0)
    fileprivate var fadeDuration: TimeInterval = 0.2
    fileprivate var activityIndicatorColor: UIColor = .white
    fileprivate var activityBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
    
}

internal final class ToastManager {
    internal static let shared = ToastManager()
    fileprivate var style = ToastStyle()
    fileprivate var isTapToDismissEnabled = true
    fileprivate var isQueueEnabled = false
    fileprivate var duration: TimeInterval = 3.0
    fileprivate var position: ToastPosition = .bottom
}

internal enum ToastPosition {
    case top
    case center
    case bottom
    
    fileprivate func centerPoint(forToast toast: UIView, inSuperview superview: UIView) -> CGPoint {
        let topPadding: CGFloat = ToastManager.shared.style.messageBottomMargin + superview.csSafeAreaInsets.top
        let bottomPadding: CGFloat = ToastManager.shared.style.messageBottomMargin + superview.csSafeAreaInsets.bottom
        
        switch self {
        case .top:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: (toast.frame.size.height / 2.0) + topPadding)
        case .center:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: superview.bounds.size.height / 2.0)
        case .bottom:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: (superview.bounds.size.height - (toast.frame.size.height / 2.0)) - bottomPadding)
        }
    }
}


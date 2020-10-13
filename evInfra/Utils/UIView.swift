//
//  UIView.swift
//  evInfra
//
//  Created by bulacode on 2018. 3. 22..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

public enum GVSpace {
    case top
    case bottom
    case leading
    case trailing
    
    func layoutAttribute() -> NSLayoutAttribute {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        case .leading: return .leading
        case .trailing: return .trailing
        }
    }
}

public enum GVAxis {
    case vertical
    case horizontal
}

extension NSLayoutConstraint {
    
    // MARK: - Added Stored Property
    
    @nonobjc static private var originalConstantKey  = "originalConstant"
    
    private var originalConstant: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &NSLayoutConstraint.originalConstantKey) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &NSLayoutConstraint.originalConstantKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Change Constant
    
    fileprivate func setGoneConstant() {
        guard self.originalConstant == nil else { return }
        self.originalConstant = self.constant
        self.constant = 0
    }
    
    fileprivate func setVisibleConstant() {
        guard let originalConstant = self.originalConstant else { return }
        self.constant = originalConstant
        self.originalConstant = nil
    }
    
    // MARK: - Determine Constraint
    
    fileprivate func isAspectRatio() -> Bool {
        return (self.firstAttribute == .height && self.secondAttribute == .width)
            || (self.firstAttribute == .width && self.secondAttribute == .height)
    }
    
    fileprivate func isHeight() -> Bool {
        // without NSSizeLayoutConstraint
        return self.firstAttribute == .height && self.secondAttribute == .notAnAttribute && type(of: self) === NSLayoutConstraint.self
    }
    
    fileprivate func isWidth() -> Bool {
        // without NSSizeLayoutConstraint
        return self.firstAttribute == .width && self.secondAttribute == .notAnAttribute && type(of: self) === NSLayoutConstraint.self
    }
    
    fileprivate func isSpacing(itemView: UIView, attribute: NSLayoutAttribute) -> Bool {
        return (self.firstItem as? UIView == itemView && self.firstAttribute == attribute)
            || (self.secondItem as? UIView == itemView && self.secondAttribute == attribute)
    }
    
    fileprivate func isEqual(itemView: UIView, attribute: NSLayoutAttribute) -> Bool {
        return (self.firstItem as? UIView == itemView && self.secondItem != nil && self.firstAttribute == attribute)
            || (self.secondItem as? UIView == itemView && self.secondAttribute == attribute)
    }
}

@IBDesignable extension UIView {
    // MARK: - Added Stored Property
    @nonobjc static private var isGoneKey  = "isGone"
    @nonobjc static private var aspectRatioConstraintsKey = "aspectRatioConstraints"
    @nonobjc static private var equalHeightConstraintsKey = "equalHeightConstraints"
    @nonobjc static private var equalWidthConstraintsKey = "equalWidthConstraints"
    
    public private(set) var isGone: Bool {
        get {
            return (objc_getAssociatedObject(self, &UIView.isGoneKey) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &UIView.isGoneKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var aspectRatioConstraints: [NSLayoutConstraint]? {
        get {
            return objc_getAssociatedObject(self, &UIView.aspectRatioConstraintsKey) as? [NSLayoutConstraint]
        }
        set {
            objc_setAssociatedObject(self, &UIView.aspectRatioConstraintsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var equalHeightConstraints: [NSLayoutConstraint]? {
        get {
            return objc_getAssociatedObject(self, &UIView.equalHeightConstraintsKey) as? [NSLayoutConstraint]
        }
        set {
            objc_setAssociatedObject(self, &UIView.equalHeightConstraintsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var equalWidthConstraints: [NSLayoutConstraint]? {
        get {
            return objc_getAssociatedObject(self, &UIView.equalWidthConstraintsKey) as? [NSLayoutConstraint]
        }
        set {
            objc_setAssociatedObject(self, &UIView.equalWidthConstraintsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - gone / visible Method
    
    /// Size constraint of self is changed to 0, realizing an Android-like gone.
    ///
    /// If self has no size constraint, it will be added.
    ///
    /// - Parameter axis: Normally, both the height and width constraints are set to 0, but
    /// if you want to set either one of the constraints to 0.
    ///
    /// - Parameter spaces: At the same time, specify when you want to set the space top, bottom,
    /// leading and trailing to 0.
    ///
    /// - Parameter completion: Blocks to be executed upon completion.
    ///
    public func gone(axis: GVAxis? = nil, spaces: [GVSpace]? = nil, completion: (() -> ())? = nil) {
        self.isGone = true
        // Find size constraints to make it 0 constant, if not create it.
        if axis == .vertical {
            var heightConstraints = self.findHeightConstraints()
            if heightConstraints == nil {
                heightConstraints = [self.addHeightConstraint()]
            }
            heightConstraints?.forEach { $0.setGoneConstant() }
        } else if axis == .horizontal {
            var widthConstraints = self.findWidthConstraints()
            if widthConstraints == nil  {
                widthConstraints = [self.addWidthConstraint()]
            }
            widthConstraints?.forEach { $0.setGoneConstant() }
        } else {
            var heightConstraints = self.findHeightConstraints()
            var widthConstraints = self.findWidthConstraints()
            if widthConstraints == nil && heightConstraints == nil {
                heightConstraints = [self.addHeightConstraint()]
                widthConstraints = [self.addWidthConstraint()]
            }
            heightConstraints?.forEach { $0.setGoneConstant() }
            widthConstraints?.forEach { $0.setGoneConstant() }
        }
        
        // Inactivate constraints that disturbs becoming 0 constant.
        self.aspectRatioConstraints = self.findAspectRatioConstraints()
        self.aspectRatioConstraints?.forEach { $0.isActive = false }
        
        self.equalWidthConstraints = self.findEqualConstraints(itemView: self, attribute: .width)
        self.equalWidthConstraints?.forEach { $0.isActive = false }
        
        self.equalHeightConstraints = self.findEqualConstraints(itemView: self, attribute: .height)
        self.equalHeightConstraints?.forEach { $0.isActive = false }
        
        // Set space constraints to 0 constant.
        spaces?.forEach { self.goneSpacing( $0.layoutAttribute()) }
        
        self.setNeedsLayout()
        
        completion?()
    }
    
    /// Restore the constraint set to 0 by gone to the original constant.
    ///
    /// Space constraints are also restored.
    ///
    /// - Parameter completion: Blocks to be executed upon completion.
    ///
    public func visible(completion: (() -> ())? = nil) {
        guard self.isGone else { return }
        
        self.isGone = false
        // Restore size constraints to original constant.
        self.findHeightConstraints()?.forEach { $0.setVisibleConstant() }
        self.findWidthConstraints()?.forEach { $0.setVisibleConstant() }
        
        // Restore space constraints to original constant.
        [.top, .bottom, .leading, .trailing].forEach { self.visibleSpacing($0) }
        
        // Reactivate other constraints.
        self.aspectRatioConstraints?.forEach { $0.isActive = true }
        self.equalWidthConstraints?.forEach { $0.isActive = true }
        self.equalHeightConstraints?.forEach { $0.isActive = true }
        
        self.setNeedsLayout()
        
        completion?()
    }
    
    private func goneSpacing(_ attribute: NSLayoutAttribute) {
        guard let spacingConstraints = self.findSpacingConstraints(itemView: self, attribute: attribute) else { return }
        spacingConstraints.forEach { $0.setGoneConstant() }
    }
    
    private func visibleSpacing(_ attribute: NSLayoutAttribute) {
        guard let spacingConstraints = self.findSpacingConstraints(itemView: self, attribute: attribute) else { return }
        spacingConstraints.forEach { $0.setVisibleConstant() }
    }
    
    // MARK: - Find Constraints
    
    private func findHeightConstraints() -> [NSLayoutConstraint]? {
        let heightConstraints = self.constraints.filter { $0.isHeight() }
        return heightConstraints.count > 0 ? heightConstraints : nil
    }
    
    private func findWidthConstraints() -> [NSLayoutConstraint]? {
        let widthConstraints = self.constraints.filter { $0.isWidth() }
        return widthConstraints.count > 0 ? widthConstraints : nil
    }
    
    private func findAspectRatioConstraints() -> [NSLayoutConstraint]? {
        return self.constraints.filter { $0.isAspectRatio() }
    }
    
    private func findSpacingConstraints(itemView: UIView, attribute: NSLayoutAttribute) -> [NSLayoutConstraint]? {
        guard let superview = self.superview else { return nil }
        let spacingConstraints = superview.constraints.filter { $0.isSpacing(itemView: itemView, attribute: attribute) }
        if spacingConstraints.count > 0 {
            return spacingConstraints
        } else {
            return superview.findSpacingConstraints(itemView: itemView, attribute: attribute)
        }
    }
    
    private func findEqualConstraints(itemView: UIView, attribute: NSLayoutAttribute) -> [NSLayoutConstraint]? {
        guard let superview = self.superview else { return nil }
        let equalConstraints = superview.constraints.filter { $0.isEqual(itemView: itemView, attribute: attribute) }
        if equalConstraints.count > 0 {
            return equalConstraints
        } else {
            return superview.findEqualConstraints(itemView: itemView, attribute: attribute)
        }
    }
    
    // MARK: - Add Size Constraint
    
    @discardableResult
    private func addHeightConstraint() -> NSLayoutConstraint {
        return self.addConstraint(attribute: .height, constant: self.bounds.size.height)
    }
    
    @discardableResult
    private func addWidthConstraint() -> NSLayoutConstraint {
        return self.addConstraint(attribute: .width, constant: self.bounds.size.width)
    }
    
    @discardableResult
    private func addConstraint(attribute: NSLayoutAttribute, constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: constant)
        constraint.priority = UILayoutPriority(rawValue: 751)
        self.addConstraint(constraint)
        return constraint
    }
    
    func visiblity(gone: Bool, dimension: CGFloat = 0.0, attribute: NSLayoutAttribute = .height) -> Void {
        if let constraint = (self.constraints.filter{$0.firstAttribute == attribute}.first) {
            constraint.constant = gone ? 0.0 : dimension
            self.layoutIfNeeded()
            self.isHidden = gone
        }
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    // custom UIView (border, radius)
    func setBorderRadius(_ corners: UIRectCorner, radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        self.clipsToBounds = true
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        self.layer.mask = mask
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = mask.frame
        borderLayer.name = "borderLayer"
        
        // remove unused layer
        if let layers = self.layer.sublayers {
            for layer in layers {
                if let name = layer.name {
                    if name.elementsEqual("borderLayer") {
                        layer.removeFromSuperlayer()
                    }
                }
            }
        }
        layer.addSublayer(borderLayer)
    }
    
    func addTapGesture(target: Any, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    /* The color of the shadow. Defaults to opaque black. Colors created
     * from patterns are currently NOT supported. Animatable. */
    @IBInspectable var shadowColor: UIColor? {
        set {
            layer.shadowColor = newValue!.cgColor
        }
        get {
            if let color = layer.shadowColor {
                return UIColor.init(cgColor: color)
            }
            else {
                return nil
            }
        }
    }

    /* The opacity of the shadow. Defaults to 0. Specifying a value outside the
     * [0,1] range will give undefined results. Animatable. */
    @IBInspectable var shadowOpacity: Float {
        set {
            layer.shadowOpacity = newValue
        }
        get {
            return layer.shadowOpacity
        }
    }

    /* The shadow offset. Defaults to (0, -3). Animatable. */
    @IBInspectable var shadowOffset: CGPoint {
        set {
            layer.shadowOffset = CGSize(width: newValue.x, height: newValue.y)
        }
        get {
            return CGPoint(x: layer.shadowOffset.width, y:layer.shadowOffset.height)
        }
    }

    /* The blur radius used to create the shadow. Defaults to 3. Animatable. */
    @IBInspectable var shadowRadius: CGFloat {
        set {
            layer.shadowRadius = newValue
        }
        get {
            return layer.shadowRadius
        }
    }
}

extension UIView {
    
    func constrainCentered(_ subview: UIView) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let verticalContraint = NSLayoutConstraint(
            item: subview,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0)
        
        let horizontalContraint = NSLayoutConstraint(
            item: subview,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0)
        
        let heightContraint = NSLayoutConstraint(
            item: subview,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: subview.frame.height)
        
        let widthContraint = NSLayoutConstraint(
            item: subview,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: subview.frame.width)
        
        addConstraints([
            horizontalContraint,
            verticalContraint,
            heightContraint,
            widthContraint])
    }
    
    func constrainToEdges(_ subview: UIView) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let topContraint = NSLayoutConstraint(
            item: subview,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 0)
        
        let bottomConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0)
        
        let leadingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0)
        
        let trailingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0)
        
        addConstraints([
            topContraint,
            bottomConstraint,
            leadingContraint,
            trailingContraint])
    }
}

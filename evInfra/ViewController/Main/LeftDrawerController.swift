//
//  LeftDrawerController.swift
//  evInfra
//
//  Created by youjin kim on 2022/10/17.
//  Copyright © 2022 soft-berry. All rights reserved.
//
// Material NavigationDrawerController 참고.

import UIKit

protocol LeftDrawerDelegate: AnyObject {
    func openLeftView(_ completion: (() -> Void)?)
    func closeLeftView(_ completion: (() -> Void)?)
}

final class LeftDrawerController: UIViewController {
    private lazy var contentViewController = UIViewController()
    private var rootViewController: UINavigationController {
        didSet {
            guard oldValue != rootViewController else { return }
            
            removeViewController(viewController: oldValue)
            prepare(viewController: rootViewController, in: container)
        }
    }
    private var leftViewController: NewLeftViewController
    
    internal var isUserInteractionEnabled: Bool {
        get {
            return rootViewController.view.isUserInteractionEnabled
        }
        set(value) {
            rootViewController.view.isUserInteractionEnabled = value
        }
    }
    
    private lazy var container = UIView().then {
        $0.frame = view.bounds
        $0.clipsToBounds = true
        $0.contentScaleFactor = UIScreen.main.scale
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private lazy var leftView = UIView().then {
        leftViewWidth = .phone == UIDevice.current.userInterfaceIdiom ? 280 : 320
        $0.frame = CGRect(x: 0, y: 0, width: leftViewWidth, height: view.bounds.height)
        $0.backgroundColor = .white
        $0.isHidden = true
        
        $0.layer.position.x = -leftViewWidth / 2
        $0.layer.zPosition = 2000
    }
    
    private var leftPanGesture: UIPanGestureRecognizer?
    private var leftTapGesture: UITapGestureRecognizer?
    
    internal var isLeftPanGestureEnabled = true {
        didSet {
            if isLeftPanGestureEnabled {
                prepareLeftPanGesture()
            } else {
                removeLeftPanGesture()
            }
        }
    }
    
    internal var isLeftTapGestureEnabled = true {
        didSet {
            if isLeftTapGestureEnabled {
                prepareLeftTapGesture()
            } else {
                removeLeftTapGesture()
            }
        }
    }
    private var isLeftViewOpened: Bool {
        return leftView.frame.origin.x != -leftViewWidth
    }
    
    private func isPointContainedWithinView(container: UIView, point: CGPoint) -> Bool {
        return container.bounds.contains(point)
    }
    private var isAnimating = false
    private var originalX: CGFloat = 0
    
    internal var leftThreshold: CGFloat = 64
    private var leftViewThreshold: CGFloat = 0
    private func isPointContainedWithinLeftThreshold(point: CGPoint) -> Bool {
        return point.x <= leftThreshold
    }
    
    private let animationDuration: TimeInterval = 0.25
    private var leftViewWidth: CGFloat = 0
    
    // MARK: - initializer
    init(rootViewController: UINavigationController, leftViewController: NewLeftViewController) {
        self.rootViewController = rootViewController
        self.leftViewController = leftViewController
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutSubviews()
    }
    
    private func layoutSubviews() {
        leftView.frame.size.width = leftViewWidth
        leftView.frame.size.height = view.bounds.height
        leftViewThreshold = leftViewWidth / 2
        
        leftViewController.view.frame = leftView.bounds
        leftViewController.view.frame.size.width = leftViewWidth
        
        rootViewController.view.frame = container.bounds
    }
    
    // MARK: - life cycle
    
    override func loadView() {
        super.loadView()
        prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rootViewController.beginAppearanceTransition(true, animated: animated)
        leftViewController.beginAppearanceTransition(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rootViewController.endAppearanceTransition()
        leftViewController.endAppearanceTransition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        rootViewController.beginAppearanceTransition(false, animated: animated)
        leftViewController.beginAppearanceTransition(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        rootViewController.endAppearanceTransition()
        leftViewController.endAppearanceTransition()
    }
    
    // MARK: - prepare
    
    private func prepare() {
        prepare(viewController: rootViewController, in: container)
                
        view.addSubview(container)
        
        // content
        contentViewController.view.backgroundColor = .black
        prepare(viewController: contentViewController, in: view)
        view.sendSubviewToBack(contentViewController.view)
        
        // leftView
        view.addSubview(leftView)
        
        prepare(viewController: leftViewController, in: leftView)
    }
    
    private func prepare(viewController: UIViewController, in container: UIView) {
        addChild(viewController)
        container.addSubview(viewController.view)
        
        viewController.didMove(toParent: self)
        viewController.view.frame = container.bounds
        viewController.view.clipsToBounds = true
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.view.contentScaleFactor = UIScreen.main.scale
    }
    
    // MARK: - PanGestureAction
    private func prepareLeftPanGesture() {
        guard nil == leftPanGesture else { return }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleLeftViewPanGesture(recognizer:)))
        leftPanGesture = panGesture
        leftPanGesture?.delegate = self
        leftPanGesture?.cancelsTouchesInView = false
        
        view.addGestureRecognizer(panGesture)
    }
    
    private func prepareLeftTapGesture() {
        guard nil == leftTapGesture else { return }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLeftViewTapGesture(recognizer:)))
        leftTapGesture = tapGesture
        leftTapGesture?.delegate = self
        leftTapGesture?.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tapGesture)
    }
    
    private func removeLeftViewGestures() {
        removeLeftPanGesture()
        removeLeftTapGesture()
    }
    
    /// Removes the left pan gesture.
    private func removeLeftPanGesture() {
        guard let v = leftPanGesture else { return }
        
        view.removeGestureRecognizer(v)
        leftPanGesture = nil
    }
    
    /// Removes the left tap gesture.
    private func removeLeftTapGesture() {
        guard let _leftTapGesture = leftTapGesture else { return }
        
        view.removeGestureRecognizer(_leftTapGesture)
        leftTapGesture = nil
    }
    
    // MARK: - setView Action
    
    private func closeLeftView(velocity: CGFloat = 0) {
        guard !isAnimating else { return }
        
        isAnimating = true
        
        // willClose
        
        UIView.animate(
            withDuration: TimeInterval(0 == velocity ? animationDuration : fmax(0.1, fmin(1, Double(leftView.frame.origin.x / velocity)))),
            animations: { [weak self, leftView = leftView] in
                leftView.layer.position.x = -leftView.bounds.width / 2
                self?.rootViewController.view.alpha = 1
                
            }) { [weak self] _ in
                
            self?.leftView.isHidden = true
            
            self?.isAnimating = false
            self?.isUserInteractionEnabled = true
            // didClose
        }
    }
    
    private func openLeftView(velocity: CGFloat = 0) {
        guard !isAnimating else { return }
        
        isAnimating = true
        leftView.isHidden = false
        isUserInteractionEnabled = false
        
        // willClose
        
        UIView.animate(
            withDuration: TimeInterval(0 == velocity ? animationDuration : fmax(0.1, fmin(1, Double(leftView.frame.origin.x / velocity)))),
            animations: { [weak self, leftView = leftView] in
                leftView.layer.position.x = leftView.bounds.width / 2
                self?.rootViewController.view.alpha = 0.5
                
            }) { [weak self] _ in
            
            self?.isAnimating = false
            // didClose
        }
    }
    
    private func removeViewController(viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    // MARK: - Action
    
    @objc private func handleLeftViewTapGesture(recognizer: UITapGestureRecognizer) {
        guard isLeftViewOpened && !isPointContainedWithinView(container: leftView, point: recognizer.location(in: leftView))
        else { return }
        
        closeLeftView()
    }
    
    @objc private func handleLeftViewPanGesture(recognizer: UIPanGestureRecognizer) {
        guard isLeftViewOpened || isPointContainedWithinLeftThreshold(point: recognizer.location(in: view))
        else { return }
        
        switch recognizer.state {
        case .began:
            originalX = leftView.layer.position.x
            leftView.isHidden = false
            
        case .changed:
            let w = leftView.bounds.width
            let translationX = recognizer.translation(in: leftView).x
            
            leftView.layer.position.x = originalX + translationX > (w / 2) ? (w / 2) : originalX + translationX
            
            let a = 1 - leftView.layer.position.x / leftView.bounds.width
            rootViewController.view.alpha = 0.5 < a && leftView.layer.position.x <= leftView.bounds.width / 2 ? a : 0.5

        case .ended, .cancelled, .failed:
            let p = recognizer.velocity(in: recognizer.view)
            let x = p.x >= 1000 || p.x <= -1000 ? p.x : 0
            
            if leftView.frame.origin.x <= -leftViewWidth + leftViewThreshold || x < -1000 {
                closeLeftView(velocity: x)
            } else {
                openLeftView(velocity: x)
            }
            
        default:
            break
        }
    }
}

// MARK: - UIGestrue Recognizer Delegate
extension LeftDrawerController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if gestureRecognizer == leftPanGesture
            && (isLeftViewOpened || isPointContainedWithinLeftThreshold(point: touch.location(in: view))) {
            return true
            
        } else if isLeftViewOpened && gestureRecognizer == leftTapGesture {
            return true
        }
        
        return false
    }
    
}

// MARK: - Delegate
extension LeftDrawerController: LeftDrawerDelegate {
    func openLeftView(_ completion: (() -> Void)?) {
        self.isLeftPanGestureEnabled = true
        self.isLeftTapGestureEnabled = true
        self.openLeftView()
        completion?()
    }
    
    func closeLeftView(_ completion: (() -> Void)?) {
        self.isLeftPanGestureEnabled = false
        self.isLeftTapGestureEnabled = false
        self.closeLeftView()
        completion?()
    }
}

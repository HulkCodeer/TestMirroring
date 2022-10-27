//
//  LeftDrawerController.swift
//  evInfra
//
//  Created by youjin kim on 2022/10/17.
//  Copyright © 2022 soft-berry. All rights reserved.
//
// Material NavigationDrawerController 참고.

import UIKit

final class LeftDrawerController: UIViewController {
    private lazy var contentViewController = UIViewController()
    private var mainViewController: UINavigationController {
        didSet {
            guard oldValue != mainViewController else { return }
            
            removeViewController(viewController: oldValue)
            prepare(viewController: mainViewController, in: container)
            
            mainViewController.didMove(toParent: self)
            mainViewController.view.frame = container.bounds
            mainViewController.view.clipsToBounds = true
            mainViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            mainViewController.view.contentScaleFactor = UIScreen.main.scale
            
        }
    }
    private var menuViewController: NewLeftViewController
    
    internal var isUserInteractionEnabled: Bool {
        get {
            return mainViewController.view.isUserInteractionEnabled
        }
        set(value) {
            mainViewController.view.isUserInteractionEnabled = value
        }
    }
    
    private lazy var container = UIView().then {
        $0.frame = view.bounds
        $0.clipsToBounds = true
        $0.contentScaleFactor = UIScreen.main.scale
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private lazy var menuView = UIView().then {
        let leftViewWidth: CGFloat = .phone == UIDevice.current.userInterfaceIdiom ? 280 : 320
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
        return menuView.frame.origin.x != -leftViewWidth
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
    init() {
        let mainReactor = MainReactor(provider: RestApi())
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(ofType: MainViewController.self)
        mainVC.reactor = mainReactor

        let menuReactor = LeftViewReactor(provider: RestApi())
        
        self.mainViewController = UINavigationController(rootViewController: mainVC)
        self.menuViewController = NewLeftViewController(reactor: menuReactor)
        
        super.init(nibName: nil, bundle: nil)
        
        GlobalDefine.shared.mainNavi = mainViewController
        GlobalDefine.shared.rootVC = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutSubviews()
    }
    
    private func layoutSubviews() {
        menuView.frame.size.width = leftViewWidth
        menuView.frame.size.height = view.bounds.height
        leftViewThreshold = leftViewWidth / 2
        
        menuViewController.view.frame = menuView.bounds
        menuViewController.view.frame.size.width = leftViewWidth
        
        mainViewController.view.frame = container.bounds
    }
    
    // MARK: - life cycle
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = Colors.backgroundPrimary.color
        mainViewController.view.backgroundColor = Colors.backgroundPrimary.color
        
        prepare(viewController: rootViewController, in: container)
                
        view.addSubview(container)
        
        // content
        contentViewController.view.backgroundColor = .black
        prepare(viewController: contentViewController, in: view)
        view.sendSubviewToBack(contentViewController.view)
        
        // leftView
        view.addSubview(leftView)
        GlobalDefine.shared.mainViewcon?.view.addSubview(menuView)
        
        prepare(viewController: leftViewController, in: leftView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainViewController.beginAppearanceTransition(true, animated: animated)
        menuViewController.beginAppearanceTransition(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainViewController.endAppearanceTransition()
        menuViewController.endAppearanceTransition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainViewController.beginAppearanceTransition(false, animated: animated)
        menuViewController.beginAppearanceTransition(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mainViewController.endAppearanceTransition()
        menuViewController.endAppearanceTransition()
    }
    
    // MARK: - prepare

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
    
    // MARK: Action
    
    func showLeftView(_ isShow: Bool, completion: (() -> Void)? = nil) {
        self.isLeftPanGestureEnabled = isShow
        self.isLeftTapGestureEnabled = isShow
        
        if isShow {
            self.openLeftView()
        } else {
            self.closeLeftView()
        }
        
        completion?()
    }
    
    // MARK: - private Action
    
    private func closeLeftView(velocity: CGFloat = 0) {
        guard !isAnimating else { return }
        
        isAnimating = true
        
        // willClose
        
        UIView.animate(
            withDuration: TimeInterval(0 == velocity ? animationDuration : fmax(0.1, fmin(1, Double(menuView.frame.origin.x / velocity)))),
            animations: { [weak self, leftView = menuView] in
                leftView.layer.position.x = -leftView.bounds.width / 2
                self?.mainViewController.view.alpha = 1
                
            }) { [weak self] _ in
                
            self?.menuView.isHidden = true
            
            self?.isAnimating = false
            self?.isUserInteractionEnabled = true
            // didClose
        }
    }
    
    private func openLeftView(velocity: CGFloat = 0) {
        guard !isAnimating else { return }
        
        isAnimating = true
        menuView.isHidden = false
        isUserInteractionEnabled = false
        
        // willClose
        
        UIView.animate(
            withDuration: TimeInterval(0 == velocity ? animationDuration : fmax(0.1, fmin(1, Double(menuView.frame.origin.x / velocity)))),
            animations: { [weak self, leftView = menuView] in
                leftView.layer.position.x = leftView.bounds.width / 2
                self?.mainViewController.view.alpha = 0.5
                
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
        
    @objc private func handleLeftViewTapGesture(recognizer: UITapGestureRecognizer) {
        guard isLeftViewOpened && !isPointContainedWithinView(container: menuView, point: recognizer.location(in: menuView))
        else { return }
        
        closeLeftView()
    }
    
    @objc private func handleLeftViewPanGesture(recognizer: UIPanGestureRecognizer) {
        guard isLeftViewOpened || isPointContainedWithinLeftThreshold(point: recognizer.location(in: view))
        else { return }
        
        switch recognizer.state {
        case .began:
            originalX = menuView.layer.position.x
            menuView.isHidden = false
            
        case .changed:
            let w = menuView.bounds.width
            let translationX = recognizer.translation(in: menuView).x
            
            menuView.layer.position.x = originalX + translationX > (w / 2) ? (w / 2) : originalX + translationX
            
            let a = 1 - menuView.layer.position.x / menuView.bounds.width
            mainViewController.view.alpha = 0.5 < a && menuView.layer.position.x <= menuView.bounds.width / 2 ? a : 0.5

        case .ended, .cancelled, .failed:
            let p = recognizer.velocity(in: recognizer.view)
            let x = p.x >= 1000 || p.x <= -1000 ? p.x : 0
            
            if menuView.frame.origin.x <= -leftViewWidth + leftViewThreshold || x < -1000 {
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

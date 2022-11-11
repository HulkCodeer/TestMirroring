//
//  TransitionController.swift
//  evInfra
//
//  Created by 박현진 on 2022/10/31.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

internal class TransitionController: UIViewController {
    
    internal var isUserInteractionEnabled: Bool {
        get {
            return rootViewController.view.isUserInteractionEnabled
        }
        set(value) {
            rootViewController.view.isUserInteractionEnabled = value
        }
    }
    
    private let container = UIView()
    
    internal var rootViewController: UIViewController! {
        didSet {
            guard oldValue != rootViewController else {
                return
            }
            
            if let v = oldValue {
                removeViewController(viewController: v)
            }
            
            prepare(viewController: rootViewController, in: container)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    internal init(rootViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.rootViewController = rootViewController
    }
    
    internal override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rootViewController.beginAppearanceTransition(true, animated: animated)
    }
    
    internal override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rootViewController.endAppearanceTransition()
    }
    
    internal override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        rootViewController.beginAppearanceTransition(false, animated: animated)
    }
    
    internal override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        rootViewController.endAppearanceTransition()
    }
    
    internal func prepare() {
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.contentScaleFactor = UIScreen.main.scale
        
        prepareContainer()
        
        guard let v = rootViewController else {
            return
        }
        
        prepare(viewController: v, in: container)
    }
}

internal extension TransitionController {
    func prepareContainer() {
        container.frame = view.bounds
        container.clipsToBounds = true
        container.contentScaleFactor = UIScreen.main.scale
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(container)
    }
    
    func prepare(viewController: UIViewController, in container: UIView) {
        addChild(viewController)
        container.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        viewController.view.frame = container.bounds
        viewController.view.clipsToBounds = true
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.view.contentScaleFactor = UIScreen.main.scale
    }
}

internal extension TransitionController {
    func removeViewController(viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}



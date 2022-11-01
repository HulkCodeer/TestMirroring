//
//  MainNavigationController.swift
//  evInfra
//
//  Created by 박현진 on 2022/10/31.
//  Copyright © 2022 soft-berry. All rights reserved.
//

internal final class MainNavigationController: UINavigationController {
    
    fileprivate var duringPushAnimation = false

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setViewControllers([rootViewController], animated: false)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    private func setup() {
        GlobalDefine.shared.mainNavi = self
        self.delegate = self
        self.interactivePopGestureRecognizer?.delegate = self
        self.navigationItem.backBarButtonItem?.isEnabled = false
        self.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(true, animated: false)
        self.setup()
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        self.duringPushAnimation = true
        super.pushViewController(viewController, animated: animated)
    }
}

extension MainNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow _: UIViewController, animated _: Bool) {
        guard let swipeNavigationController = navigationController as? MainNavigationController else { return }
        swipeNavigationController.duringPushAnimation = false
    }
}

extension MainNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == interactivePopGestureRecognizer else {
            return true // default value
        }
        return self.viewControllers.count > 1 && self.duringPushAnimation == false
    }
}

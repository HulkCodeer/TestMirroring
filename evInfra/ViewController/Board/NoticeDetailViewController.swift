//
//  NoticeDetailViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 20..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
import Motion
import SwiftyJSON

class NoticeDetailViewController: UIViewController {
    @IBOutlet weak var pageView: UIView!
    var boardList: JSON!
    var noticeIndex: Int!
    var pageController:UIPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageController?.delegate = self
        self.pageController?.dataSource = self
        
        let startingViewController: NoticeContentViewController = self.viewControllerAtIndex(index: self.noticeIndex)!
        let viewControllers: Array = [startingViewController]
        self.pageController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
        self.addChildViewController(self.pageController!)
        self.pageView.addSubview(self.pageController!.view)
        
        let pageViewRect = self.pageView.bounds
        self.pageController!.view.frame = pageViewRect
        self.pageController!.didMove(toParentViewController: self)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onClickBackBtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension NoticeDetailViewController {
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = self.boardList.arrayValue[self.noticeIndex]["subject"].stringValue
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    func viewControllerAtIndex(index:Int) -> NoticeContentViewController? {
        
        let vc : NoticeContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "NoticeContentViewController") as! NoticeContentViewController
        
        vc.pageIndex = index
        vc.noticeContent = self.boardList.arrayValue[index]["content"].stringValue
        return vc
    }
}

extension NoticeDetailViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! NoticeContentViewController
        var index = vc.pageIndex as Int
        
        if( index == 0 || index == NSNotFound) {
            return nil
        }
        index = index - 1
        
        return self.viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! NoticeContentViewController
        
        var index = vc.pageIndex as Int
        if( index == NSNotFound) {
            return nil
        }
        
        index = index + 1
        if (index == self.boardList.arrayValue.count) {
            return nil
        }
        
        return self.viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentViewController = pageViewController.viewControllers![0] as? NoticeContentViewController {
                navigationItem.titleLabel.text = self.boardList.arrayValue[currentViewController.pageIndex]["subject"].stringValue
            }
        }
    }
}

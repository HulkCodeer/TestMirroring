//
//  OfferwallViewController.swift
//  evInfra
//
//  Created by Michael Lee on 2020/01/30.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import UIKit
import Material

class OfferwallViewController: UIViewController, AdPopcornOfferwallDelegate{
    
    @IBOutlet weak var offerwallContainer: UIView!
    override func viewDidLoad() {
        prepareActionBar();
        
        AdPopcornOfferwall.setUserId(MemberManager.getMemberId());
        prepareView();
    }
    
    @objc fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "베리 충전"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareView() {
        // 오퍼월 테마 색상 변경
        AdPopcornStyle.sharedInstance().adPopcornCustomThemeColor = UIColor(hexString:"#472a2bff");

        // 오퍼월 로고 변경
        AdPopcornStyle.sharedInstance().adPopcornCustomOfferwallTitleLogoPath = nil

        // 오퍼월 타이틀 변경
        AdPopcornStyle.sharedInstance().adPopcornCustomOfferwallTitle = "베리 충전소";

        // 오퍼월 타이틀 색상 변경
        AdPopcornStyle.sharedInstance().adPopcornCustomOfferwallTitleColor = UIColor.red;

        // 오퍼월 Top/bottom bar 색상 변경
        //AdPopcornStyle.sharedInstance().adPopcornCustomOfferwallTitleBackgroundColor = UIColor.white;
        
        let adPopcornVC:AdPopcornAdListViewController = AdPopcornAdListViewController();
        adPopcornVC.setViewModeWidthSize(self.offerwallContainer.bounds.width);
        adPopcornVC.setViewModeHeightSize(self.offerwallContainer.bounds.height);
        
        self.addChildViewController(adPopcornVC);
        
        self.offerwallContainer.addSubview(adPopcornVC.view);
        
        adPopcornVC.setViewModeImpression();
    }
}

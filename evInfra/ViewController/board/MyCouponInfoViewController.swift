//
//  MyCouponInfoViewController.swift
//  evInfra
//
//  Created by 이신광 on 06/11/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import UIKit
import Material
import WebKit

class MyCouponInfoViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    var couponId = 0
    
    override func loadView() {
        super.loadView()
        
        webView = WKWebView(frame: view.frame)
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = true
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareActionBar()
        prepareWebView()
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "쿠폰 정보"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareWebView() {
        let mbId = MemberManager.getMbId()
        let params = "mb_id=\(mbId)&coupon_id=\(couponId)"
        
        var request = URLRequest(url: URL(string: Const.EV_SERVER_IP + "/event/couponInfo.do")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = params.data(using: .utf8)
        
        webView.load(request)
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
}

//
//  TermsViewController.swift
//  evInfra
//
//  Created by zenky on 2018. 4. 16..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
import WebKit

class TermsViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    enum Request {
        case UsingTerms        // 서비스 이용약관
        case PersonalInfoTerms // 개인정보처리방침
        case LocationTerms     // 위치기반서비스 이용약관
        case Licence           // 라이센스
        case Contact           // 제휴문의
        case EvBonusGuide      // 보조금 안내
        case EvBonusStatus     // 보조금 현황
        case Help              // 도움말
        case BusinessInfo      // 사업자정보
    }

    var tabIndex:Request = .UsingTerms
    var webView: WKWebView!

    @IBOutlet weak var fixWebView: UIView!
    @IBOutlet weak var termsTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        loadFromUrl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        super.loadView()
        
        webView = WKWebView(frame: self.view.frame)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = true
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view = webView
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)

        switch tabIndex {
        case .UsingTerms:
            navigationItem.titleLabel.text = "서비스 이용약관"
            
        case .PersonalInfoTerms:
            navigationItem.titleLabel.text = "개인정보 취급방침"
            
        case .LocationTerms:
            navigationItem.titleLabel.text = "위치기반서비스 이용약관"
            
        case .Licence:
            navigationItem.titleLabel.text = "라이센스"
            
        case .Contact:
            navigationItem.titleLabel.text = "제휴문의"
            
        case .EvBonusGuide:
            navigationItem.titleLabel.text = "보조금 안내"
            
        case .EvBonusStatus:
            navigationItem.titleLabel.text = "보조금 현황"
            
        case .Help:
            navigationItem.titleLabel.text = "도움말"
        case .BusinessInfo:
            navigationItem.titleLabel.text = "사업자 정보"
        }
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    func loadFromUrl() {
        var strUrl = "\(Const.EV_SERVER_IP)/terms/termsOfUse"
        switch tabIndex {
        case .UsingTerms:
            strUrl = "\(Const.EV_SERVER_IP)/terms/termsOfUse"
            
        case .PersonalInfoTerms:
            strUrl = "\(Const.EV_SERVER_IP)/terms/termsOfPersonal"
            
        case .LocationTerms:
            strUrl = "\(Const.EV_SERVER_IP)/terms/termsOfLocation"
            
        case .Licence:
            strUrl = "\(Const.EV_SERVER_IP)/terms/termsOfLicense"
            
        case .Contact:
            strUrl = "http://www.soft-berry.com/contact/"
            
        case .EvBonusGuide:
            strUrl = Const.EV_SERVER_IP + "/docs/evBonus"
            
        case .EvBonusStatus:
            strUrl = Const.EV_SERVER_IP + "/docs/bonusDashboard"
            
        case .Help:
            strUrl = Const.EV_SERVER_IP + "/docs/evInfraHelp"
        
        case .BusinessInfo:
            strUrl = Const.EV_SERVER_IP + "/docs/businessInfo"
        }

        let url = NSURL(string:strUrl)
        let request = NSURLRequest(url: url! as URL)
        webView.load(request as URLRequest)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            if let newURL = navigationAction.request.url,
                let host = newURL.host , !host.hasPrefix(Const.EV_SERVER_IP + "/docs/evInfraHelp") &&
                UIApplication.shared.canOpenURL(newURL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(newURL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(newURL)
                }
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}

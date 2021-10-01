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
import JavaScriptCore

class TermsViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    enum Request {
        case Contact           // 제휴문의
        case UsingTerms        // 서비스 이용약관
        case PersonalInfoTerms // 개인정보처리방침
        case LocationTerms     // 위치기반서비스 이용약관
        case MembershipTerms   // 회원카드 이용약관
        case Licence           // 라이센스
        case EvBonusGuide      // 보조금 안내
        case PriceInfo         // 충전요금 안내
        case EvBonusStatus     // 보조금 현황
        case BusinessInfo      // 사업자정보
        case StationPrice      // 충전소 요금정보
        case FAQTop            // FAQ (top10)
    }

    var tabIndex:Request = .UsingTerms
    var subParams:String = ""
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
        
        let uiScreenEdgePan = UIScreenEdgePanGestureRecognizer(target: self, action:  #selector(swipeEvent))
        uiScreenEdgePan.edges = .left
        webView.addGestureRecognizer(uiScreenEdgePan)
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")

        switch tabIndex {
        case .UsingTerms:
            navigationItem.titleLabel.text = "서비스 이용약관"
            
        case .PersonalInfoTerms:
            navigationItem.titleLabel.text = "개인정보 취급방침"
            
        case .LocationTerms:
            navigationItem.titleLabel.text = "위치기반서비스 이용약관"
            
        case .MembershipTerms:
            navigationItem.titleLabel.text = "회원카드 이용약관"
            
        case .Licence:
            navigationItem.titleLabel.text = "라이센스"
            
        case .Contact:
            navigationItem.titleLabel.text = "제휴문의"
            
        case .EvBonusGuide:
            navigationItem.titleLabel.text = "보조금 안내"
            
        case .PriceInfo:
            navigationItem.titleLabel.text = "충전요금 안내"
            
        case .EvBonusStatus:
            navigationItem.titleLabel.text = "보조금 현황"
            
        case .BusinessInfo:
            navigationItem.titleLabel.text = "사업자 정보"
        case .StationPrice:
            navigationItem.titleLabel.text = "충전소 가격정보"
        case .FAQTop:
            navigationItem.titleLabel.text = "자주묻는 질문"
        }
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        backKeyEvent()
    }
    
    @objc
    func swipeEvent(_ recogniger : UIScreenEdgePanGestureRecognizer) {
        if recogniger.state == .recognized {
            backKeyEvent()
        }
    }
    
    @objc func backKeyEvent() {
        if webView.canGoBack {
            webView.goBack()
        }else{
            self.navigationController?.pop()
        }
    }
    
    
    func loadFromUrl() {
        var strUrl = Const.EV_PAY_SERVER + "/terms/term/service_use"
        switch tabIndex {
        case .Contact:
            strUrl = "http://www.soft-berry.com/contact/"
            
        case .UsingTerms:
            strUrl = Const.EV_PAY_SERVER + "/terms/term/service_use"
        
        case .PersonalInfoTerms:
            strUrl = Const.EV_PAY_SERVER + "/terms/term/privacy_policy"
        
        case .LocationTerms:
            strUrl = Const.EV_PAY_SERVER + "/terms/term/service_location"
            
        case .MembershipTerms:
            strUrl = Const.EV_PAY_SERVER + "/terms/term/membership"
        
        case .Licence:
            strUrl = Const.EV_PAY_SERVER + "/terms/term/license"
        
        case .EvBonusGuide:
            strUrl = Const.EV_PAY_SERVER + "/docs/info/subsidy_guide"
            
        case .PriceInfo:
            strUrl = Const.EV_PAY_SERVER + "/docs/info/charge_price_info"
        
        case .EvBonusStatus:
            strUrl = Const.EV_PAY_SERVER + "/docs/info/subsidy_status"
        
        case .BusinessInfo:
            strUrl = Const.EV_PAY_SERVER + "/docs/info/business_info"
            
        case .StationPrice:
            strUrl = Const.EV_PAY_SERVER + "/docs/info/charge_price_info"
        case .FAQTop:
            strUrl = Const.EV_PAY_SERVER + "/docs/info/faq_main"
        }

        if subParams.isEmpty {
            let url = NSURL(string:strUrl)
            let request = NSURLRequest(url: url! as URL)
            webView.load(request as URLRequest)
        } else {
            let url = NSURL(string:strUrl)
            var request = URLRequest(url: url! as URL)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded",
                forHTTPHeaderField: "Content-Type")
            request.httpBody = subParams.data(using: .utf8)
            webView.load(request as URLRequest)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType == .linkActivated  {
            if let newURL = navigationAction.request.url,
                let host = newURL.host , !host.hasPrefix(Const.EV_PAY_SERVER + "/docs/info/ev_infra_help") &&
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

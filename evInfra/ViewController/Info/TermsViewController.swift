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
import SwiftyJSON

internal class TermsViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
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
        case FAQDetail         // FAQ detail page
        case BatteryInfo       // SK Battery
    }

    var tabIndex:Request = .UsingTerms
    var subParams:String = "" // POST parameter
    var subURL:String = "" // GET parameter
    var header: [String: String] = ["Content-Type":"application/x-www-form-urlencoded"]
    var webView: WKWebView!

    @IBOutlet weak var fixWebView: UIView!
    @IBOutlet weak var termsTitle: UILabel!
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        loadFromUrl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        webView.autoresizingMask = [.flexibleHeight]
        webView.allowsBackForwardNavigationGestures = true
        
        self.view = webView
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
//            self.title = "서비스 이용약관 화면"
        case .PersonalInfoTerms:
            navigationItem.titleLabel.text = "개인정보 취급방침"
//            self.title = "개인정보 취급방침 화면"
        case .LocationTerms:
            navigationItem.titleLabel.text = "위치기반서비스 이용약관"
//            self.title = "위치기반서비스 이용약관 화면"
        case .MembershipTerms:
            navigationItem.titleLabel.text = "회원카드 이용약관"
//            self.title = "회원카드 이용약관 화면"
        case .Licence:
            navigationItem.titleLabel.text = "라이센스"
//            self.title = "라이센스 화면"
        case .Contact:
            navigationItem.titleLabel.text = "제휴문의"
//            self.title = "제휴문의 화면"
        case .EvBonusGuide:
            navigationItem.titleLabel.text = "보조금 안내"
//            self.title = "보조금 안내 화면"
        case .PriceInfo:
            navigationItem.titleLabel.text = "충전요금 안내"
//            self.title = "충전요금 안내 화면"
        case .EvBonusStatus:
            navigationItem.titleLabel.text = "보조금 현황"
//            self.title = "보조금 현황 화면"
        case .BusinessInfo:
            navigationItem.titleLabel.text = "사업자 정보"
//            self.title = "사업자 정보 화면"
        case .StationPrice:
            navigationItem.titleLabel.text = "충전소 가격정보"
//            self.title = "충전소 가격정보 화면"
        case .FAQDetail, .FAQTop:
            navigationItem.titleLabel.text = "자주묻는 질문"
//            self.title = "자주묻는 질문 화면"
        case .BatteryInfo:
            navigationItem.titleLabel.text = "내 차 배터리 관리"
//            self.title = "내 차 배터리 관리 화면"
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
    
    
    public func setHeader(key: String, value: String) {
        header[key] = value
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
            AmplitudeManager.shared.createEventType(type: MapEvent.viewChargingPriceInfo)
                .logEvent()
            
        case .EvBonusStatus:
            strUrl = Const.EV_PAY_SERVER + "/docs/info/subsidy_status"
        
        case .BusinessInfo:
            strUrl = Const.EV_PAY_SERVER + "/docs/info/business_info"
            
        case .StationPrice:
            strUrl = Const.EV_PAY_SERVER + "/docs/info/charge_price_info"
            
        case .FAQTop:
            strUrl = Const.EV_PAY_SERVER + "/docs/info/faq_main"
            
        case .FAQDetail:
            strUrl = Const.EV_PAY_SERVER + "/docs/info/faq_detail"
        
        case .BatteryInfo:
            strUrl = Const.SK_BATTERY_SERVER
            let contentController = webView.configuration.userContentController
            contentController.add(self, name: "BaaSWebHandler")
        }

        loadWebView(webUrl: strUrl)
    }
    
    func loadWebView(webUrl: String) {
        var strUrl = webUrl
        
        if !subURL.isEmpty {
            strUrl = strUrl + "?" + subURL
        }
        
        guard let _url = NSURL(string:strUrl) else {
            navigationController?.pop()
            return
        }
        
        var request = URLRequest(url: _url as URL)
        
        if !header.isEmpty {
            for (key, value) in header {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        if !subParams.isEmpty {
            request.httpMethod = "POST"
            request.httpBody = subParams.data(using: .utf8)
        }
        webView.load(request as URLRequest)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType == .linkActivated  {
            if let newURL = navigationAction.request.url,
                let host = newURL.host , !host.hasPrefix(Const.EV_PAY_SERVER + "/docs/info/ev_infra_help") &&
                UIApplication.shared.canOpenURL(newURL) {
                if host.hasPrefix("com.soft-berry.ev-infra") { // deeplink
                    if #available(iOS 13.0, *) {                        
                        DeepLinkPath.sharedInstance.linkPath = newURL.path
                        if let component = URLComponents(url: newURL, resolvingAgainstBaseURL: false) {
                            DeepLinkPath.sharedInstance.linkParameter = component.queryItems
                        }
                        DeepLinkPath.sharedInstance.runDeepLink()
                    } else {
                        UIApplication.shared.open(newURL, options: [:], completionHandler: nil)
                    }
                } else {
                    UIApplication.shared.open(newURL, options: [:], completionHandler: nil)
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
extension TermsViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "BaaSWebHandler", let messageBody = message.body as? String {
            if let dataFromString = messageBody.data(using: .utf8, allowLossyConversion: false) {
                if let json = try? JSON(data: dataFromString) {
                    let method = json["method"].stringValue
                    if method == "goBack" {
                        self.navigationController?.pop()
                    }
                }
            }
        }
    }
}

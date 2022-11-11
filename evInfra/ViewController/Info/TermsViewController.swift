//
//  TermsViewController.swift
//  evInfra
//
//  Created by zenky on 2018. 4. 16..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore
import SwiftyJSON

internal class TermsViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    enum Request {
        case Contact           // 제휴문의
        case UsingTerms        // 서비스 이용약관
        case PersonalInfoTerms // 개인정보 처리방침
        case LocationTerms     // 위치기반서비스 이용약관
        case MembershipTerms   // 회원카드 이용약관
        case Licence           // 라이센스
        case EvBonusGuide      // 보조금 안내
        case priceInfo         // 충전요금 안내
        case EvBonusStatus     // 보조금 현황
        case BusinessInfo      // 사업자정보
        case StationPrice      // 충전소 요금정보
        case faqTop            // FAQ (top10)
        case faqDetail         // FAQ detail page
        case BatteryInfo       // SK Battery
    }

    private lazy var customNaviBar = CommonNaviView()
    
    var tabIndex:Request = .UsingTerms
    var subParams:String = "" // POST parameter
    var subURL:String = "" // GET parameter
    var header: [String: String] = ["Content-Type":"application/x-www-form-urlencoded"]
    private lazy var webView = WKWebView().then {
        $0.uiDelegate = self
        $0.navigationDelegate = self
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.autoresizingMask = [.flexibleHeight]
        $0.allowsBackForwardNavigationGestures = true
        
    }

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
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.view.naviBarHeight)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func prepareActionBar() {
        navigationController?.isNavigationBarHidden = true
        
        customNaviBar.backClosure = {
            if self.webView.canGoBack {
                self.webView.goBack()
            } else {
                GlobalDefine.shared.mainNavi?.pop()
            }
        }
        view.addSubview(customNaviBar)
        customNaviBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
        
        switch tabIndex {
        case .UsingTerms:
            customNaviBar.naviTitleLbl.text = "서비스 이용약관"
        case .PersonalInfoTerms:
            customNaviBar.naviTitleLbl.text = "개인정보 처리방침"
        case .LocationTerms:
            customNaviBar.naviTitleLbl.text = "위치기반서비스 이용약관"
        case .MembershipTerms:
            customNaviBar.naviTitleLbl.text = "회원카드 이용약관"
        case .Licence:
            customNaviBar.naviTitleLbl.text = "라이센스"
        case .Contact:
            customNaviBar.naviTitleLbl.text = "제휴문의"
        case .EvBonusGuide:
            customNaviBar.naviTitleLbl.text = "보조금 안내"
        case .priceInfo:
            customNaviBar.naviTitleLbl.text = "충전요금 안내"
        case .EvBonusStatus:
            customNaviBar.naviTitleLbl.text = "보조금 현황"
        case .BusinessInfo:
            customNaviBar.naviTitleLbl.text = "사업자 정보"
        case .StationPrice:
            customNaviBar.naviTitleLbl.text = "충전소 가격정보"
        case .faqDetail, .faqTop:
            customNaviBar.naviTitleLbl.text = "자주묻는 질문"
        case .BatteryInfo:
            customNaviBar.naviTitleLbl.text = "내 차 배터리 관리"
        }
        
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
            strUrl = "\(Const.EV_PAY_SERVER)/docs/info/partnership_info_v3"
            
        case .UsingTerms:
            strUrl = "\(Const.EV_PAY_SERVER)/terms/term/service_use_v3"
        
        case .PersonalInfoTerms:
            strUrl = "\(Const.EV_PAY_SERVER)/terms/term/privacy_policy_v3"
        
        case .LocationTerms:
            strUrl = "\(Const.EV_PAY_SERVER)/terms/term/service_location"
            
        case .MembershipTerms:
            strUrl = "\(Const.EV_PAY_SERVER)/terms/term/membership_v3"
        
        case .Licence:
            strUrl = "\(Const.EV_PAY_SERVER)/terms/term/license_v3"
        
        case .EvBonusGuide:
            strUrl = "\(Const.EV_PAY_SERVER)/docs/info/subsidy_guide"
            
        case .priceInfo:
            strUrl = "\(Const.EV_PAY_SERVER)/docs/info/charge_price_info"
            MapEvent.viewChargingPriceInfo.logEvent()
            
        case .EvBonusStatus:
            strUrl = "\(Const.EV_PAY_SERVER)/docs/info/subsidy_status"
        
        case .BusinessInfo:
            strUrl = "\(Const.EV_PAY_SERVER)/docs/info/business_info_v3"
            
        case .StationPrice:
            strUrl = "\(Const.EV_PAY_SERVER)/docs/info/charge_price_info"
            
        case .faqTop:
            strUrl = "\(Const.EV_PAY_SERVER)/docs/info/faq_main"
            
        case .faqDetail:
            strUrl = "\(Const.EV_PAY_SERVER)/docs/info/faq_detail"
        
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

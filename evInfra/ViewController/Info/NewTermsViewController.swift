//
//  NewTermsViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/06/21.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import WebKit
import JavaScriptCore
import SwiftyJSON

internal final class NewTermsViewController: CommonBaseViewController {
    enum TermsType {
        case contact
        case usingTerms
        case personalInfoTerms
        case locationTerms
        case membershipTerms
        case licence
        case evBonusGuide
        case priceInfo
        case evBonusStatus
        case businessInfo
        case stationPrice
        case faqTop
        case faqDetail
        case skBatteryInfo
        case contents
        case car
        case serviceUse
        case privacyAgree
        case privacyPolicy
        case serviceLocation
        case marketing
        case ad
        
        internal var headerTitle: String {
            switch self {
            case .contact: return "제휴문의"
            case .usingTerms: return "서비스 이용약관"
            case .personalInfoTerms: return "개인정보 취급방침"
            case .locationTerms: return "위치기반서비스 이용약관"
            case .membershipTerms: return "회원카드 이용약관"
            case .licence: return  "라이센스"
            case .evBonusGuide: return "보조금 안내"
            case .priceInfo: return  "충전요금 안내"
            case .evBonusStatus: return "보조금 현황"
            case .businessInfo: return "사업자 정보"
            case .stationPrice: return "충전소 가격정보"
            case .faqTop, .faqDetail: return "자주묻는 질문"
            case .skBatteryInfo: return "내 차 배터리 관리"
            case .marketing: return "홍보 및 마케팅 목적 개인정보 수집 및 이용 동의"
            case .ad: return "광고성 정보 수신 동의"
            case .contents: return "콘텐츠 활용 동의"
            case .car: return "개인정보 수집 및 이용동의(차량정보)"
            case .serviceUse: return "서비스 이용약관"
            case .privacyAgree: return "개인정보 수집 및 이용 동의"
            case .privacyPolicy: return "개인정보처리방침"
            case .serviceLocation: return "위치기반서비스 이용약관"
            }
        }
        
        internal var urlPath: String {
            switch self {
            case .contact: return "http://www.soft-berry.com/contact/"
            case .usingTerms: return "\(Const.EV_PAY_SERVER)/terms/term/service_use"
            case .personalInfoTerms: return "\(Const.EV_PAY_SERVER)/terms/term/privacy_policy_v2"
            case .locationTerms: return "\(Const.EV_PAY_SERVER)/terms/term/service_location"
            case .membershipTerms: return "\(Const.EV_PAY_SERVER)/terms/term/membership"
            case .licence: return  "\(Const.EV_PAY_SERVER)/terms/term/license"
            case .evBonusGuide: return "\(Const.EV_PAY_SERVER)/docs/info/subsidy_guide"
            case .priceInfo: return  "\(Const.EV_PAY_SERVER)/docs/info/charge_price_info"
            case .evBonusStatus: return "\(Const.EV_PAY_SERVER)/docs/info/subsidy_status"
            case .businessInfo: return "\(Const.EV_PAY_SERVER)/docs/info/business_info"
            case .stationPrice: return "\(Const.EV_PAY_SERVER)/docs/info/charge_price_info"
            case .faqTop: return "\(Const.EV_PAY_SERVER)/docs/info/faq_main"
            case .faqDetail: return "\(Const.EV_PAY_SERVER)/docs/info/faq_detail"
            case .skBatteryInfo: return "\(Const.SK_BATTERY_SERVER)"            
            case .marketing: return "\(Const.EV_PAY_SERVER)/terms/term/marketing"
            case .ad: return "\(Const.EV_PAY_SERVER)/terms/term/ad"
            case .contents: return "\(Const.EV_PAY_SERVER)/terms/term/content"
            case .car: return "\(Const.EV_PAY_SERVER)/terms/term/privacy_car"
            case .serviceUse: return "\(Const.EV_PAY_SERVER)/terms/term/service_use"
            case .privacyAgree: return "\(Const.EV_PAY_SERVER)/terms/term/privacy_agree_v2"
            case .privacyPolicy: return "\(Const.EV_PAY_SERVER)/terms/term/privacy_policy_v2"
            case .serviceLocation: return "\(Const.EV_PAY_SERVER)/terms/term/service_location"            
            }
        }
    }
    
    internal var tabIndex: TermsType = .usingTerms
    var subParams:String = "" // POST parameter
    var subURL:String = "" // GET parameter
    var header: [String: String] = ["Content-Type":"application/x-www-form-urlencoded"]
    
    // MARK: UI
    
    private lazy var naviTotalView = CommonNaviView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.naviTitleLbl.text = "회원탈퇴"
    }
    
    private lazy var config = WKWebViewConfiguration().then {
        let contentController = WKUserContentController()
        contentController.add(self, name: "BaaSWebHandler")
        $0.userContentController = contentController
    }
    
    private lazy var webView = WKWebView(frame: CGRect.zero, configuration: self.config).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.navigationDelegate = self
        $0.uiDelegate = self
        $0.allowsBackForwardNavigationGestures = true
    }
        
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(webView)
        webView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviTotalView.backClosure = {
            if self.webView.canGoBack {
                self.webView.goBack()
            }else{
                GlobalDefine.shared.mainNavi?.pop()
            }
        }
        
        naviTotalView.naviTitleLbl.text = tabIndex.headerTitle
        loadWebView(webUrl: tabIndex.urlPath)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
    
    internal func setHeader(key: String, value: String) {
        header[key] = value
    }
    
    fileprivate func loadWebView(webUrl: String) {
        var strUrl = webUrl
        
        if !subURL.isEmpty {
            strUrl = strUrl + "?" + subURL
        }
        
        guard let _url = NSURL(string:strUrl) else {
            GlobalDefine.shared.mainNavi?.pop()
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
}

extension NewTermsViewController: WKNavigationDelegate, WKUIDelegate {
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

extension NewTermsViewController: WKScriptMessageHandler {
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

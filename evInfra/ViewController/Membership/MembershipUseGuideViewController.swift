//
//  MembershipUseGuideViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import WebKit
import RxSwift

internal final class MembershipUseGuideViewController: CommonBaseViewController, WKUIDelegate {
    
    // MARK: UI
    
    private lazy var commonNaviView = CommonNaviView().then {
        $0.naviTitleLbl.text = "EV Pay 카드 사용 안내"
    }
    
    private let config = WKWebViewConfiguration().then {
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        $0.userContentController = contentController
    }
    
    private lazy var webView = WKWebView(frame: CGRect.zero, configuration: self.config).then {
        
        $0.navigationDelegate = self
        $0.uiDelegate = self
    }
        
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
                
        self.contentView.addSubview(commonNaviView)
        commonNaviView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
        
        self.contentView.addSubview(self.webView)
        webView.snp.makeConstraints {
            $0.top.equalTo(commonNaviView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
                                        
        guard let _url = URL(string: "\(Const.EV_PAY_SERVER)/docs/info/membership_card?osType=ios") else {
            return
        }
        let requestUrl = URLRequest(url: _url)
        webView.load(requestUrl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // 추후 딥링크 추가시 필요
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == "evinfra" {
            DeepLinkModel.shared.openSchemeURL(urlstring: url.absoluteString)
        }
        decisionHandler(.allow)
        return
    }
    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//
//        if navigationAction.navigationType == .linkActivated  {
//            if let newURL = navigationAction.request.url,
//                let host = newURL.host, UIApplication.shared.canOpenURL(newURL) {
//                if host.hasPrefix("com.soft-berry.ev-infra") { // deeplink
//                    if #available(iOS 13.0, *) {
//                        DeepLinkPath.sharedInstance.linkPath = newURL.path
//                        if let component = URLComponents(url: newURL, resolvingAgainstBaseURL: false) {
//                            DeepLinkPath.sharedInstance.linkParameter = component.queryItems
//                        }
//                        DeepLinkPath.sharedInstance.runDeepLink()
//                    } else {
//                        UIApplication.shared.open(newURL, options: [:], completionHandler: nil)
//                    }
//                } else {
//                    UIApplication.shared.open(newURL, options: [:], completionHandler: nil)
//                }
//                decisionHandler(.cancel)
//            } else {
//                decisionHandler(.allow)
//            }
//        } else {
//            decisionHandler(.allow)
//        }
//    }
}

extension MembershipUseGuideViewController: UIWebViewDelegate {
}

extension MembershipUseGuideViewController: WKNavigationDelegate {
    
}

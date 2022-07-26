//
//  MembershipUseGuideViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import WebKit
import RxSwift

internal final class MembershipUseGuideViewController: BaseViewController, WKUIDelegate {
    
    // MARK: UI
    
    private let config = WKWebViewConfiguration().then {
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        $0.userContentController = contentController
    }
    
    private lazy var webView = WKWebView(frame: CGRect.zero, configuration: self.config).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.navigationDelegate = self
        $0.uiDelegate = self
    }
        
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        prepareActionBar(with: "회원카드 사용 안내")
                        
        view.addSubview(self.webView)
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
                                        
        guard let _url = URL(string: "\(Const.EV_PAY_SERVER)/docs/info/membership_card?osType=ios") else {
            return
        }
        let requestUrl = URLRequest(url: _url)
        webView.load(requestUrl)
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

//
//  MembershipUseGuideViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import WebKit
import RxSwift

internal final class MembershipUseGuideViewController: BaseViewController {
    
    // MARK: UI
    
    private let config = WKWebViewConfiguration().then {
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        $0.userContentController = contentController
    }
    
    private lazy var webView = WKWebView(frame: CGRect.zero, configuration: self.config).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
        
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        prepareActionBar(with: "회원카드 사용 안내")
                        
        view.addSubview(self.webView)
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
                                        
        guard let _url = URL(string: "\(Const.EV_PAY_SERVER)/docs/info/membership_card") else {
            return
        }
        let requestUrl = URLRequest(url: _url)
        webView.load(requestUrl)
    }
}

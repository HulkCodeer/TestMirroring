//
//  RentalInfoManageViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/10.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import WebKit
import Then

internal final class MemberGuideViewController: UIViewController {
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
    
    private lazy var membershipRegisterBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("회원카드 만들기", for: .normal)
        $0.titleLabel?.textColor = UIColor(named: "nt-9")
    }
    
    private lazy var arrowImgView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icon_arrow_right_lg")
        $0.tintColor = UIColor(named: "content-primary")
    }
    
    override func loadView() {
        super.loadView()
        
        prepareActionBar(with: "회원카드 안내")
        
        view.addSubview(self.webView)
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(self.membershipRegisterBtn)
        membershipRegisterBtn.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        membershipRegisterBtn.addSubview(self.arrowImgView)
        arrowImgView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(self.membershipRegisterBtn.snp.centerY)
            $0.width.height.equalTo(32)
        }
        
        guard let _url = URL(string: "\(Const.EV_PAY_SERVER)/docs/info/membership_info") else {
            return
        }
        let requestUrl = URLRequest(url: _url)
        webView.load(requestUrl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}

extension MemberGuideViewController: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {}
}


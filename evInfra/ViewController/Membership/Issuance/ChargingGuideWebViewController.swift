//
//  ChargingGuideWebViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/10/31.
//  Copyright © 2022 soft-berry. All rights reserved.
//


import WebKit
import Then
import RxSwift

internal final class ChargingGuideWebViewController: CommonBaseViewController {
    
    // MARK: VARIABLE
    
    internal let disposebag = DisposeBag()
            
    // MARK: UI
    
    private lazy var naviTotalView = CommonNaviView().then {
        $0.naviTitleLbl.text = "수령 전 충전안내"
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
        
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
                       
        view.addSubview(self.webView)
        webView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
            
        guard let _url = URL(string: "\(Const.EI_FILE_SERVER)/info/charge_before_arrival.html") else {
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
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = false
    }
}

extension ChargingGuideWebViewController: WKUIDelegate {
    
}

extension ChargingGuideWebViewController: UIWebViewDelegate {
}

extension ChargingGuideWebViewController: WKNavigationDelegate {
}


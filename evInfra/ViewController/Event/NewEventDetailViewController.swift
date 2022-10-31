//
//  NewEventDetailViewController.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/08/08.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit
import Then
import WebKit
import SwiftyJSON
import RxSwift

struct EventData {
    var naviTitle: String = "이벤트 상세화면"
    var eventUrl: String = ""
    var promotionId: String = ""
    var mbId: String = ""
    var carmoreParam: String = "" // 카모아 전용 파라미터
    
    init(naviTitle: String, eventUrl: String, promotionId: String, mbId: String, carmoreParam: String) {
        self.naviTitle = naviTitle
        self.eventUrl = eventUrl
        self.promotionId = promotionId
        self.mbId = mbId
        self.carmoreParam = carmoreParam
    }
    
    init(naviTitle: String, eventUrl: String, promotionId: String, mbId: String) {
        self.naviTitle = naviTitle
        self.eventUrl = eventUrl
        self.promotionId = promotionId
        self.mbId = mbId
    }
    
    init(eventUrl: String, promotionId: String, mbId: String) {        
        self.eventUrl = eventUrl
        self.promotionId = promotionId
        self.mbId = mbId
    }
    
    init(naviTitle: String, eventUrl: String, promotionId: String) {
        self.naviTitle = naviTitle
        self.eventUrl = eventUrl
        self.promotionId = promotionId
    }
    
    init(naviTitle: String, eventUrl: String) {
        self.naviTitle = naviTitle
        self.eventUrl = eventUrl
    }
    
    init(eventUrl: String) {        
        self.eventUrl = eventUrl
    }
    
    init(promotionId: String) {
        self.promotionId = promotionId
    }
    
    init() {}
    
    internal func getQueryItems() -> [URLQueryItem] {
        var result = [URLQueryItem]()
        
        if !self.mbId.isEmpty {
            result.append(URLQueryItem(name: "mbId", value: self.mbId))
        }
        
        if !self.promotionId.isEmpty {
            result.append(URLQueryItem(name: "promotionId", value: self.promotionId))
        }
        
        if !self.carmoreParam.isEmpty {
            result.append(URLQueryItem(name: "param", value: self.carmoreParam))
        }
                        
        return result
    }
}

internal final class NewEventDetailViewController: CommonBaseViewController {
        
    // MARK: UI
    
    private lazy var naviTotalView = CommonNaviView()
    
    private lazy var totalView = UIView()
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(self, name: "openCarmore")
        contentController.add(self, name: "getBerry")
        contentController.add(self, name: "openSafari")
        config.userContentController = contentController
        let view = WKWebView(frame: CGRect.zero, configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.navigationDelegate = self
        view.uiDelegate = self
        return view
    }()
    
    // MARK: VARIABLE
            
    internal var eventData: EventData = EventData()
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom)
            $0.width.leading.trailing.bottom.equalToSuperview()
        }
        
        self.totalView.addSubview(webView)
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        naviTotalView.naviTitleLbl.text = eventData.naviTitle.isEmpty ? "이벤트 상세화면" : eventData.naviTitle
        naviTotalView.backClosure = {
            self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "openCarmore")
            self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "getBerry")
            self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "openSafari")
            
            GlobalDefine.shared.mainNavi?.pop()
        }
                                
        var urlComponents = URLComponents(string: eventData.eventUrl)        
        
        if !eventData.getQueryItems().isEmpty {
            urlComponents?.queryItems = eventData.getQueryItems()
        }
        
        guard let _url = urlComponents?.url else {
            return
        }
                        
        let request = URLRequest(url: _url)        
        webView.load(request)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
}

extension NewEventDetailViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "경고", style: .cancel) { _ in
            completionHandler()
        }
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            completionHandler(false)
        }
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension NewEventDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.useCredential, nil)
            return
        }
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let urlString = navigationAction.request.url?.absoluteString ?? ""
        printLog(out: "createWebViewWith \(urlString)")
        if navigationAction.targetFrame == nil {
            self.webView.load(navigationAction.request)
        }
        return nil
    }
}

extension NewEventDetailViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let jsInterface = message.name
        
        switch jsInterface {
        case "openSafari":
            if let jsonString = message.body as? String {
                if let dataFromString = jsonString.data(using: .utf8, allowLossyConversion: false) {
                    if let json = try? JSON(data: dataFromString) {
                        if let url = URL(string: json["url"].stringValue), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: {(success: Bool) in
                                if success {
                                    printLog(out: "Launching \(url) was successful")
                                }
                            })
                        }
                    } else {
                        Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료후 다시 시도해 주세요.")
                    }
                } else {
                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료후 다시 시도해 주세요.")
                }
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료후 다시 시도해 주세요.")
            }
            
        case "openCarmore":
            let tmapURL = "carmore://&carmore_deeplink=1&mt=3&evs=165"
            if let url = URL(string: tmapURL), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: {(success: Bool) in
                    if success {
                        printLog(out: "Launching \(url) was successful")
                    } else {
                        Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료후 다시 시도해 주세요.")
                    }
                })
            } else {
                Snackbar().show(message: "카모아 앱이 설치되어 있지 않습니다.")
            }
            
        case "getBerry":
            MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
                guard let self = self else { return }
                if isLogin {
                    RestApi().postGetBerry(eventId: "\(self.eventData.promotionId)")
                        .observe(on: MainScheduler.asyncInstance)
                        .convertData()
                        .compactMap { result -> String? in
                            switch result {
                            case .success(let data):
                                let jsonData = JSON(data)
                                
                                let code = jsonData["code"].stringValue
                                guard "1000".equals(code) else {
                                    Snackbar().show(message: "\(jsonData["msg"].stringValue)")
                                    return nil
                                }
                                
                                return code
                                
                            case .failure(let errorMessage):
                                printLog(out: "Error Message : \(errorMessage)")
                                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료후 다시 시도해 주세요.")
                                return nil
                            }
                        }
                        .subscribe(onNext: { code in
                            if "1000".equals(code) {
                                let message = UIAlertController(title: nil, message: "3천베리 지급 완료", preferredStyle: .alert)
                                let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
                                message.addAction(ok)
                                
                                GlobalDefine.shared.mainNavi?.present(message, animated: true, completion: nil)
                            } else {
                                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료후 다시 시도해 주세요.")
                            }
                        })
                        .disposed(by: self.disposeBag)
                } else {
                    MemberManager.shared.showLoginAlert()
                }
            }
            
        default:break
        }
    }
}

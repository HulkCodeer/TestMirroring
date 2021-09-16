//
//  SearchAddressViewController.swift
//  evInfra
//
//  Created by bulacode on 20/10/2019.
//  Copyright © 2019 soft-berry. All rights reserved.

import UIKit
import Material
import WebKit
import SwiftyJSON

class SearchAddressViewController: UIViewController {

    var mWebView: WKWebView!
    var searchAddressDelegate: SearchAddressViewDelegate? = nil
    
    override func loadView() {
        super.loadView()
        
        initWebView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        if let url = URL(string: Const.EV_PAY_SERVER  + "/search/address") {
            mWebView.load(URLRequest(url: url))
        }
    }

    func initWebView() {
        let webViewConfig = WKWebViewConfiguration()
        let webViewContentController = WKUserContentController()
        webViewContentController.add(self, name: "processDATA")
        webViewConfig.userContentController = webViewContentController
        
        mWebView = WKWebView(frame: self.view.frame, configuration: webViewConfig)
        mWebView.uiDelegate = self
        mWebView.navigationDelegate = self
        mWebView.translatesAutoresizingMaskIntoConstraints = true
        mWebView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(mWebView)
    }

    func prepareActionBar() {
       let backButton = IconButton(image: Icon.cm.arrowBack)
       backButton.tintColor = UIColor(named: "content-primary")
       backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
       
       navigationItem.leftViews = [backButton]
       navigationItem.hidesBackButton = true
       navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
       navigationItem.titleLabel.text = "우편번호검색"
       self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
}

extension SearchAddressViewController: WKUIDelegate {
    
}

extension SearchAddressViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("execDaumPostcode()", completionHandler: {(result, error) in
            if let result = result {
                print(result)
            }
        })
    }
}

extension SearchAddressViewController: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "processDATA" {
            if let jsonString = message.body as? String {
                if let dataFromString = jsonString.data(using: .utf8, allowLossyConversion: false) {
                    if let json = try? JSON(data: dataFromString) {
                        self.showRegisteredResult(json: json)
                    } else {
                        Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료후 다시 시도해 주세요.")
                    }
                } else {
                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료후 다시 시도해 주세요.")
                }
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료후 다시 시도해 주세요.")
            }
        }
    }
    
    func showRegisteredResult(json: JSON) {
        if let delegate = searchAddressDelegate{
            delegate.recieveAddressInfo(zonecode: json["zonecode"].stringValue, fullRoadAddr: json["fullRoadAddr"].stringValue)
        }else{
            Snackbar().show(message: "주소를 받아오지 못했습니다. 다시 시도해 주세요.")
        }
        self.navigationController?.pop()
    }
}

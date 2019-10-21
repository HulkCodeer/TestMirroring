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
        
        override func loadView() {
            super.loadView()
            initWebView()
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            prepareActionBar()
            if let url = URL(string: Const.EV_SERVER_IP  + "/searchAddressIos"){
                print("PJS HERE URL LOAD")
                mWebView.load(URLRequest(url: url))
            }
            
        }
        

        func initWebView() {
            
            let webViewConfig = WKWebViewConfiguration()
            let webViewContentController = WKUserContentController()
            webViewContentController.add(self, name: "returnFromServer")
            
            
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
           backButton.tintColor = UIColor(rgb: 0x15435C)
           backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
           
           navigationItem.leftViews = [backButton]
           navigationItem.hidesBackButton = true
           navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
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

    extension SearchAddressViewController: WKNavigationDelegate{
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
            if(message.name == "returnFromServer"){
                if let jsonString = message.body as? String {
                    if let dataFromString = jsonString.data(using: .utf8, allowLossyConversion: false) {
                        if let json = try? JSON(data: dataFromString) {
                            self.showRegisteredResult(json: json)
                        } else {
                            Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료후 다시 시도해 주세요.")
                        }
                    } else{
                        Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료후 다시 시도해 주세요.")
                    }
                } else{
                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료후 다시 시도해 주세요.")
                }
                
            }
        }
        
        func showRegisteredResult(json: JSON) {
            
        }
    }

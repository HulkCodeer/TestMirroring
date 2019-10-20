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
            if let url = URL(string: Const.keyboardWillShowEV_SERVER_IP  + "/searchAddress"){
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
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "경고", style: .cancel) { _ in
                completionHandler()
                
            }
            alertController.addAction(cancelAction);
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

    extension SearchAddressViewController: WKNavigationDelegate{
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let urlStr = navigationAction.request.url?.absoluteString{
            }
            if navigationAction.navigationType == .linkActivated  {
                if let newURL = navigationAction.request.url,
                    let host = newURL.host,
                    UIApplication.shared.canOpenURL(newURL) {
                    if(host.hasPrefix("kftc-bankpay")) {
                        UIApplication.shared.open(newURL, options: [:], completionHandler: {(isInstalled) -> Void in
                            if !isInstalled {
                                if let kftcMobileDownloadUrl = URL.init(string: "http://itunes.apple.com/kr/app/id369125087?mt=8") {
                                    UIApplication.shared.open(kftcMobileDownloadUrl)
                                }
                            }
                        })
                    }else{
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(newURL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(newURL)
                        }
                    }
                    
                    decisionHandler(.allow)
                } else {
                    decisionHandler(.allow)
                }
            } else {
                decisionHandler(.allow)
            }
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
                            Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
                        }
                    } else{
                        Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
                    }
                } else{
                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
                }
                
            }
        }
        
        func showRegisteredResult(json: JSON) {
            let payInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "MyPayinfoViewController") as! MyPayinfoViewController
            payInfoVC.registData = json
            var vcArray = self.navigationController?.viewControllers
            vcArray!.removeLast()
            vcArray!.append(payInfoVC)
            self.navigationController?.setViewControllers(vcArray!, animated: true)
        }
    }

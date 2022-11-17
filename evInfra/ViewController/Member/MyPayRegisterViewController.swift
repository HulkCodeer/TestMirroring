//
//  MyPayRegisterViewController.swift
//  evInfra
//
//  Created by bulacode on 16/10/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import Material
import WebKit
import SwiftyJSON
import RxSwift

internal final class MyPayRegisterViewController: UIViewController {
    internal weak var myPayRegisterViewDelegate: MyPayRegisterViewDelegate?
    
    private let disposeBag = DisposeBag()
    
    private lazy var customNavibar = CommonNaviView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
        $0.naviTitleLbl.text = "결제정보관리"
    }
    private var mWebView: WKWebView!
    
    override func loadView() {
        super.loadView()
        initWebView()
        
        customNavibar.backClosure = { [weak self] in
            self?.navigationController?.pop()
            self?.myPayRegisterViewDelegate?.onCancelRegister()
        }
        
        view.addSubview(customNavibar)
        customNavibar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
    }
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AmplitudeEvent.shared.fromViewSourceByLogEvent(eventType: .viewAddPaymentCard)        
        
        makePostRequest(url: Const.EV_PAY_SERVER + "/pay/evPay/registEvPay", payload: ["mb_id":"\(MemberManager.shared.mbId)"])
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    func initWebView() {
        
        let webViewConfig = WKWebViewConfiguration()
        let webViewContentController = WKUserContentController()
        webViewContentController.add(self, name: "returnFromServer")
        
        
        webViewConfig.userContentController = webViewContentController
        
        let frame: CGRect = .init(x: view.frame.minX, y: view.frame.minY + Constants.view.naviBarHeight,
                                  width: view.frame.width, height: view.frame.height)
        mWebView = WKWebView(frame: frame, configuration: webViewConfig)
        mWebView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16D57"
        mWebView.uiDelegate = self
        mWebView.navigationDelegate = self
        mWebView.translatesAutoresizingMaskIntoConstraints = true
        mWebView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(mWebView)
        
    }
    
    func makePostRequest(url: String, payload: Dictionary<String, Any>) {
        let jsonPayload: String
        do {
            let data = try JSONSerialization.data(
                withJSONObject: payload,
                options: JSONSerialization.WritingOptions(rawValue: 0))
            jsonPayload = String(data: data, encoding: String.Encoding.utf8)!
        } catch {
            jsonPayload = "{}"
        }
        
        mWebView.loadHTMLString(postMakingHTML(url: url, payload: jsonPayload), baseURL: nil)
    }
    
    private func postMakingHTML(url: String, payload: String) -> String {
        return "<html><head><script>function post(path,params,method){method = method || 'post';var form=document.createElement('form');form.setAttribute('method', method);form.setAttribute('action',path);for(var key in params){if(params.hasOwnProperty(key)){var hiddenField=document.createElement('input');hiddenField.setAttribute('type', 'hidden');hiddenField.setAttribute('name', key);hiddenField.setAttribute('value', params[key]);form.appendChild(hiddenField);}}document.body.appendChild(form);form.submit();}</script></head><body></body></html><script>post('\(url)',\(payload),'post');</script>"
    }
    
}

extension MyPayRegisterViewController: WKUIDelegate {
    
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

extension MyPayRegisterViewController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

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
                    UIApplication.shared.open(newURL, options: [:], completionHandler: nil)
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

extension MyPayRegisterViewController: WKScriptMessageHandler {

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
        self.navigationController?.pop()
        myPayRegisterViewDelegate?.finishRegisterResult(json: json)
        
        GlobalDefine.shared.isUseAllBerry.onNext(true)
    }
}

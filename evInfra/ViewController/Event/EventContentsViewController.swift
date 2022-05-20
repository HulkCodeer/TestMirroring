//
//  EventContentsViewController.swift
//  evInfra
//
//  Created by 이신광 on 06/11/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON
import WebKit

class EventContentsViewController: UIViewController {

    @IBOutlet weak var webViewContainer: UIView!
    var webView: WKWebView!
    var eventId = 0
    var eventTitle: String = ""
    
    
    override func loadView() {
        super.loadView()
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        let frame = CGRect(x: 0, y: 0, width: webViewContainer.frame.width, height: webViewContainer.frame.height)
        
        config.userContentController = contentController
        webView = WKWebView(frame: frame, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = true
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        webViewContainer.addSubview(webView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareActionBar()
        prepareWebView()
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = eventTitle
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareWebView() {
        let url = Const.EV_PAY_SERVER + "/event/event/getDetailEvent"
        let payload = ["mb_id":"\(MemberManager.shared.mbId)",  "event_id":"\(eventId)"]
        makePostRequest(url: url, payload: payload)
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
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
        
        webView.loadHTMLString(postMakingHTML(url: url, payload: jsonPayload), baseURL: nil)
    }
    
    private func postMakingHTML(url: String, payload: String) -> String {
        return "<html><head><script>function post(path,params,method){method = method || 'post';var form=document.createElement('form');form.setAttribute('method', method);form.setAttribute('action',path);for(var key in params){if(params.hasOwnProperty(key)){var hiddenField=document.createElement('input');hiddenField.setAttribute('type', 'hidden');hiddenField.setAttribute('name', key);hiddenField.setAttribute('value', params[key]);form.appendChild(hiddenField);}}document.body.appendChild(form);form.submit();}</script></head><body></body></html><script>post('\(url)',\(payload),'post');</script>"
    }

}

extension EventContentsViewController: WKUIDelegate {
    
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

extension EventContentsViewController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        
    }
}

//extension EventContentsViewController: WKScriptMessageHandler {
//
//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        if(message.name == "ClientControl"){
//
//        }
//    }
//
//
//}

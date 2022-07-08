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
import RxSwift

internal final class EventContentsViewController: UIViewController {

    // MARK: UI
    
    @IBOutlet weak var webViewContainer: UIView!
    
    // MARK: VARIABLE
    
    private var webView: WKWebView!
    private let disposebag = DisposeBag()
    
    internal var eventId = 0
    internal var eventTitle: String = ""
    internal var externalEventParam: String?
    
    // MARK: SYSTEM FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func loadView() {
        super.loadView()
        let contentController = WKUserContentController()
        contentController.add(self, name: "openCarmore")
        contentController.add(self, name: "getBerry")
        contentController.add(self, name: "openMonthlySubscription")
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
        var payload = ["mb_id":"\(MemberManager.shared.mbId)",  "event_id":"\(eventId)"]
        
        if let _externalEventParam = self.externalEventParam {
            payload["param"] = _externalEventParam
        }
        
        makePostRequest(url: url, payload: payload)
    }
    
    @objc
    fileprivate func handleBackButton() {
        GlobalDefine.shared.mainNavi?.pop()
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

extension EventContentsViewController: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let jsInterface = message.name
        
        switch jsInterface {
        case "openMonthlySubscription":
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
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료후 다시 시도해 주세요.")
            }
            
        case "getBerry":
            RestApi().postGetBerry(eventId: "\(self.eventId)")
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
                .disposed(by: self.disposebag)
            
        default:break            
        }
    }
}

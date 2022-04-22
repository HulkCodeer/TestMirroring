//
//  GuideAlertDialog.swift
//  evInfra
//
//  Created by SH on 2021/09/08.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON
import WebKit

class GuideAlertDialog: UIView, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet var dismissBtn: UIButton!
    @IBOutlet var guideView: UIView!
    
    var webView: WKWebView!
    var guideUrl: String = ""
    var newVersion: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        getUpdateGuide()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        getUpdateGuide()
    }
    
    private func initView() {
        let view = Bundle.main.loadNibNamed("GuideAlertDialog", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        dismissBtn.layer.cornerRadius = 6
        
        webView = WKWebView(frame: self.guideView.bounds)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = true
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.guideView.addSubview(webView)
    }
    
    private func getUpdateGuide() {
        let guideVersion = UserDefault().readInt(key: UserDefault.Key.GUIDE_VERSION)
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        Server.getUpdateGuide(guide_version: guideVersion, app_version: version) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let code = json["code"].stringValue
                switch(code) {
                    case "1000":
                        self.guideUrl = Const.EV_PAY_SERVER + "/docs/guide/update_guide?view=" + json["url"].stringValue
                        self.newVersion = json["version"].intValue
                        self.initView()
                        self.showGuide()
                        break;

                    default:
                        self.removeFromSuperview()
                        break;
                }
            }
        }
    }
    
    private func showGuide() {
        let url = NSURL(string:guideUrl)
        let request = NSURLRequest(url: url! as URL)
        webView.load(request as URLRequest)
    }
    
    @IBAction func onClickClose(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @IBAction func onClickDismiss(_ sender: Any) {
        UserDefault().saveInt(key: UserDefault.Key.GUIDE_VERSION, value: newVersion)
        Snackbar().show(message: "업데이트 안내 다시보지 않기가 설정되었습니다. ")
        self.removeFromSuperview()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            if let newURL = navigationAction.request.url,
                let host = newURL.host , !host.hasPrefix(Const.EV_PAY_SERVER) &&
                UIApplication.shared.canOpenURL(newURL) {
                if host.hasPrefix("com.soft-berry.ev-infra") { // deeplink
                    if #available(iOS 13.0, *) {
                        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                        DeepLinkPath.sharedInstance.linkPath = newURL.path
                        if let component = URLComponents(url: newURL, resolvingAgainstBaseURL: false) {
                            DeepLinkPath.sharedInstance.linkParameter = component.queryItems
                        }
                        DeepLinkPath.sharedInstance.runDeepLink(navigationController: (sceneDelegate?.navigationController)!)
                    } else {
                        UIApplication.shared.open(newURL, options: [:], completionHandler: nil)
                    }
                } else {
                    UIApplication.shared.open(newURL, options: [:], completionHandler: nil)
                }
                self.removeFromSuperview()
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}

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

class GuideAlertDialog: UIView, WKNavigationDelegate {
    
    @IBOutlet var dismissBtn: UIButton!
    @IBOutlet var guideView: UIView!
    
    var webView: WKWebView!
    var guideUrl: String = ""
    var newVersion: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        getUpdateGuide()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
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
                        self.guideUrl = Const.EV_PAY_SERVER + json["url"].stringValue
                        self.newVersion = json["version"].intValue
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
        self.removeFromSuperview()
    }
    
}

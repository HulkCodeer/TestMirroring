//
//  MembershipTermView.swift
//  evInfra
//
//  Created by bulacode on 25/10/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import WebKit

class MembershipTermView: UIView, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var termView: UIView!
    var webView: WKWebView!
    var delegate: MembershipTermViewDelegate?

    @IBAction func onClickConfirmBtn(_ sender: UIButton) {
        delegate?.confirmMembershipTerm()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            loadTerm()
        }
    }
    
    private func commonInit() {
        let view = Bundle.main.loadNibNamed("MembershipTermView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        webView = WKWebView(frame: self.termView.frame)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = true
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.termView.addSubview(webView)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func loadTerm() {
        let strUrl = "\(Const.EV_PAY_SERVER)/terms/term/membership"
        let url = NSURL(string:strUrl)
        let request = NSURLRequest(url: url! as URL)
        webView.load(request as URLRequest)
    }
}

protocol MembershipTermViewDelegate {
    func confirmMembershipTerm()
}

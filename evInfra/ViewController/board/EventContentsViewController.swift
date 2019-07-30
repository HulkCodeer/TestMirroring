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

class EventContentsViewController: UIViewController, WKUIDelegate {

    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var btnAccept: UIButton!
    var webView: WKWebView!
    var eventId = 0
    
    override func loadView() {
        super.loadView()
        
        let frame = CGRect(x: 0, y: 0, width: webViewContainer.frame.width, height: webViewContainer.frame.height)
        webView = WKWebView(frame: frame)
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = true
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        webViewContainer.addSubview(webView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareActionBar()
        prepareWebView()
        
        btnAccept.addTarget(self, action: #selector(onClickAccept), for: .touchUpInside)
        
        verifyEvent()
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "이벤트 내용"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareWebView() {
        let eventUrl = Const.EV_SERVER_IP + "/event/contents/\(eventId)"
        let request = URLRequest(url: URL(string: eventUrl)!)
        webView.load(request)
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    @objc
    fileprivate func onClickAccept() {
        self.acceptEvent()
    }
    
    fileprivate func verifyEvent() {
        Server.verifyEvent(eventId: eventId) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let result = json["result_code"].stringValue
                
                switch result {
                case "1000": // 참여 가능
                    self.btnAccept.isEnabled = true
                case "1001": // 이미 참여함
                    self.btnAccept.isEnabled = false
                    Snackbar().show(message: "이미 참여한 이벤트입니다.")
                case "1002": // 쿠폰 소진
                    self.btnAccept.isEnabled = false
                    Snackbar().show(message: "쿠폰이 모두 소진되었습니다.")
                case "1003": // 기한 만료
                    self.btnAccept.isEnabled = false
                    Snackbar().show(message: "이벤트가 만료되었습니다.")
                case "1004": // 이벤트 취소
                    self.btnAccept.isEnabled = false
                    Snackbar().show(message: "이벤트가 종료되었습니다.")
                default: // "9000" error
                    self.btnAccept.isEnabled = false
                    Snackbar().show(message: "잠시 후 다시 시도해 주세요.")
                }
            }
        }
    }
    
    fileprivate func acceptEvent() {
        Server.acceptEvent(eventId: eventId) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let result = json["result_code"].stringValue
                
                switch result {
                case "1000": // 쿠폰 발급 완료
                    self.btnAccept.isEnabled = false
                    Snackbar().show(message: "쿠폰이 발급되었습니다.")
                case "1001": // 이미 참여함
                    self.btnAccept.isEnabled = false
                    Snackbar().show(message: "이미 참여한 이벤트입니다.")
                case "1002": // 쿠폰 소진
                    self.btnAccept.isEnabled = false
                    Snackbar().show(message: "쿠폰이 모두 소진되었습니다.")
                default: // "9000" error
                    self.btnAccept.isEnabled = false
                    Snackbar().show(message: "쿠폰 발급을 실패했습니다. 잠시 후 다시 시도해 주세요.")
                }
            }
        }
    }
}

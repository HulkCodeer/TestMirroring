//
//  MyPayinfoViewController.swift
//  evInfra
//
//  Created by bulacode on 21/06/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import Material
import WebKit
import SwiftyJSON

class MyPayinfoViewController: UIViewController{
    let PAY_REGISTER_MODE = 1
    let CARD_REGISTER_MODE = 2
    
    let DELETE_MODE = 0
    let CHANGE_MODE = 1
    
    var mWebView: WKWebView!
    @IBOutlet weak var mPayInfoView: UIView!
    @IBOutlet weak var registerCardInfo: UIView!
    @IBOutlet weak var registerInfo: UIView!
    
    @IBOutlet weak var franchiseeLabel: UILabel!
    @IBOutlet weak var vanLabel: UILabel!
    @IBOutlet weak var cardCoLabel: UILabel!
    @IBOutlet weak var cardNoLabel: UILabel!
    @IBOutlet weak var regDateLabel: UILabel!
    
    
    @IBOutlet weak var resultCodeLabel: UILabel!
    @IBOutlet weak var resultMsgLabel: UILabel!
    @IBOutlet weak var registerInfoBtnLayer: UIStackView!
    
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var changeBtn: UIButton!
    
    var registerInfoHeight:CGFloat = 0;
    override func loadView() {
        super.loadView()
        initWebView()
        initInfoView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        checkRegisterPayment()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func checkRegisterPayment(){
        Server.getPayRegisterStatus { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let payCode = json["pay_code"].intValue
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
                switch(payCode){
                    case PaymentStatus.PAY_NO_USER, PaymentStatus.PAY_NO_CARD_USER:
                        self.showRegisterWeb()
                        
                        break;
                    case PaymentStatus.PAY_DEBTOR_USER, PaymentStatus.PAY_NO_VERIFY_USER, PaymentStatus.PAY_DELETE_FAIL_USER:
                        let ok = UIAlertAction(title: "확인", style: .default, handler:{ (ACTION) -> Void in
                            self.navigationController?.pop()
                        })
                        var actions = Array<UIAlertAction>()
                        actions.append(ok)
                        UIAlertController.showAlert(title: "알림", message: json["ResultMsg"].stringValue, actions: actions)

                    case PaymentStatus.PAY_FINE_USER:
                        Server.getPayRegisterInfo { (isSuccess, value) in
                            if isSuccess {
                                let json = JSON(value)
                                self.showRegisteredResult(json: json)
                            }else {
                                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
                            }
                        }
                    case PaymentStatus.PAY_REGISTER_FAIL_PG:
                        let ok = UIAlertAction(title: "확인", style: .default, handler:{ (ACTION) -> Void in
                            self.navigationController?.pop()
                        })
                        var actions = Array<UIAlertAction>()
                        actions.append(ok)
                        UIAlertController.showAlert(title: "알림", message: "서비스 연결상태가 좋지 않습니다.\n잠시 후 다시 시도해 주세요.", actions: actions)

                    default:
                        break;
                }
                
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            }
        }
        
    }
    
    
    func showRegisteredResult(json: JSON) {
        self.mWebView.isHidden = true
        self.mPayInfoView.isHidden = false
        let payCode = json["pay_code"].intValue
       
        switch(payCode){
                
            case PaymentStatus.PAY_REGISTER_SUCCESS:
                self.registerCardInfo.isHidden = false
                self.okBtn.isHidden = false
                self.registerInfoBtnLayer.isHidden = true
                
                self.franchiseeLabel.text = "(주)소프트베리"
                self.vanLabel.text = "스마트로(주)"
                self.cardCoLabel.text = json["card_co"].stringValue
                self.cardNoLabel.text = json["card_nm"].stringValue
                self.regDateLabel.text = json["reg_date"].stringValue
                
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
                
            case PaymentStatus.PAY_REGISTER_FAIL, PaymentStatus.PAY_REGISTER_FAIL_PG, PaymentStatus.PAY_REGISTER_CANCEL_FROM_USER:
                self.registerCardInfo.isHidden = true
                self.okBtn.isHidden = false
                self.registerInfoBtnLayer.isHidden = true
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
            case PaymentStatus.PAY_MEMBER_DELETE_SUCESS, PaymentStatus.PAY_MEMBER_DELETE_FAIL_NO_USER, PaymentStatus.PAY_MEMBER_DELETE_FAIL, PaymentStatus.PAY_MEMBER_DELETE_FAIL_DB:
                self.registerCardInfo.isHidden = true
                self.okBtn.isHidden = false
                self.registerInfoBtnLayer.isHidden = true
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
                break;
            case PaymentStatus.PAY_FINE_USER:
                self.registerCardInfo.isHidden = false
                self.okBtn.isHidden = true
                self.registerInfoBtnLayer.isHidden = false
                self.franchiseeLabel.text = "(주)소프트베리"
                self.vanLabel.text = "스마트로(주)"
                self.cardCoLabel.text = json["card_co"].stringValue
                self.cardNoLabel.text = json["card_nm"].stringValue
                self.regDateLabel.text = json["reg_date"].stringValue
                break;
            default:
                self.registerCardInfo.isHidden = true
                self.okBtn.isHidden = false
                self.registerInfoBtnLayer.isHidden = true
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
                break;
            
        }
        
    }

    func showRegisterWeb(){
        mWebView.isHidden = false
        mPayInfoView.isHidden = true
        makePostRequest(url: Const.EV_PAY_SERVER + "/pay/evPay/registEvPay", payload: ["mb_id":"\(MemberManager.getMbId())"])
        
    }
    
    func deletePayMember(){
        Server.deletePayMember { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let payCode = json["pay_code"].intValue
                self.registerInfo.visible()
                self.registerCardInfo.isHidden = true
                self.okBtn.isHidden = false
                self.registerInfoBtnLayer.isHidden = true
                self.resultCodeLabel.text = "\(payCode)"
                self.resultMsgLabel.text = json["ResultMsg"].stringValue
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            }
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
    
    func initInfoView(){
        registerCardInfo.layer.shadowColor = UIColor.black.cgColor
        registerCardInfo.layer.shadowOpacity = 0.5
        registerCardInfo.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        registerInfo.layer.shadowColor = UIColor.black.cgColor
        registerInfo.layer.shadowOpacity = 0.5
        registerInfo.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        registerInfoHeight = registerInfo.layer.height
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "결제정보관리"
        self.navigationController?.isNavigationBarHidden = false
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
    
    @IBAction func onClickOkBtn(_ sender: UIButton) {
        self.navigationController?.pop()
    }
    
    @IBAction func onClickDeleteBtn(_ sender: UIButton) {
        showAlertDialog(vc: self, type: self.DELETE_MODE, completion:  {(isOkey) -> Void in
            if isOkey {
               self.deletePayMember()
            }
        })
    }
    
    @IBAction func onClickChangeBtn(_ sender: UIButton) {
        registerCardInfo.gone()
        
        showAlertDialog(vc: self, type: self.CHANGE_MODE, completion:  {(isOkey) -> Void in
            if isOkey {
                self.showRegisterWeb()
            }
        })
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    func showAlertDialog(vc: UIViewController, type: Int, completion: ((Bool) -> ())? = nil) {
        var title: String = ""
        var msg: String = ""
        
        switch(type){
            case self.DELETE_MODE:
                title = "알림"
                msg = "결제정보를 삭제하시면 결제기능을 이용할 수 없습니다.\n결제정보를 삭제 하시겠습니까?"
                break;
            case self.CHANGE_MODE:
                title = "알림"
                msg = "결제정보 변경을 진행하시면, 현재 결제정보는 이용할 수 없습니다.\n결제정보를 변경 하시겠습니까?"
                break;
            
            default:
                break;
        }
        
        let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in
            if completion != nil {
                completion!(true)
            }
        })
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler:{ (ACTION) -> Void in
            if completion != nil {
                completion!(false)
            }
        })
        
        var actions = Array<UIAlertAction>()
        actions.append(ok)
        actions.append(cancel)
        UIAlertController.showAlert(title: title, message: msg, actions: actions)
    }
}

extension MyPayinfoViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .cancel) { _ in
            completionHandler()
            
        }
        alertController.addAction(okAction);
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

extension MyPayinfoViewController: WKNavigationDelegate{
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

extension MyPayinfoViewController: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "returnFromServer"){
            let data = message.body
            let json = JSON.init(parseJSON: data as! String)
            self.showRegisteredResult(json: json)
        }
    }
}

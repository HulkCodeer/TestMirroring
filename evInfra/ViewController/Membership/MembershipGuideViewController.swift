//
//  RentalInfoManageViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/10.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import WebKit
import Then
import RxSwift

internal final class MembershipGuideViewController: CommonBaseViewController, WKUIDelegate {
    
    // MARK: VARIABLE
    
    private let disposebag = DisposeBag()
    
    internal weak var delegate: LeftViewReactorDelegate?
    
    // MARK: UI
    
    private lazy var commonNaviView = CommonNaviView().then {
        $0.naviTitleLbl.text = "EV Pay 카드 안내"
    }
    
    private let config = WKWebViewConfiguration().then {
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        $0.userContentController = contentController
    }
    
    private lazy var webView = WKWebView(frame: CGRect.zero, configuration: self.config).then {
        $0.navigationDelegate = self
        $0.uiDelegate = self
    }
            
    private lazy var membershipRegisterBtn = StickyButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 80), level: .primary).then {
        $0.rectBtn.setTitle("EV Pay 카드 만들기", for: .normal)
    }
    
    private lazy var membershipBtnTitleLbl = UILabel().then {
        $0.text = "EV Pay 카드 만들기"
        $0.textColor = Colors.nt9.color
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textAlignment = .center
    }
    
    private lazy var arrowImgView = UIImageView().then {
        
        $0.image = UIImage(named: "icon_arrow_right_lg")
        $0.tintColor = UIColor(named: "content-primary")
    }
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
                
        self.contentView.addSubview(commonNaviView)
        commonNaviView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
        
        self.contentView.addSubview(self.membershipRegisterBtn)
        membershipRegisterBtn.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        self.contentView.addSubview(self.webView)
        webView.snp.makeConstraints {
            $0.top.equalTo(commonNaviView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(membershipRegisterBtn.snp.top)
        }
                                        
        guard let _url = URL(string: "\(Const.EV_PAY_SERVER)/docs/info/membership_info?osType=ios") else {
            return
        }
        let requestUrl = URLRequest(url: _url)
        webView.load(requestUrl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AmplitudeEvent.shared.fromViewSourceByLogEvent(eventType: .viewApplyEVICard)
        
        membershipRegisterBtn.rectBtn.rx.tap
            .asDriver()
            .drive(with: self) { obj, _ in
                let viewcon = UIStoryboard(name : "Membership", bundle: nil).instantiateViewController(ofType: MembershipIssuanceViewController.self)
                viewcon.delegate = obj
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                AmplitudeEvent.shared.fromViewSourceByLogEvent(eventType: .viewInfoEVICard)                                
            }
            .disposed(by: disposebag)
    }
            
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = false
    }
    
    // 추후 딥링크 추가시 필요
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == "evinfra" {
            DeepLinkModel.shared.openSchemeURL(urlstring: url.absoluteString)
        }
        decisionHandler(.allow)
        return
    }
    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//
//        if navigationAction.navigationType == .linkActivated  {
//            if let newURL = navigationAction.request.url,
//                let host = newURL.host, UIApplication.shared.canOpenURL(newURL) {
//                if host.hasPrefix("com.soft-berry.ev-infra") { // deeplink
//                    if #available(iOS 13.0, *) {
//                        DeepLinkPath.sharedInstance.linkPath = newURL.path
//                        if let component = URLComponents(url: newURL, resolvingAgainstBaseURL: false) {
//                            DeepLinkPath.sharedInstance.linkParameter = component.queryItems
//                        }
//                        DeepLinkPath.sharedInstance.runDeepLink()
//                    } else {
//                        UIApplication.shared.open(newURL, options: [:], completionHandler: nil)
//                    }
//                } else {
//                    UIApplication.shared.open(newURL, options: [:], completionHandler: nil)
//                }
//                decisionHandler(.cancel)
//            } else {
//                decisionHandler(.allow)
//            }
//        } else {
//            decisionHandler(.allow)
//        }
//    }
}

extension MembershipGuideViewController: UIWebViewDelegate {
}

extension MembershipGuideViewController: WKNavigationDelegate {
}

extension MembershipGuideViewController: LeftViewReactorDelegate {
    func completeResiterMembershipCard() {
        self.delegate?.completeResiterMembershipCard()
    }
    
    func completeRegisterPayCard() {}
}

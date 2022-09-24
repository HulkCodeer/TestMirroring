//
//  NewNoticeDetailViewController.swift
//  evInfra
//
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SafariServices
import WebKit

import Then
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import WebKit

internal final class NewNoticeDetailViewController: CommonBaseViewController, StoryboardView {
        
    private lazy var customNaviBar = CommonNaviView().then {
        $0.naviTitleLbl.text = "EV Infra 공지사항"
    }
    
    private lazy var scrollView = UIScrollView().then {
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
    }
    private lazy var scrollContentView = UIView()
    
    private lazy var titleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 8
    }
    private lazy var titleLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.font = .systemFont(ofSize: 18, weight: .bold)
    }
    private lazy var dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = Colors.contentTertiary.color
    }
    private lazy var titleBottomSpacingView = UIView()
    private lazy var divider = UIView().then {
        $0.backgroundColor = Colors.nt1.color
    }
    
    private lazy var webView = WKWebView().then {
        $0.scrollView.alwaysBounceVertical = false
        $0.navigationDelegate = self
    }
    
    init(reactor: NoticeDetailReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: lifeCycle

    override func loadView() {
        super.loadView()

        contentView.addSubview(customNaviBar)
        contentView.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)

        scrollContentView.addSubview(titleStackView)
        scrollContentView.addSubview(webView)
        
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(dateLabel)
        titleStackView.addArrangedSubview(titleBottomSpacingView)
        titleStackView.addSubview(divider)
        
        let horizontalMargin: CGFloat = 16
        let verticalPadding: CGFloat = 24
        let titleBottomSpacing: CGFloat = 16
        let webViewBottomSpacing: CGFloat = 30
        
        let webViewEstimatedHeight: CGFloat = 200
        
        customNaviBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
            $0.height.equalTo(Constants.view.naviBarHeight)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(customNaviBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.width.equalTo(view)
            $0.bottom.equalTo(view)
        }
        
        scrollContentView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.width.equalToSuperview()
        }

        titleStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(verticalPadding)
            $0.leading.trailing.equalToSuperview().inset(horizontalMargin)
        }
        titleBottomSpacingView.snp.makeConstraints {
            $0.height.equalTo(titleBottomSpacing)
        }
        webView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(verticalPadding)
            $0.leading.trailing.equalToSuperview().inset(horizontalMargin)
            $0.bottom.equalToSuperview().inset(webViewBottomSpacing)
            $0.height.equalTo(webViewEstimatedHeight)
        }
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        divider.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.width.equalTo(view)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(titleStackView)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
    
    // MARK: bind
    
    internal func bind(reactor: NoticeDetailReactor) {
        // action
        Observable.just(NoticeDetailReactor.Action.loadHTML)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // satate
        reactor.state.map { $0.title }
            .asDriver(onErrorJustReturn: String())
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.date }
            .asDriver(onErrorJustReturn: String())
            .drive(dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        reactor.state.map { $0.html }
            .asDriver(onErrorJustReturn: String())
            .drive(with: self) { owner, html in
                owner.webView.loadHTMLString(html, baseURL: nil)
            }
            .disposed(by: disposeBag)
        
    }

}

// MARK: WKNavigationDelegate

extension NewNoticeDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard case .linkActivated = navigationAction.navigationType,
              let url = navigationAction.request.url
        else {
            decisionHandler(.allow)
            return
        }
        
        if let url = navigationAction.request.url,
            url.scheme == "evinfra"
        {  // deeplink
            DeepLinkModel.shared.openSchemeURL(urlstring: url.absoluteString)
        } else {
            openSafari(url: url)
        }

        decisionHandler(.cancel)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let webviewHeight: CGFloat = webView.scrollView.contentSize.height
            webView.snp.updateConstraints {
                $0.height.equalTo(webviewHeight)
            }
        }
    }
    
    // MARK: WebViewAction
    
    private func openSafari(url: URL) {
        let hasHost = url.host != nil
        let url = hasHost ? url : URL(string: "http://\(url)")
        guard let _url = url  else { return }
        
        let safariVC = SFSafariViewController(url: _url)
        safariVC.modalPresentationStyle = .pageSheet
        GlobalDefine.shared.mainNavi?.present(safariVC, animated: true)
    }
    
}

//
//  NewNoticeDetailViewController.swift
//  evInfra
//
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
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
    }
    private lazy var contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 24
    }
    
    private lazy var titleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 8
    }
    private lazy var titleTopSpacingView = UIView()
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
    }
    
    init(reactor: NoticeDetailReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()

        contentView.addSubview(customNaviBar)
        contentView.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(titleStackView)
        contentStackView.addArrangedSubview(webView)

        titleStackView.addArrangedSubview(titleTopSpacingView)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(dateLabel)
        titleStackView.addArrangedSubview(titleBottomSpacingView)
        titleStackView.addSubview(divider)
        
        let horizontalMargin: CGFloat = 16
        let titleVerticalSpacing: CGFloat = 16
        
        customNaviBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
//            $0.height.equalTo(Constants.view.naviHeight)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(customNaviBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view)
        }
        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalTo(view).inset(horizontalMargin)
        }

        titleTopSpacingView.snp.makeConstraints {
            $0.height.equalTo(titleVerticalSpacing)
        }
        titleBottomSpacingView.snp.makeConstraints {
            $0.height.equalTo(titleVerticalSpacing)
        }

        divider.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalTo(contentView)
            $0.bottom.equalTo(titleStackView)
        }
        
        webView.snp.makeConstraints {
            $0.height.equalTo(view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
    
    internal func bind(reactor: NoticeDetailReactor) {
        Observable.just(NoticeDetailReactor.Action.loadHTML)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.title }
            .observe(on: MainScheduler.instance)
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.date }
            .observe(on: MainScheduler.instance)
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.html }
            .asDriver(onErrorJustReturn: String())
            .drive(with: self) { owner, html in
                owner.webView.loadHTMLString(html, baseURL: nil)
            }
            .disposed(by: disposeBag)
        
    }
}

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

final class NewNoticeDetailViewController: CommonBaseViewController {
    private lazy var customNaviBar = CommonNaviView().then {
        $0.naviTitleLbl.text = "공지사항"
    }
    
    private lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    private lazy var contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
    }
    
    private lazy var titleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 4
    }
    private lazy var titleLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.font = .systemFont(ofSize: 18, weight: .bold)
    }
    private lazy var dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = Colors.contentTertiary.color
    }
    private lazy var divider = UIView().then {
        $0.backgroundColor = Colors.nt1.color
    }
    
    private lazy var webView = WKWebView()
    override func loadView() {
        super.loadView()
        
        contentView.addSubview(customNaviBar)
//        contentView.addSubview(webView)
        contentView.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(titleStackView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
    
}

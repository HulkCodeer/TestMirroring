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

internal final class MembershipGuideViewController: BaseViewController {
    
    // MARK: VARIABLE
    
    private let disposebag = DisposeBag()
    
    // MARK: UI
    
    private let config = WKWebViewConfiguration().then {
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        $0.userContentController = contentController
    }
    
    private lazy var webView = WKWebView(frame: CGRect.zero, configuration: self.config).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var membershipRegisterBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor(named: "gr-5")
    }
    
    private lazy var membershipBtnTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "회원카드 만들기"
        $0.textColor = UIColor(named: "nt-9")
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textAlignment = .center
    }
    
    private lazy var arrowImgView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icon_arrow_right_lg")
        $0.tintColor = UIColor(named: "content-primary")
    }
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        prepareActionBar(with: "회원카드 안내")
        
        view.addSubview(self.membershipRegisterBtn)
        membershipRegisterBtn.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            let safeAreaBottomHeight = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            $0.height.equalTo(64 + safeAreaBottomHeight)
        }
        
        view.addSubview(self.webView)
        webView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.equalTo(membershipRegisterBtn.snp.top)
        }
        
        membershipRegisterBtn.addSubview(membershipBtnTitleLbl)
        membershipBtnTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalTo(membershipRegisterBtn.snp.centerX)
            $0.height.equalTo(24)
        }
        
        membershipRegisterBtn.addSubview(arrowImgView)
        arrowImgView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(membershipBtnTitleLbl.snp.centerY)
            $0.width.height.equalTo(32)
        }
        
        guard let _url = URL(string: "\(Const.EV_PAY_SERVER)/docs/info/membership_info") else {
            return
        }
        let requestUrl = URLRequest(url: _url)
        webView.load(requestUrl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        membershipRegisterBtn.rx.tap
            .asDriver()
            .drive(onNext: {[weak self] _ in
                guard let self = self else { return }
                let storyboard = UIStoryboard(name : "Membership", bundle: nil)
                let mbsIssueVC = storyboard.instantiateViewController(ofType: MembershipIssuanceViewController.self)
                self.navigationController?.push(viewController: mbsIssueVC)
            })
            .disposed(by: disposebag)
    }
}

//
//  NewSettingsViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/06/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

internal final class NewSettingsViewController: CommonBaseViewController, StoryboardView {
    
    enum SettingType: String, CaseIterable {
        case basicNotice = "기본 알림"
        case locationNotice = "지역 알림"
        case marketingNoticeAgree = "마케팅 알림 수신 동의"
        
        internal func subTitle() -> String {
            switch self {
            case .basicNotice:
                return "충전소, 포인트 등 앱의 기본 알림에 대한 설정입니다."
                
            case .locationNotice:
                return "내가 있는 지역의 충전소 공지 알림이에요."
                
            case .marketingNoticeAgree:
                return "포인트, 충전 이벤트 등을 알려드릴게요!"
                
            default: return ""
            }
        }
    }
    
    // MARK: UI
    
    private lazy var naviTotalView = CommonNaviView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.naviTitleLbl.text = "설정"
    }
    
    private lazy var totalScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private lazy var totalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
            
    private lazy var stackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }
    
    // MARK: SYSTEM FUNC
    
    init(reactor: SettingsReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
                
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(totalScrollView)
        totalScrollView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(naviTotalView.snp.bottom)
        }
        
        totalScrollView.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        totalView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        
        for settingType in SettingType.allCases {
            let settingView = self.createSettingView(mainTitle: settingType.rawValue, subTitle: settingType.subTitle())
            settingView.snp.makeConstraints {
                $0.height.equalTo(66)
            }
            stackView.addArrangedSubview(settingView)
        }
        
        let quitAccountView = self.createQuitAccountView(mainTitle: "회원탈퇴")
        totalView.addSubview(quitAccountView)
        quitAccountView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
                    
    internal func bind(reactor: SettingsReactor) {        
                
    }
    
    private func createSettingView(mainTitle: String, subTitle: String) -> UIView {
        let view = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let mainTitleLbl = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = mainTitle
            $0.numberOfLines = 1
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = Colors.contentPrimary.color
        }
        
        view.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(22)
        }
        
        let subTitleLbl = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = subTitle
            $0.numberOfLines = 2
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = Colors.contentTertiary.color
        }
        
        view.addSubview(subTitleLbl)
        subTitleLbl.snp.makeConstraints {
            $0.top.equalTo(mainTitleLbl.snp.bottom).offset(-4)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(16)
        }
        
        let lineView = self.createLineView()
        view.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.top.equalTo(subTitleLbl.snp.bottom).offset(15)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        return view
    }
    
    private func createQuitAccountView(mainTitle: String) -> UIView {
        let view = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let mainTitleLbl = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = mainTitle
            $0.numberOfLines = 1
            $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            $0.textColor = Colors.contentTertiary.color
        }
        
        view.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(16)
        }
        
        let lineView = self.createLineView()
        view.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        return view
    }
}

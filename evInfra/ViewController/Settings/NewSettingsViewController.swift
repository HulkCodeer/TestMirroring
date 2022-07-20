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
import SwiftyJSON

internal final class NewSettingsViewController: CommonBaseViewController, StoryboardView {
    
    enum SettingType: String, CaseIterable {
        case basicNotice = "기본 알림"
        case locationNotice = "지역 알림"
        case marketingNoticeAgree = "마케팅 알림 수신 동의"
        case clustering = "충전소 군집 기능"
        
        internal func subTitle() -> String {
            switch self {
            case .basicNotice:
                return "충전소, 포인트 등 앱의 기본 알림에 대한 설정입니다."
                
            case .locationNotice:
                return "내가 있는 지역의 충전소 공지 알림이에요."
                
            case .marketingNoticeAgree:
                return "포인트, 충전 이벤트 등을 알려드릴게요!"
                
            case .clustering:
                return ""
                            
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
            $0.width.equalToSuperview()
        }
                        
        totalScrollView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.width.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        for settingType in SettingType.allCases {
            let settingView = self.createSettingView(mainTitle: settingType.rawValue, subTitle: settingType.subTitle(), settingType: settingType)
            settingView.snp.makeConstraints {
                $0.height.equalTo(66)
            }
            stackView.addArrangedSubview(settingView)
        }
                
        MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
            guard let self = self,
                    (MemberManager.shared.loginType == .kakao ||
                    MemberManager.shared.loginType == .apple) else { return }
            let quitAccountView = self.createQuitAccountView(mainTitle: "회원탈퇴")
            self.totalScrollView.addSubview(quitAccountView)
            quitAccountView.snp.makeConstraints {
                $0.top.equalTo(self.stackView.snp.bottom)
                $0.leading.bottom.trailing.equalToSuperview()
                $0.centerX.equalToSuperview()
                $0.height.equalTo(isLogin ? 56:0)
            }
        }
    }
            
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
                    
    internal func bind(reactor: SettingsReactor) {}
    
    private func createSettingView(mainTitle: String, subTitle: String, settingType: SettingType) -> UIView {
        let view = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let stackView = UIStackView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.axis = .vertical
            $0.distribution = .equalSpacing
            $0.alignment = .fill
            $0.spacing = 0
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        let mainTitleLbl = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = mainTitle
            $0.numberOfLines = 1
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = Colors.contentPrimary.color
        }
        
        stackView.addArrangedSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.height.equalTo(22)
        }
        
        let subTitleLbl = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = subTitle
            $0.textAlignment = .natural
            $0.numberOfLines = 2
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = Colors.contentTertiary.color
        }
        
        if !subTitle.isEmpty {
            stackView.addArrangedSubview(subTitleLbl)
            subTitleLbl.snp.makeConstraints {
                $0.height.equalTo(16)
            }
        }
                
        let noticeSw = UISwitch().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.tintColor = Colors.contentPrimary.color
            $0.thumbTintColor = .white
            $0.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }
        
        view.addSubview(noticeSw)
        noticeSw.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-28)
            $0.leading.greaterThanOrEqualTo(stackView.snp.trailing).offset(30)
        }
                                       
        let lineView = self.createLineView()
        view.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.top.lessThanOrEqualTo(stackView.snp.bottom).offset(15)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        guard let _reactor = self.reactor else { return view}
        
        let isOn: Bool
        switch settingType {
        case .basicNotice:
            isOn = _reactor.initialState.isBasicNotification ?? false
            
            noticeSw.rx.isOn
                .changed
                .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
                .distinctUntilChanged()
                .asDriver(onErrorJustReturn: false)
                .drive(onNext: { [weak self] isOn in
                    guard let self = self, let _reactor = self.reactor else { return }
                    Observable.just(SettingsReactor.Action.updateBasicNotification(isOn))
                        .bind(to: _reactor.action)
                        .disposed(by: self.disposeBag)
                })
                .disposed(by: self.disposeBag)
            
            
            _reactor.state.compactMap { $0.isBasicNotification }
            .bind(to: noticeSw.rx.isOn)
            .disposed(by: self.disposeBag)
            
        case .locationNotice:
            isOn = _reactor.initialState.isLocalNotification ?? false
            
            noticeSw.rx.isOn
                .changed
                .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
                .distinctUntilChanged()
                .asDriver(onErrorJustReturn: false)
                .drive(onNext: { [weak self] isOn in
                    guard let self = self, let _reactor = self.reactor else { return }
                    Observable.just(SettingsReactor.Action.updateLocalNotification(isOn))
                        .bind(to: _reactor.action)
                        .disposed(by: self.disposeBag)
                })
                .disposed(by: self.disposeBag)
            
            _reactor.state.compactMap { $0.isLocalNotification }
            .bind(to: noticeSw.rx.isOn)
            .disposed(by: self.disposeBag)
            
            
        case .marketingNoticeAgree:
            isOn = _reactor.initialState.isMarketingNotification ?? false
            
            noticeSw.rx.isOn
                .changed
                .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
                .distinctUntilChanged()
                .asDriver(onErrorJustReturn: false)
                .drive(onNext: { [weak self] isOn in
                    guard let self = self, let _reactor = self.reactor else { return }
                    Observable.just(SettingsReactor.Action.updateMarketingNotification(isOn))
                        .bind(to: _reactor.action)
                        .disposed(by: self.disposeBag)
                })
                .disposed(by: self.disposeBag)
            
            _reactor.state.compactMap { $0.isMarketingNotification }
            .bind(to: noticeSw.rx.isOn)
            .disposed(by: self.disposeBag)
            
        case .clustering:
            isOn = _reactor.initialState.isClustering ?? false
            
            noticeSw.rx.isOn
                .changed
                .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
                .distinctUntilChanged()
                .asDriver(onErrorJustReturn: false)
                .drive(onNext: { [weak self] isOn in
                    guard let self = self, let _reactor = self.reactor else { return }
                    Observable.just(SettingsReactor.Action.updateClustering(isOn))
                        .bind(to: _reactor.action)
                        .disposed(by: self.disposeBag)
                })
                .disposed(by: self.disposeBag)
            
            _reactor.state.compactMap { $0.isClustering }
            .bind(to: noticeSw.rx.isOn)
            .disposed(by: self.disposeBag)
            
        }
        
        noticeSw.isOn = isOn
        
        return view
    }
    
    private func createQuitAccountView(mainTitle: String) -> UIView {
        let view = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
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
            $0.leading.equalTo(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        let lineView = self.createLineView()
        view.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        let quitAccountBtn = UIButton().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(quitAccountBtn)
        quitAccountBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        quitAccountBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self, let _reactor = self.reactor else { return }
                
                Server.getPayRegisterStatus { (isSuccess, value) in
                    if isSuccess {
                        let json = JSON(value)
                        let payCode = json["pay_code"].intValue
                                            
                        switch PaymentStatus(rawValue: payCode) {
                        case .PAY_DEBTOR_USER: // 돈안낸 유저
                            Snackbar().show(message: "현재 회원님께서는 미수금이 있으므로 회원 탈퇴를 할 수 없습니다.")
                            
                        case .CHARGER_STATE_CHARGING: // 충전중
                            Snackbar().show(message: "현재 회원님께서는 충전중이으므로 회원 탈퇴를 할 수 없습니다.")
                                                
                        default:
                            Observable.just(SettingsReactor.Action.moveQuitAccountReasonQuestion)
                                .bind(to: _reactor.action)
                                .disposed(by: self.disposeBag)
                        }
                        
                        printLog(out: "json data : \(json)")
                    } else {
                        Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
                    }
                }
                
                
            })
            .disposed(by: self.disposeBag)
        
        return view
    }
}

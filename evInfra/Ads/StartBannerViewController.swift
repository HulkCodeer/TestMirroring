//
//  AdsViewController.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/08/01.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit
import SDWebImage

internal final class StartBannerViewController: CommonBaseViewController, StoryboardView {
    
    private lazy var dimmedViewBtn = UIButton().then {
        $0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
        $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    private lazy var eventImageView = UIImageView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
        $0.contentMode = .scaleToFill
    }
    
    private lazy var eventImageButton = UIButton().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var buttonContainerView = UIStackView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
    private lazy var closeWithDurationButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.setTitleColor(Colors.contentTertiary.color, for: .normal)
        $0.fontSize = 14
        $0.setTitle("7일간 보지 않기", for: .normal)
    }
    
    private lazy var closeButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.setTitleColor(Colors.contentPrimary.color, for: .normal)
        $0.fontSize = 14
        $0.setTitle("닫기", for: .normal)
    }
    
    private lazy var safeAreaBottomView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
    private let safeAreaInsetBottomHeight = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    
    init(reactor: GlobalAdsReactor) {
        super.init()
        self.reactor = reactor
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .coverVertical
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
        
        let screenWidth = UIScreen.main.bounds.width
        let imgViewHeight = (291 / 375) * screenWidth
        
        self.contentView.backgroundColor = .clear
        
        self.view.addSubview(dimmedViewBtn)
        dimmedViewBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.view.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(imgViewHeight + 54)
            $0.bottom.equalTo(self.contentView.snp.bottom)
        }
        
        self.view.addSubview(safeAreaBottomView)
        safeAreaBottomView.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(safeAreaInsetBottomHeight)
        }
        
        self.containerView.addSubview(buttonContainerView)
        buttonContainerView.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        self.containerView.addSubview(eventImageView)
        eventImageView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(imgViewHeight)
            $0.bottom.equalTo(buttonContainerView.snp.top)
        }
        
        self.containerView.addSubview(eventImageButton)
        eventImageButton.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.equalTo(buttonContainerView.snp.top)
        }

        buttonContainerView.addSubview(closeWithDurationButton)
        closeWithDurationButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(2)
            $0.top.equalToSuperview().offset(8)
            $0.height.equalTo(38)
            $0.width.equalTo(120)
        }

        buttonContainerView.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-2)
            $0.top.equalToSuperview().offset(8)
            $0.height.equalTo(38)
            $0.width.equalTo(57)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable.merge(dimmedViewBtn.rx.tap.asObservable(), closeButton.rx.tap.asObservable())
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                owner.closeStartBannerViewController()
                owner.logEvent(with: .clickCloseBanner, type: owner.closeButton.titleLabel?.text ?? "닫기")
            }.disposed(by: disposeBag)
        
        closeWithDurationButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                UserDefault().saveString(key: UserDefault.Key.AD_KEEP_DATE_FOR_A_WEEK, value: Date().toString())
                owner.closeStartBannerViewController()
                owner.logEvent(with: .clickCloseBanner, type: owner.closeWithDurationButton.titleLabel?.text ?? "7일간 보지 않기")
            }.disposed(by: disposeBag)
    }
    
    internal func bind(reactor: GlobalAdsReactor) {        
        reactor.state.compactMap { $0.startBanner?.img }
            .asDriver(onErrorJustReturn: "")
            .drive(self.eventImageView.rx.bindImage)
            .disposed(by: self.disposeBag)
        
        eventImageButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                guard let banner = reactor.currentState.startBanner else { return }
                guard !banner.extUrl.isEmpty else { return }
                
                let viewcon = NewEventDetailViewController()
                viewcon.eventUrl = banner.extUrl
                self.closeStartBannerViewController()
                self.logClickEvent()
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
            }.disposed(by: disposeBag)
    }
    
    // 앰플리튜드 view_enter 로깅을 위해 필요함
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "시작배너 화면"
        
        logViewEvent()
    }
    
    private func closeStartBannerViewController() {
        self.dimmedViewBtn.backgroundColor = .clear
        GlobalDefine.shared.mainNavi?.dismiss(animated: true)
    }
    
    private func logClickEvent() {
        Observable.just(GlobalAdsReactor.Action.addEventClickCount(self.reactor?.currentState.startBanner?.evtId ?? "") )
            .bind(to: GlobalAdsReactor.sharedInstance.action)
            .disposed(by: self.disposeBag)
        
    }
    
    private func logViewEvent() {
        Observable.just(GlobalAdsReactor.Action.addEventViewCount(self.reactor?.currentState.startBanner?.evtId ?? "") )
            .bind(to: GlobalAdsReactor.sharedInstance.action)
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - Amplitude Logging 이벤트
    private func logEvent(with event: EventType.PromotionEvent, type: String) {
        switch event {
        case .clickBanner:
            guard let banner = self.reactor?.currentState.startBanner else { return }
            let property: [String: Any] = ["bannerType": type,
                                           "adID": banner.evtId,
                                           "adName": banner.evtTitle]
            
            AmplitudeManager.shared.logEvent(type: .promotion(event), property: property)
        case .clickCloseBanner:
            let property: [String: Any] = ["type": type]
            AmplitudeManager.shared.logEvent(type: .promotion(event), property: property)
        default: break
        }
    }
}

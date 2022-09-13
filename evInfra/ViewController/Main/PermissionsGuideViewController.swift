//
//  PermissionsGuideViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/09/01.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import MiniPlengi

internal final class PermissionsGuideViewController: CommonBaseViewController, StoryboardView {
    
    enum PermissionTypes: CaseIterable {
        case location
        
        internal var title: String {
            switch self {
            case .location: return "위치 동의"
            }
        }
        
        internal var description: String {
            switch self {
            case .location: return "내 현재 위치를 기준으로 주변 충전소 찾기, 충전소 경로 안내, 근처의 혜택 정보 및 광고 제공을 위한 필수 정보로 활용됩니다."
            }
        }
        
        internal var typeImage: UIImage {
            switch self {
            case .location: return Icons.iconMapMd.image
            }
        }
    }
    
    // MARK: UI
    
    private lazy var naviTotalView = CommonNaviView().then {        
        $0.naviTitleLbl.text = "권한동의"
        $0.naviBackBtn.isHidden = true
    }
    
    private lazy var totalView = UIView()
    
    private lazy var mainTitleLbl = UILabel().then {
        $0.font = .systemFont(ofSize: 22, weight: .semibold)
        $0.textColor = Colors.contentPrimary.color
        $0.text = "더 나은 충전 생활을 위해"
        $0.textAlignment = .natural
    }
    
    private lazy var subTitleLbl = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.text = "아래의 권한 동의가 필요합니다."
        $0.textAlignment = .natural
    }
    
    private lazy var permissionStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 24
    }
    
    private lazy var nextBtn = StickButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 80), level: .primary).then {
        $0.rectBtn.setTitle("권한 동의하기", for: .normal)
    }
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()        
                
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(nextBtn)
        nextBtn.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        self.contentView.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(nextBtn.snp.top)
        }
        
        self.totalView.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        self.totalView.addSubview(subTitleLbl)
        subTitleLbl.snp.makeConstraints {
            $0.top.equalTo(mainTitleLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        self.totalView.addSubview(permissionStackView)
        permissionStackView.snp.makeConstraints {
            $0.top.equalTo(subTitleLbl.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview()
        }
        
        for type in PermissionTypes.allCases {
            permissionStackView.addArrangedSubview(self.createPermissionView(type: type))
        }
    }
    
    // MARK: FUNC
    
    private func createPermissionView(type: PermissionTypes) -> UIView {
        let view = UIView()
        
        let imgTotalView = UIView().then {
            $0.IBcornerRadius = 48/2
            $0.backgroundColor = Colors.backgroundPositiveLight.color
        }
        view.addSubview(imgTotalView)
        imgTotalView.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.width.height.equalTo(48)
        }
        
        let imgView = UIImageView().then {
            $0.image = Icons.iconCurrentLocationMd.image
            $0.tintColor = Colors.backgroundPositive.color
        }
        imgTotalView.addSubview(imgView)
        imgView.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.center.equalToSuperview()
        }
                
        let mainTitleLbl = UILabel().then {
            $0.text = type.title
            $0.textAlignment = .natural
            $0.numberOfLines = 1
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = Colors.backgroundAlwaysDark.color
            $0.sizeToFit()
        }
        
        view.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(imgTotalView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        let subTitleLbl = UILabel().then {
            $0.text = type.description
            $0.textAlignment = .natural
            $0.numberOfLines = 3
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = Colors.contentTertiary.color
            $0.sizeToFit()
        }
        
        view.addSubview(subTitleLbl)
        subTitleLbl.snp.makeConstraints {
            $0.top.equalTo(mainTitleLbl.snp.bottom).offset(4)
            $0.leading.equalTo(imgTotalView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.lessThanOrEqualTo(100)
        }        
        return view
    }
    
    // MARK: REACTOR
    
    init(reactor: PermissionsGuideReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    internal func bind(reactor: PermissionsGuideReactor) {
        nextBtn.rectBtn.rx.tap
            .asDriver()
            .drive(onNext: {
                LocationWorker.shared.locationStatusObservable
                    .subscribe(onNext: { status in                        
                        switch status {
                        case .authorizedAlways, .authorizedWhenInUse:
                            LocationWorker.shared.fetchLocation()
                            
                            if Plengi.initialize(clientID: "zeroone",
                                           clientSecret: "zeroone)Q@Eh(4",
                                                 echoCode: "\(MemberManager.shared.mbId)") == .SUCCESS {                                
                                _ = Plengi.start()
                            }
                                                        
                            GlobalFunctionSwift.showPopup(title: "위치 권한을 항상 허용으로\n변경해주세요.", message: "위치정보를 항상 허용으로 변경해주시면,\n근처의 충전소 정보 및 풍부한 혜택 정보를\n 알려드릴게요.정확한 위치를 위해 ‘설정>EV Infra>위치'\n에서 항상 허용으로 변경해주세요.", confirmBtnTitle: "항상 허용하기", confirmBtnAction: { [weak self] in
                                guard let self = self else { return }
                                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                                    if UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                }
                                self.moveMainViewcon()
                            }, cancelBtnTitle: "유지하기", cancelBtnAction: { [weak self] in
                                guard let self = self else { return }
                                self.moveMainViewcon()
                            }, dimmedBtnAction: {})
                            
                        case .denied: self.moveMainViewcon()
                        default: break
                        }
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func moveMainViewcon() {
        MemberManager.shared.isFirstInstall = "isFirstInstall"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let reactor = MainReactor(provider: RestApi())
        let mainViewcon = storyboard.instantiateViewController(ofType: MainViewController.self)
        mainViewcon.reactor = reactor
        let leftViewController = storyboard.instantiateViewController(ofType: LeftViewController.self)
        
        let appToolbarController = AppToolbarController(rootViewController: mainViewcon)
        appToolbarController.delegate = mainViewcon
        let ndController = AppNavigationDrawerController(rootViewController: appToolbarController, leftViewController: leftViewController)
        GlobalDefine.shared.mainNavi?.setViewControllers([ndController], animated: true)
    }
}

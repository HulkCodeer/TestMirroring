//
//  NewLeftViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/08/08.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON
import UIKit
import ReusableKit

internal final class NewLeftViewController: CommonBaseViewController, StoryboardView {
    private enum Reusable {
        static let leftViewMenuItem = ReusableCell<LeftViewMenuItem>(nibName: LeftViewMenuItem.reuseID)        
    }
        
    enum ViewHeightConst {
        static var loginViewHeight: CGFloat = 165
        static var nonLoginViewHeigt: CGFloat = 121
    }
    
    // MARK: UI
    
    private lazy var menuContentView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    private lazy var dimView = UIButton().then {
        $0.backgroundColor = .darkGray.withAlphaComponent(0.5)
        $0.isHighlighted = false
    }
    
    private lazy var userInfoTotalView = UIView()
    
    private lazy var loginTotalView = UIView()
    
    private lazy var profileTotalView = UIView()
    
    private lazy var profileImgView = UIImageView().then {
        $0.image = Icons.iconProfileEmpty.image
    }
    
    private lazy var nicknameLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
    }
    
    private lazy var moveMyInfoBtn = UIButton()
    
    private lazy var loginUserBerryInfoTotalView = UIView().then {
        $0.backgroundColor = Colors.backgroundPositiveLight.color
        $0.IBcornerRadius = 8
    }
    
    private lazy var myBerryGuideLbl = UILabel().then {
        $0.text = "MY 베리"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = Colors.gr6.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
    }
    
    private lazy var myBerryGuideArrow = ChevronArrow.init(.size20(.right)).then {
        $0.IBimageColor = Colors.gr3.color
    }
    
    private lazy var moveMyPointBtn = UIButton()
    
    private lazy var myBerryRefreshTotalView = UIView().then {
        $0.IBcornerRadius = 20/2
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
    private lazy var myBerryRefreshImgView = UIImageView().then {
        $0.image = Icons.iconRefreshXs.image
        $0.tintColor = Colors.gr4.color
    }
    
    private lazy var myBerryRefreshBtn = UIButton()
    
    private lazy var myBerryLbl = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = Colors.gr6.color
        $0.textAlignment = .right
        $0.numberOfLines = 1
    }
    
    private lazy var useMyBerrySettingTotalView = UIView()
    
    private lazy var useAllMyBerryGuideLbl = UILabel().then {
        $0.text = "충전 시 베리 전액 사용"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentSecondary.color
        $0.textAlignment = .left
        $0.numberOfLines = 1
    }
    
    private lazy var useAllMyBerrySw = UISwitch().then {
        $0.tintColor = Colors.contentPrimary.color
        $0.thumbTintColor = .white
        $0.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    private lazy var useAllMyBerryBtn = UIButton()
    
    private lazy var nonLoginTotalView = UIView()
    
    private lazy var nonLoginProfileImgView = UIImageView().then {
        $0.image = Icons.iconProfileEmpty.image
    }
    
    private lazy var loginInduceLbl = UILabel().then {
        $0.text = "로그인을 해주세요"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
    }
    
    private lazy var loginInduceArrow = ChevronArrow.init(.size20(.right)).then {
        $0.IBimageColor = Colors.contentPrimary.color
    }
    
    private lazy var moveLoginBtn = UIButton()
    
    private lazy var nonLoginUserBerryInfoTotalView = UIView().then {
        $0.backgroundColor = Colors.backgroundDisabled.color
        $0.IBcornerRadius = 8
    }
    
    private lazy var nonLoginMyBerryGuideLbl = UILabel().then {
        $0.text = "MY 베리"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = Colors.contentDisabled.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
    }
        
    
    private lazy var nonLoginMyBerryLbl = UILabel().then {
        $0.text = "-"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = Colors.contentDisabled.color
        $0.textAlignment = .right
        $0.numberOfLines = 1
    }
    
    
    private lazy var menuListTotalView = UIView().then {
        $0.backgroundColor = Colors.backgroundSecondary.color
    }
    
    private lazy var menuCategoryTypeStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 0
        $0.backgroundColor = .clear
    }
    
    private lazy var tableView = UITableView().then {
        $0.register(Reusable.leftViewMenuItem)
        $0.register(UINib(nibName: "LeftViewTableHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "LeftViewTableHeader")
        $0.backgroundColor = .white
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 48
        $0.allowsSelection = true
        $0.allowsSelectionDuringEditing = false
        $0.isMultipleTouchEnabled = false
        $0.allowsMultipleSelection = false
        $0.allowsMultipleSelectionDuringEditing = false
        $0.contentInset = .zero
        $0.bounces = false
        $0.delegate = self
        $0.dataSource = self
    }
                        
    // MARK: VARIABLE
    
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        view.isOpaque = false
        view.backgroundColor = .clear
        
        view.addSubview(dimView)
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(menuContentView)
        menuContentView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.equalTo(view.frame.width * 0.7)
        }
        
        menuContentView.addSubview(userInfoTotalView)
        userInfoTotalView.snp.makeConstraints {            
            $0.top.equalToSuperview().offset(UIScreen.main.bounds.height > 667 ? 45 : 18)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ViewHeightConst.loginViewHeight)
        }
        
        menuContentView.addSubview(menuListTotalView)
        menuListTotalView.snp.makeConstraints {
            $0.top.equalTo(userInfoTotalView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        let line = self.createLineView(color: Colors.borderOpaque.color)
        userInfoTotalView.addSubview(line)
        line.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        // 로그인 되었을때 뷰
        userInfoTotalView.addSubview(loginTotalView)
        loginTotalView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(line.snp.top)
        }
        
        loginTotalView.addSubview(profileTotalView)
        profileTotalView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }
                        
        profileTotalView.addSubview(profileImgView)
        profileImgView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        
        profileTotalView.addSubview(nicknameLbl)
        nicknameLbl.snp.makeConstraints {
            $0.leading.equalTo(profileImgView.snp.trailing).offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        profileTotalView.addSubview(moveMyInfoBtn)
        moveMyInfoBtn.snp.makeConstraints {
            $0.leading.equalTo(profileImgView.snp.leading)
            $0.trailing.equalTo(nicknameLbl.snp.trailing)
            $0.height.equalTo(nicknameLbl.snp.height)
        }
        
        loginTotalView.addSubview(loginUserBerryInfoTotalView)
        loginUserBerryInfoTotalView.snp.makeConstraints {
            $0.top.equalTo(profileTotalView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        loginUserBerryInfoTotalView.addSubview(myBerryGuideLbl)
        myBerryGuideLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(22)
        }
        
        loginUserBerryInfoTotalView.addSubview(myBerryGuideArrow)
        myBerryGuideArrow.snp.makeConstraints {
            $0.leading.equalTo(myBerryGuideLbl.snp.trailing)
            $0.centerY.equalTo(myBerryGuideLbl.snp.centerY)
            $0.width.height.equalTo(20)
        }
        
        loginUserBerryInfoTotalView.addSubview(moveMyPointBtn)
        moveMyPointBtn.snp.makeConstraints {
            $0.leading.equalTo(loginUserBerryInfoTotalView.snp.leading)
            $0.trailing.equalTo(myBerryGuideArrow.snp.trailing)
            $0.height.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        loginUserBerryInfoTotalView.addSubview(myBerryRefreshTotalView)
        myBerryRefreshTotalView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-12)
            $0.width.height.equalTo(20)
        }
        
        myBerryRefreshTotalView.addSubview(myBerryRefreshImgView)
        myBerryRefreshImgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        myBerryRefreshTotalView.addSubview(myBerryRefreshBtn)
        myBerryRefreshBtn.snp.makeConstraints {
            $0.center.equalTo(myBerryRefreshImgView.center)
            $0.width.height.equalTo(44)
        }
        
        loginUserBerryInfoTotalView.addSubview(myBerryLbl)
        myBerryLbl.snp.makeConstraints {
            $0.trailing.equalTo(myBerryRefreshTotalView.snp.leading).offset(-6)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(26)
        }
        
        loginTotalView.addSubview(useMyBerrySettingTotalView)
        useMyBerrySettingTotalView.snp.makeConstraints {
            $0.top.equalTo(loginUserBerryInfoTotalView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        useMyBerrySettingTotalView.addSubview(useAllMyBerryGuideLbl)
        useAllMyBerryGuideLbl.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(22)
        }
        
        useMyBerrySettingTotalView.addSubview(useAllMyBerrySw)
        useAllMyBerrySw.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(useAllMyBerryGuideLbl)
        }
        
        useMyBerrySettingTotalView.addSubview(useAllMyBerryBtn)
        useAllMyBerryBtn.snp.makeConstraints {
            $0.center.equalTo(useAllMyBerrySw)
            $0.width.height.equalTo(useAllMyBerrySw)
        }
        
        menuListTotalView.addSubview(menuCategoryTypeStackView)
        menuCategoryTypeStackView.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.width.equalTo(70)
        }
                
        // 로그인 안되었을때 뷰
        userInfoTotalView.addSubview(nonLoginTotalView)
        nonLoginTotalView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.greaterThanOrEqualTo(line.snp.top).offset(-16)
        }
                        
        nonLoginTotalView.addSubview(nonLoginProfileImgView)
        nonLoginProfileImgView.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        
        nonLoginTotalView.addSubview(loginInduceLbl)
        loginInduceLbl.snp.makeConstraints {
            $0.leading.equalTo(nonLoginProfileImgView.snp.trailing).offset(16)
            $0.centerY.equalTo(nonLoginProfileImgView.snp.centerY)
            $0.height.equalTo(24)
        }
        
        nonLoginTotalView.addSubview(loginInduceArrow)
        loginInduceArrow.snp.makeConstraints {
            $0.leading.equalTo(loginInduceLbl.snp.trailing)
            $0.centerY.equalTo(loginInduceLbl.snp.centerY)
            $0.width.height.equalTo(20)
        }
                
        nonLoginTotalView.addSubview(moveLoginBtn)
        moveLoginBtn.snp.makeConstraints {
            $0.leading.equalTo(nonLoginProfileImgView.snp.leading)
            $0.trailing.equalTo(loginInduceArrow.snp.trailing)
            $0.height.equalTo(loginInduceLbl.snp.height)
        }
        
        nonLoginTotalView.addSubview(nonLoginUserBerryInfoTotalView)
        nonLoginUserBerryInfoTotalView.snp.makeConstraints {
            $0.top.equalTo(nonLoginProfileImgView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        nonLoginUserBerryInfoTotalView.addSubview(nonLoginMyBerryGuideLbl)
        nonLoginMyBerryGuideLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(22)
        }
    
        nonLoginUserBerryInfoTotalView.addSubview(nonLoginMyBerryLbl)
        nonLoginMyBerryLbl.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-12)
            $0.width.height.equalTo(20)
        }
        
        menuListTotalView.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.leading.equalTo(menuCategoryTypeStackView.snp.trailing)
            $0.top.trailing.bottom.equalToSuperview()
        }
                
        profileImgView.IBcornerRadius = 32/2
        profileImgView.sd_setImage(with: URL(string:"\(Const.urlProfileImage)\(MemberManager.shared.profileImage)"), placeholderImage: Icons.iconProfileEmpty.image)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let displayNickname = MemberManager.shared.memberNickName
        nicknameLbl.text = displayNickname.count > 10 ? "\(displayNickname.substring(to: 10))..." : displayNickname
        
        moveMyInfoBtn.rx.tap
            .asDriver()
            .drive(onNext: {
                let memberStoryboard = UIStoryboard(name : "Member", bundle: nil)
                let mypageVC = memberStoryboard.instantiateViewController(ofType: MyPageViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: mypageVC)
            })
            .disposed(by: self.disposeBag)
        
        moveLoginBtn.rx.tap
            .asDriver()
            .drive(onNext: {
                let loginStoryboard = UIStoryboard(name : "Login", bundle: nil)
                let loginVC = loginStoryboard.instantiateViewController(ofType: LoginViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: loginVC)
            })
            .disposed(by: self.disposeBag)
        
        moveMyPointBtn.rx.tap
            .asDriver()
            .drive(onNext: {
                let viewcon = UIStoryboard(name : "Charge", bundle: nil).instantiateViewController(ofType: PointViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
            })
            .disposed(by: self.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        MemberManager.shared.tryToLoginCheck { [weak self] isLogin in
            guard let self = self, let _reactor = self.reactor else { return }
            self.nonLoginTotalView.isHidden = isLogin
            self.loginTotalView.isHidden = !isLogin
            
            self.userInfoTotalView.snp.updateConstraints {
                $0.height.equalTo(isLogin ? ViewHeightConst.loginViewHeight : ViewHeightConst.nonLoginViewHeigt)
            }
            
            guard isLogin else { return }
            Observable.just(LeftViewReactor.Action.getMyBerryPoint)
                .bind(to: _reactor.action)
                .disposed(by: self.disposeBag)                        
        }
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationDrawerController?.reHideStatusBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationDrawerController?.reShowStatusBar()
    }
    
    func bind(reactor: LeftViewReactor) {
        MemberManager.shared.tryToLoginCheck { [weak self] isLogin in
            guard let self = self, isLogin else { return }
            Observable.just(LeftViewReactor.Action.getMyBerryPoint)
                .bind(to: reactor.action)
                .disposed(by: self.disposeBag)
        }
                
        for menuCategoryType in LeftViewReactor.MenuCategoryType.allCases {
            if menuCategoryType == .battery && MemberManager.shared.deviceId.isEmpty {
                continue
            }
            
            let menuTypeView = self.createMenuTypeView(menuCategoryType: menuCategoryType, reactor: reactor)
            menuTypeView.snp.makeConstraints {
                $0.width.height.equalTo(70)
            }
            self.menuCategoryTypeStackView.addArrangedSubview(menuTypeView)
        }
        
        reactor.state.compactMap { $0.myBerryPoint }
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] point in
                guard let self = self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.myBerryRefreshImgView.layer.removeAnimation(forKey: "transform.rotation.z")
                }
                self.myBerryLbl.text = point
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.isAllBerry }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isOn in
                guard let self = self else { return }
                self.useAllMyBerrySw.isOn = isOn
                guard isOn else { return }
                let message = "0".equals(reactor.currentState.myBerryPoint ?? "") ? "베리가 적립되면 다음 충전 시 베리가 자동으로 전액 사용됩니다." : "다음 충전 후 결제 시 베리가 전액 사용됩니다."
                Snackbar().show(message: "\(message)")
            })
            .disposed(by: self.disposeBag)
        
        dimView.rx.tap
            .asDriver()
            .drive(with: self) { owenr, _ in
                owenr.dismiss(animated: false)
            }
            .disposed(by: disposeBag)
        
        myBerryRefreshBtn.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let animation = CABasicAnimation(keyPath: "transform.rotation.z")
                let direction = 1.0
                animation.toValue = NSNumber(value: .pi * 2 * direction)
                animation.duration = 1
                animation.isCumulative = true
                animation.repeatCount = .infinity
                self.myBerryRefreshImgView.layer.add(animation, forKey: "transform.rotation.z")
                
                Observable.just(LeftViewReactor.Action.refreshBerryPoint)
                    .bind(to: reactor.action)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: self.disposeBag)
                        
        useAllMyBerryBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                switch (MemberManager.shared.hasPayment, MemberManager.shared.hasMembership) {
                case (false, false):
                    guard !self.useAllMyBerrySw.isOn else { return }
                    let popupModel = PopupModel(title: "회원카드를 발급하시겠어요?",
                                                message: "베리는 회원카드 발급 후\n충전 시 할인 받을 수 있어요.",
                                                confirmBtnTitle: "네 발급할게요.", cancelBtnTitle: "다음에 할게요.",
                                                confirmBtnAction: {
                        let viewcon = MembershipGuideViewController()
                        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                    }, textAlignment: .center)
                        
                    let popup = VerticalConfirmPopupViewController(model: popupModel)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                    })
                    
                case (false, true):
                    guard !self.useAllMyBerrySw.isOn else { return }
                    let popupModel = PopupModel(title: "결제 카드를 확인해주세요",
                                                message: "현재 회원님의 결제정보에 오류가 있어\n다음 충전 시 베리를 사용할 수 없어요.",
                                                confirmBtnTitle: "결제정보 확인하러가기", cancelBtnTitle: "다음에 할게요.",
                                                confirmBtnAction: {
                        
                        Server.getPayRegisterStatus { (isSuccess, value) in
                            if isSuccess {
                                let json = JSON(value)
                                let payCode = json["pay_code"].intValue
                                                    
                                switch PaymentStatus(rawValue: payCode) {
                                case .PAY_NO_CARD_USER, .PAY_NO_USER: // 카드등록 아니된 멤버
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                        let viewcon = UIStoryboard(name : "Member", bundle: nil).instantiateViewController(ofType: MyPayinfoViewController.self)                                                                                                                        
                                        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                                    })
                                                        
                                case .PAY_DEBTOR_USER: // 돈안낸 유저
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                        let viewcon = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(ofType: RepayListViewController.self)
                                        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                                    })
                                    
                                default: self.dismiss(animated: true)
                                }
                            } else {
                                self.dismiss(animated: true)
                                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
                            }
                        }
                        
                    }, cancelBtnAction: {
                        self.dismiss(animated: true)
                    }, textAlignment: .center)
                                            
                    let popup = VerticalConfirmPopupViewController(model: popupModel)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                    })
                    
                case (true, false):
                    guard !self.useAllMyBerrySw.isOn else { return }
                    let popupModel = PopupModel(title: "더 많은 충전소에서\n베리를 적립해보세요!",
                                                message: "회원카드 발급 시 환경부, 한국전력 등\n더 많은 충전소에서 적립할 수 있어요.",
                                                confirmBtnTitle: "회원카드 안내 보러가기", cancelBtnTitle: "다음에 할게요.",
                                                confirmBtnAction: {
                        let viewcon = MembershipGuideViewController()
                        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                    }, textAlignment: .center)
                        
                    let popup = VerticalConfirmPopupViewController(model: popupModel)
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                    
                case (true, true):
                    Observable.just(LeftViewReactor.Action.setIsAllBerry(!self.useAllMyBerrySw.isOn))
                        .bind(to: reactor.action)
                        .disposed(by: self.disposeBag)
                                
                }
            })
            .disposed(by: self.disposeBag)
        
        GlobalDefine.shared.isUseAllBerry
            .filter { $0 }
            .map { isUseAllBerry in  LeftViewReactor.Action.setIsAllBerry(isUseAllBerry) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
    
    private func createMenuTypeView(menuCategoryType: LeftViewReactor.MenuCategoryType, reactor: LeftViewReactor) -> UIView {
        let view = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
            $0.backgroundColor = menuCategoryType == reactor.currentState.menuCategoryType ? Colors.backgroundPrimary.color : .clear
        }
                       
        let menuImgView = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.image = menuCategoryType.menuImgView
            $0.tintColor = Colors.backgroundAlwaysDark.color
        }
        
        view.addSubview(menuImgView)
        menuImgView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        
        let menuTitleLbl = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = menuCategoryType.menuTitle
            $0.numberOfLines = 1
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = Colors.backgroundAlwaysDark.color
            $0.textAlignment = .center
        }

        view.addSubview(menuTitleLbl)
        menuTitleLbl.snp.makeConstraints {
            $0.top.equalTo(menuImgView.snp.bottom).offset(3)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(16)
            $0.bottom.equalToSuperview().offset(-9)
        }
        
        let btn = UIButton().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        view.addSubview(btn)
        btn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        btn.rx.tap
            .map { LeftViewReactor.Action.changeMenuCategoryType(menuCategoryType) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.menuCategoryType }
            .asDriver(onErrorJustReturn: LeftViewReactor.MenuCategoryType.mypage)
            .drive(onNext: { [weak self] type in
                guard let self = self else { return }
                view.backgroundColor = menuCategoryType == type ? Colors.backgroundPrimary.color : .clear
                self.tableView.reloadData()
            })
            .disposed(by: self.disposeBag)
        
        return view
    }
        
    // 각 게시판에 badge
    private func setNewBadge(cell: LeftViewMenuItem, index: IndexPath) {
        guard let _reactor = self.reactor else {
            return
        }
        cell.newBadge.isHidden = true
        let latestIds = Board.sharedInstance.latestBoardIds

        switch _reactor.currentState.menuCategoryType {
        case .mypage:
            if index.section == 1 {
                if index.row == 0 { // 미수금 표시
                    if UserDefault().readBool(key: UserDefault.Key.HAS_FAILED_PAYMENT) {
                        cell.newBadge.isHidden = false
                    }
                }
            }

        case .community:
            if index.section == 0 {
                switch index.row {
                case 0:
                    if let latestNoticeId = latestIds[Board.KEY_NOTICE] {
                        let noticeId = UserDefault().readInt(key: UserDefault.Key.LAST_NOTICE_ID)
                        if noticeId < latestNoticeId {
                            cell.newBadge.isHidden = false
                        }
                    }

                case 1:
                    if let latestFreeBoardId = latestIds[Board.KEY_FREE_BOARD] {
                        let freeId = UserDefault().readInt(key: UserDefault.Key.LAST_FREE_ID)
                        if freeId < latestFreeBoardId {
                            cell.newBadge.isHidden = false
                        }
                    }

                case 2:
                    if let latestChargerBoardId = latestIds[Board.KEY_CHARGER_BOARD] {
                        let chargerId = UserDefault().readInt(key: UserDefault.Key.LAST_CHARGER_ID)
                        if chargerId < latestChargerBoardId {
                            cell.newBadge.isHidden = false
                        }
                    }

                default:
                    cell.newBadge.isHidden = true
                }
            }

            if index.section == 1 {
                let title: String = _reactor.currentState.menuCategoryType.menuList[index.section].smallMenuList[index.row]
                if let boardInfo = Board.sharedInstance.getBoardNewInfo(title: title) {
                    let companyId = UserDefault().readInt(key: boardInfo.shardKey!)
                    if companyId < boardInfo.brdId! {
                        cell.newBadge.isHidden = false
                    }
                }
            }
       
        default:
            cell.newBadge.isHidden = true
        }
    }

    private func updateMyPageTitle(cell: LeftViewMenuItem, index: IndexPath) {
        if index.row == 0 {
            if MemberManager.shared.hasPayment {
                cell.menuLabel.text = "결제 정보 관리"
            } else {
                cell.menuLabel.text = "결제 정보 등록"
            }
        } else if index.row == 1 {
            if MemberManager.shared.hasMembership {
                cell.menuLabel.text = "회원카드 관리"
            } else {
                cell.menuLabel.text = "회원카드 신청"
            }
        }
    }
}

extension NewLeftViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let _reactor = self.reactor else { return 0 }
        return _reactor.currentState.menuCategoryType.menuList.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let _reactor = self.reactor else { return UIView() }
        let headerView = Bundle.main.loadNibNamed("LeftViewTableHeader", owner: self, options: nil)?.first as! LeftViewTableHeader
        let headerValue = _reactor.currentState.menuCategoryType.menuList[section].mediumCategory.rawValue
        headerView.cellTitle.text = headerValue
        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _reactor = self.reactor else { return 0 }
        return _reactor.currentState.menuCategoryType.menuList[section].smallMenuList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let _reactor = self.reactor else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(ofType: LeftViewMenuItem.self, for: indexPath)
        cell.menuLabel.text = _reactor.currentState.menuCategoryType.menuList[indexPath.section].smallMenuList[indexPath.row]
        
        // 게시판, 이벤트 등에 새글 표시
        setNewBadge(cell: cell, index: indexPath)

        if _reactor.currentState.menuCategoryType == .mypage &&
            _reactor.currentState.menuCategoryType.menuList[indexPath.section].mediumCategory == .pay {
            updateMyPageTitle(cell: cell, index: indexPath)
        }

        // 설정 - 버전정보 표시
        if _reactor.currentState.menuCategoryType == .settings &&
            "버전 정보".equals(_reactor.currentState.menuCategoryType.menuList[indexPath.section].smallMenuList[indexPath.row]) {
            cell.menuContent.isHidden = false
            cell.menuContent.text = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
        } else {
            cell.menuContent.isHidden = true
        }
        return cell
    }

    func tableView(_ tableView : UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _reactor = self.reactor else { return }
        tableView.deselectRow(at: indexPath, animated: false)
        _reactor.currentState.menuCategoryType.menuList[indexPath.section].moveViewController(index: indexPath)
    }
}

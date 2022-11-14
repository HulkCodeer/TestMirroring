//
//  MembershipIssuanceCompleteViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/10/23.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class MembershipCardIssuanceCompleteViewController: CommonBaseViewController, StoryboardView {
    // MARK: UI
    
    private lazy var naviTotalView = CommonNaviView().then {
        $0.naviTitleLbl.text = "EV Pay 카드 신청 완료"
    }
    
    private lazy var totalScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private lazy var completeWelcomeGuideTotalView = UIView()
    
    private lazy var completeWelcomeCheckRoundTotalView = UIView().then {
        $0.backgroundColor = Colors.backgroundPositiveLight.color
        $0.IBcornerRadius = 79 / 2
    }
    
    private lazy var completeWelcomeCheckImgView = UIImageView().then {
        $0.image = Icons.iconCheckLg.image
        $0.tintColor = Colors.contentPositive.color
    }
    
    private lazy var completeWelcomeGuideLbl = UILabel().then {
        $0.text = "회원카드 신청 완료"
        $0.font = .systemFont(ofSize: 22, weight: .semibold)
        $0.textColor = Colors.contentPrimary.color
    }
    
    private lazy var shipmentStatusView = ShipmentStatusView(frame: .zero)
                    
    private lazy var buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.spacing = 8
    }
            
    private lazy var moveMembershipCardBtn = RectButton(level: .primary).then {
        $0.setTitle("확인", for: .normal)
    }
            
    // MARK: VARIABLE
    
    internal weak var delegate: LeftViewReactorDelegate?
    
    // MARK: SYSTEM FUNC
    
    init(reactor: MembershipCardIssuanceCompleteReactor) {
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
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
        
        self.contentView.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-19)
            $0.height.equalTo(44)
        }
                
        buttonStackView.addArrangedSubview(moveMembershipCardBtn)
        
        self.contentView.addSubview(totalScrollView)
        totalScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.width.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(buttonStackView.snp.top)
        }
        
        totalScrollView.addSubview(self.completeWelcomeGuideTotalView)
        completeWelcomeGuideTotalView.snp.makeConstraints {
            $0.width.equalTo(totalScrollView)
            $0.top.centerX.equalToSuperview()
        }
        
        completeWelcomeGuideTotalView.addSubview(completeWelcomeCheckRoundTotalView)
        completeWelcomeCheckRoundTotalView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(32)
            $0.width.height.equalTo(79)
        }
        
        completeWelcomeCheckRoundTotalView.addSubview(completeWelcomeCheckImgView)
        completeWelcomeCheckImgView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        
        completeWelcomeGuideTotalView.addSubview(completeWelcomeGuideLbl)
        completeWelcomeGuideLbl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(completeWelcomeCheckRoundTotalView.snp.bottom).offset(24)
            $0.bottom.equalToSuperview().offset(-32)
        }
        
        let lineView = self.createLineView(color: Colors.backgroundSecondary.color)
        totalScrollView.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.width.centerX.equalToSuperview()
            $0.height.equalTo(4)
            $0.top.equalTo(completeWelcomeGuideTotalView.snp.bottom)
        }
        
        totalScrollView.addSubview(shipmentStatusView)
        shipmentStatusView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom)            
            $0.width.centerX.bottom.equalToSuperview()
        }
    }
            
    // MARK: FUNC
    
    func bind(reactor: MembershipCardIssuanceCompleteReactor) {
        self.shipmentStatusView.bind(reactor: reactor)
        
        Observable.just(MembershipCardIssuanceCompleteReactor.Action.membershipCardInfo)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
                       
        moveMembershipCardBtn.rx.tap
            .asDriver()
            .drive(with: self) { obj, _ in
                // QR 충전에서 회원카드 없는 CASE로 등록하러 온 경우
                guard let _mainNavi = GlobalDefine.shared.mainNavi else { return }
                if let _vc = _mainNavi.containsView(ofKind: NewPaymentQRScanViewController.self) {
                    Snackbar().show(message: "EV Pay카드 발급이 완료되었어요.")
                    _ = _mainNavi.popToViewController(_vc, animated: true)
                    return
                }
                
                // 사이드 메뉴에서 베리 전액 설정 시 회원카드 없는 CASE로 등록하러 온 경우
                if let _vc = _mainNavi.containsView(ofKind: NewLeftViewController.self), let _delegate = obj.delegate {
                    Snackbar().show(message: "EV Pay카드 발급이 완료되었어요.")
                    _delegate.completeResiterMembershipCard()
                    _ = _mainNavi.popToViewController(_vc, animated: true)
                    return
                }
                
                let viewcon = UIStoryboard(name : "Membership", bundle: nil).instantiateViewController(ofType: MembershipCardViewController.self)
                viewcon.fromViewType = .membershipCardComplete
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
            }
            .disposed(by: self.disposeBag)                
    }
    
}

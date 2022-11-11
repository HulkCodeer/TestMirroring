//
//  MembershipCardViewController.swift
//  evInfra
//
//  Created by bulacode on 18/09/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import SwiftyJSON
import ReactorKit
import RxViewController

internal final class MembershipCardViewController: CommonBaseViewController, StoryboardView {    
    
    enum FromViewType {
        case membershipCardComplete
        case none
    }
    
    // MARK: UI
        
    private lazy var commonNaviView = CommonNaviView().then {
        $0.naviTitleLbl.text = "EV Pay 카드관리"
    }
    
    private lazy var partnershipListView = PartnershipListView(frame: .zero).then {        
        $0.delegate = self        
    }
    
    // MARK: VARIABLE
    
    private var paymentStatus: PaymentStatus = .none
    
    internal var fromViewType: FromViewType = .none
    
    // MARK: SYSTEM FUNC
    
    init(reactor: MembershipCardReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        self.contentView.addSubview(commonNaviView)
        commonNaviView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
        
        self.contentView.addSubview(partnershipListView)
        partnershipListView.snp.makeConstraints {
            $0.top.equalTo(commonNaviView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
            
    // MARK: REACTORKIT

    func bind(reactor: MembershipCardReactor) {
        Observable.just(MembershipCardReactor.Action.loadPaymentStatus)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.rx.viewWillAppear
            .asDriver()
            .drive(with: self) { obj, _ in
                MemberManager.shared.tryToLoginCheck { isLogin in
                    guard isLogin else {
                        MemberManager.shared.showLoginAlert()
                        return
                    }
                    Observable.just(MembershipCardReactor.Action.membershipCardInfo)
                        .bind(to: reactor.action)
                        .disposed(by: obj.disposeBag)
                }
                
            }
            .disposed(by: self.disposeBag)
                        
        reactor.state.compactMap { $0.membershipCardInfo }
            .asDriver(onErrorJustReturn: MembershipCardInfo(JSON.null))
            .drive(with: self) { obj, model in
                self.partnershipListView.fromViewType = self.fromViewType
                self.partnershipListView.showInfoView(info: model)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.isConfirmDelivery }
            .filter { $0 }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { obj, isConfirmDelivery in
                Observable.just(MembershipCardReactor.Action.membershipCardInfo)
                    .bind(to: reactor.action)
                    .disposed(by: obj.disposeBag)
            }
            .disposed(by: self.disposeBag)
    }
}

extension MembershipCardViewController: MembershipReissuanceInfoDelegate {
    func reissuanceComplete() {        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            Snackbar().show(message: "재발급 신청이 완료되었습니다.")
        })
    }
}

extension MembershipCardViewController: PartnershipListViewDelegate {
    func addNewPartnership() {
    }
    
    func showEvinfraMembershipInfo(info : MembershipCardInfo) {
        let viewcon = UIStoryboard(name: "Membership", bundle: nil).instantiateViewController(ofType: MembershipInfoViewController.self)
        viewcon.setCardInfo(info : info)
        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
    }
    
    func showLotteRentInfo(){
        let viewcon = UIStoryboard(name: "Membership", bundle: nil).instantiateViewController(ofType: LotteRentInfoViewController.self)
        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
    }
    
    func moveMembershipUseGuideView() {
        let viewcon = MembershipUseGuideViewController()
        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
    }
    
    func moveReissuanceView(info: MembershipCardInfo) {
        let reactor = MembershipReissuanceReactor(provider: RestApi())
        let viewcon = MembershipReissuanceViewController()
        viewcon.reactor = reactor
        reactor.cardNo = info.displayCardNo
        viewcon.delegate = self
        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
    }
    
    func paymentStatusInfo() -> PaymentStatus {
        self.paymentStatus
    }
    
    func showShipmentStatusView() {
        guard let _reactor = self.reactor else { return }
        let viewcon = MembershipCardShipmentStatusViewController(reactor: _reactor)
        viewcon.view.frame = GlobalDefine.shared.mainNavi?.view.bounds ?? UIScreen.main.bounds
        self.addChild(viewcon)
        self.view.addSubview(viewcon.view)
    }
}

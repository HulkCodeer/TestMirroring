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

internal final class MembershipCardViewController: CommonBaseViewController, StoryboardView {    
    
    enum FromViewType {
        case membershipCardComplete
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPayStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.interactivePopGestureRecognizer?.isEnabled = false
        
        MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
            guard isLogin, let self = self else {
                MemberManager.shared.showLoginAlert()
                return
            }
            self.checkMembershipData()
        }
    }
    
    // MARK: REACTORKIT

    func bind(reactor: MembershipCardReactor) {
        Observable.just(MembershipCardReactor.Action.membershipCardInfo)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.membershipCardInfo }
            .asDriver(onErrorJustReturn: MembershipCardInfo(JSON.null))
            .drive(with: self) { obj, model in
                self.partnershipListView.showInfoView(info: model)
            }
            .disposed(by: self.disposeBag)
    }
    
    // MARK: FUNC
    
    private func checkMembershipData() {
        Server.getInfoMembershipCard { [weak self] (isSuccess, value) in
            guard let self = self, isSuccess else { return }
            let json = JSON(value)
            
            let item : MemberPartnershipInfo = MemberPartnershipInfo(json)
            self.partnershipListView.showInfoView(info: item)
        }
    }
    
    private func checkPayStatus() {
        Server.getPayRegisterStatus { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let payCode = json["pay_code"].intValue
                
                switch PaymentStatus(rawValue: payCode) {
                case .PAY_NO_CARD_USER, // 카드등록 아니된 멤버
                        .PAY_NO_VERIFY_USER, // 인증 되지 않은 멤버 *헤커 의심
                        .PAY_DELETE_FAIL_USER, // 비정상적인 삭제 멤버
                        .PAY_NO_USER :  // 유저체크
                    
                    let popupModel = PopupModel(title: "결제카드 오류 안내",
                                                message: "현재 고객님의 결제 카드에 오류가 발생했어요. 오류 발생 시 원활한 서비스 이용을 할 수 없으니 다른 카드로 변경해주세요.",
                                                confirmBtnTitle: "결제카드 변경하기",
                                                confirmBtnAction: { [weak self] in
                        guard let self = self else { return }
                        let memberStoryboard = UIStoryboard(name : "Member", bundle: nil)
                        let myPayInfoVC = memberStoryboard.instantiateViewController(ofType: MyPayinfoViewController.self)
                        GlobalDefine.shared.mainNavi?.push(viewController: myPayInfoVC)
                    })

                    let popup = ConfirmPopupViewController(model: popupModel)
                                                                                
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.present(popup, animated: false, completion: nil)
                    })
                                        
                case .PAY_DEBTOR_USER: // 돈안낸 유저
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        let paymentVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(ofType: RepayListViewController.self)
                        GlobalDefine.shared.mainNavi?.push(viewController: paymentVC)
                    })
                                        
                default: break
                }
                
                printLog(out: "json data : \(json)")
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            }
        }
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
    
    func showEvinfraMembershipInfo(info : MemberPartnershipInfo) {
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
    
    func moveReissuanceView(info: MemberPartnershipInfo) {
        let reactor = MembershipReissuanceReactor(provider: RestApi())
        let viewcon = MembershipReissuanceViewController()
        viewcon.reactor = reactor
        reactor.cardNo = info.cardNo ?? ""
        viewcon.delegate = self
        navigationController?.push(viewController: viewcon)
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

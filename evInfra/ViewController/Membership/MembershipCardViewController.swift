//
//  MembershipCardViewController.swift
//  evInfra
//
//  Created by bulacode on 18/09/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON

internal final class MembershipCardViewController: CommonBaseViewController {

    // MARK: UI
    
    private lazy var commonNaviView = CommonNaviView().then {
        $0.naviTitleLbl.text = "EV Pay 카드관리"
    }
    
    private lazy var partnershipListView = PartnershipListView(frame: .zero).then {        
        $0.delegate = self
        $0.navi = self.navigationController ?? UINavigationController()
    }
    
    // MARK: VARIABLE
    
    private var paymentStatus: PaymentStatus = .none
    
    // MARK: SYSTEM FUNC
    
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
                    
                    let popupModel = PopupModel(title: "결제 정보 재등록이 필요해요",
                                                message: "현재 카드 오류/삭제로 인해 고객님의 결제 정보를 불러올 수 없어요. 원활한 서비스 이용을 위해 결제 정보를 다시 등록해주세요.",
                                                confirmBtnTitle: "결제 정보 등록하기",
                                                confirmBtnAction: { [weak self] in
                        guard let self = self else { return }
                        let memberStoryboard = UIStoryboard(name : "Member", bundle: nil)
                        let myPayInfoVC = memberStoryboard.instantiateViewController(ofType: MyPayinfoViewController.self)
                        self.navigationController?.push(viewController: myPayInfoVC)
                    })

                    let popup = ConfirmPopupViewController(model: popupModel)
                                                                                
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.present(popup, animated: false, completion: nil)
                    })
                                        
                case .PAY_DEBTOR_USER: // 돈안낸 유저
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        let paymentVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(ofType: RepayListViewController.self)
                        self.navigationController?.push(viewController: paymentVC)
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
        let mbsInfoVC = storyboard?.instantiateViewController(withIdentifier: "MembershipInfoViewController") as! MembershipInfoViewController
        mbsInfoVC.setCardInfo(info : info)
        navigationController?.push(viewController: mbsInfoVC)
    }
    
    func showLotteRentInfo(){
        let lotteInfoVC = storyboard?.instantiateViewController(withIdentifier: "LotteRentInfoViewController") as! LotteRentInfoViewController
        navigationController?.push(viewController: lotteInfoVC)
    }
    
    func moveMembershipUseGuideView() {
        let viewcon = MembershipUseGuideViewController()
        navigationController?.push(viewController: viewcon)
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
}

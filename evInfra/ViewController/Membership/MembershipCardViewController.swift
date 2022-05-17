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

protocol MembershipCardDelegate {
    func reissuanceComplete()
}

internal final class MembershipCardViewController: BaseViewController {

    // MARK: UI
    
    private lazy var partnershipListView = PartnershipListView(frame: .zero).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self        
    }
    
    // MARK: VARIABLE
    
    private var payRegistResult: JSON?
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(partnershipListView)
        partnershipListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar(with: "회원카드 관리")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                        
        if MemberManager().isLogin() {
            checkMembershipData()
        } else {
            MemberManager().showLoginAlert(vc: self)
        }
    }

    func checkMembershipData() {        
        Server.getInfoMembershipCard { [weak self] (isSuccess, value) in
            guard let self = self, isSuccess else { return }
            let json = JSON(value)
            let item : MemberPartnershipInfo = MemberPartnershipInfo(json)
            self.partnershipListView.showInfoView(info: item)
        }
    }
}

extension MembershipCardViewController: MembershipCardDelegate {
    func reissuanceComplete() {
        Snackbar().show(message: "재발급 신청이 완료되었습니다.")
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
        let viewcon = MembershipReissuanceViewController()
        viewcon.cardNo = info.cardNo ?? ""
        viewcon.membershipCardDelegate = self
        navigationController?.push(viewController: viewcon)
    }
}

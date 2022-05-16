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

internal final class MembershipCardViewController: UIViewController {

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
        
        prepareActionBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
            print("JSON DATA : \(json)")
            let item : MemberPartnershipInfo = MemberPartnershipInfo(json)
            self.partnershipListView.showInfoView(info: item)
        }
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "회원카드 관리"
        self.navigationController?.isNavigationBarHidden = false
    }

    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
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
        navigationController?.push(viewController: viewcon)
    }
}

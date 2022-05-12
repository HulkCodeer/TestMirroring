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

internal final class MembershipCardViewController: UIViewController,
    PartnershipJoinViewDelegate, PartnershipListViewDelegate {

    private var partnershipJoinView : PartnershipJoinView? = nil
    private var partnershipListView : PartnershipListView? = nil
    private var payRegistResult: JSON?
    private var partnershipInfoList = [MemberPartnershipInfo]()
    private var viewCnt = 0;
    
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
        Server.getMemberPartnershipInfo { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                self.partnershipInfoList.removeAll()
                
                let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                if json["code"].stringValue.elementsEqual("1101") { // MBS_CARD_NOT_ISSUED 발급받은 회원카드가 없음
                    UserDefault().saveBool(key: UserDefault.Key.INTRO_SKR, value: false)
                    self.partnershipJoinView = PartnershipJoinView.init(frame: frame)
                    if let pjView = self.partnershipJoinView {
                        pjView.delegate = self
                        pjView.showInfoView(infoList : self.partnershipInfoList)
                        self.view.addSubview(pjView)
                        self.viewCnt = 1
                    }
                } else {
                    for jsonRow in json["list"].arrayValue {
                        let item : MemberPartnershipInfo = MemberPartnershipInfo.init(json : jsonRow)
                        self.partnershipInfoList.append(item)
                    }
                    self.partnershipListView = PartnershipListView.init(frame: frame)
                    if let plView = self.partnershipListView {
                        plView.delegate = self
                        plView.showInfoView(infoList: self.partnershipInfoList)
                        self.view.addSubview(plView)
                        self.viewCnt = 1
                    }
                }
            }
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
        if viewCnt > 1 {
            viewCnt -= 1
            if let plView = self.partnershipListView {
                plView.delegate = self
                plView.showInfoView(infoList: self.partnershipInfoList)
                self.view.addSubview(plView)
            }
        }
        else {
            self.view.removeFromSuperview()
            self.navigationController?.pop()
        }
    }
    
    func showMembershipIssuanceView() {
        let mbsIssueVC = storyboard?.instantiateViewController(withIdentifier: "MembershipIssuanceViewController") as! MembershipIssuanceViewController
        navigationController?.push(viewController: mbsIssueVC)
    }
    func showSKMemberQRView() {
        let mbsQRVC = storyboard?.instantiateViewController(withIdentifier: "MembershipQRViewController") as! MembershipQRViewController
        navigationController?.push(viewController: mbsQRVC)
    }
    
    func showLotteRentCertificateView() {
        let lotteVC = storyboard?.instantiateViewController(withIdentifier: "LotteRentCertificateViewController") as! LotteRentCertificateViewController
        navigationController?.push(viewController: lotteVC)
    }
    
    func addNewPartnership() {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.partnershipJoinView = PartnershipJoinView.init(frame: frame)
        if let pjView = self.partnershipJoinView {
            pjView.delegate = self
            pjView.showInfoView(infoList : self.partnershipInfoList)
            self.view.addSubview(pjView)
            self.viewCnt += 1
        }
    }
}

extension MembershipCardViewController {
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
    
    func moveReissuanceView() {
        let viewcon = MembershipReissuanceViewController()
        
        for item in partnershipInfoList {
            switch item.clientId {
            case 1 : // evinfra
                viewcon.cardNo = item.cardNo ?? ""
                navigationController?.push(viewController: viewcon)
                                
                break

//            case 23 : //sk rent
//                viewSkrList.isHidden = false
//                cardCnt -= 1
//                MemberManager.setSKRentConfig()
//                isSKR = true
//                break;
//
//            case 24 : //lotte rent
//                viewLotteList.isHidden = false
//                labelCarNo.text = item.carNo
//                labelContrDate.text = item.startDate! + " ~ " + item.endDate!
//                cardCnt -= 1
//                break
            default :
                print("out of index")
            }
        }
    }
}

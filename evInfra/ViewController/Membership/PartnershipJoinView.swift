//
//  PartnershipJoinView.swift
//  evInfra
//
//  Created by SH on 2020/10/05.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol PartnershipJoinViewDelegate: class {
    func showMembershipIssuanceView()
    func showSKMemberQRView()
    func showLotteRentCertificateView()
}

internal final class PartnershipJoinView : UIView {
    // MARK: UI
    
    @IBOutlet weak var lbPartnerShipTitle: UILabel!
    @IBOutlet weak var viewSkrentJoin: UIView!
    @IBOutlet weak var viewLotteJoin: UIView!
    
    // MARK: VARIABLE
    
    internal weak var delegate: PartnershipJoinViewDelegate?
    
    // MARK: SYSTEM FUNC
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let view = Bundle.main.loadNibNamed("PartnershipJoinView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        addSubview(view)
        initView()
    }
    
    private func initView() {
        let skr_touch = UITapGestureRecognizer(target: self, action: #selector(self.onClickSKRent))
        viewSkrentJoin.addGestureRecognizer(skr_touch)

        
        let lotte_touch = UITapGestureRecognizer(target: self, action: #selector(self.onClickLotteRent))
        viewLotteJoin.addGestureRecognizer(lotte_touch)
    }
    
    func showInfoView(infoList : [MemberPartnershipInfo]) {
        var partnershipCnt = 2
        for item in infoList {
            switch item.clientId {
//            case 1 : // evinfra
//                lbEvTitle.isHidden = true
//                viewEvinfraJoin.isHidden = true
//                break
            case 23 : //sk rent
                viewSkrentJoin.isHidden = true
                partnershipCnt -= 1
                break
            case 24 : //lotte rent
                viewLotteJoin.isHidden = true
                partnershipCnt -= 1
                break
            default :
                print("out of index")
            }
        }
        if partnershipCnt <= 0 {
            lbPartnerShipTitle.isHidden = true
        }
    }
    
    @objc func onClickEvInfra(sender: UITapGestureRecognizer) {
        self.delegate?.showMembershipIssuanceView()
    }
    
    @objc func onClickSKRent(sender: UITapGestureRecognizer) {
        self.delegate?.showSKMemberQRView()
    }
    
    @objc func onClickLotteRent(sender: UITapGestureRecognizer) {
        self.delegate?.showLotteRentCertificateView()
    }
}

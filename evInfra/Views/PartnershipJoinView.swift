//
//  PartnershipJoinView.swift
//  evInfra
//
//  Created by SH on 2020/10/05.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import UIKit
import SwiftyJSON
class PartnershipJoinView : UIView{
    @IBOutlet var lbEvTitle: UILabel!
    @IBOutlet var lbPartnerShipTitle: UILabel!
    @IBOutlet weak var viewEvinfraJoin: UIStackView!
    @IBOutlet weak var viewSkrentJoin: UIStackView!
    @IBOutlet weak var viewLotteJoin: UIStackView!
    
    var delegate: PartnershipJoinViewDelegate?
    
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
    
    private func initView(){
        let ev_touch = UITapGestureRecognizer(target: self, action: #selector(self.onClickEvInfra))
        pinBackground(getBackgroundView(), to: viewEvinfraJoin)
        viewEvinfraJoin.addGestureRecognizer(ev_touch)

        let skr_touch = UITapGestureRecognizer(target: self, action: #selector(self.onClickSKRent))
        pinBackground(getBackgroundView(), to: viewSkrentJoin)
        viewSkrentJoin.addGestureRecognizer(skr_touch)
        
        let lotte_touch = UITapGestureRecognizer(target: self, action: #selector(self.onClickLotteRent))
        pinBackground(getBackgroundView(), to: viewLotteJoin)
        viewLotteJoin.addGestureRecognizer(lotte_touch)
    }
    
    func showInfoView(infoList : [MemberPartnershipInfo]){
        var partnershipCnt = 2
        for item in infoList {
            switch item.clientId {
            case 1 : // evinfra
                lbEvTitle.isHidden = true
                viewEvinfraJoin.isHidden = true
                break
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
        if(partnershipCnt <= 0){
            lbPartnerShipTitle.isHidden = true
        }
    }
    
    @objc func onClickEvInfra(sender: UITapGestureRecognizer){
        print("evinfra btn pressed")
        self.delegate?.showMembershipIssuanceView()
    }
    
    @objc func onClickSKRent(sender: UITapGestureRecognizer){
        print("skr btn pressed")
        self.delegate?.showSKMemberQRView()
    }
    
    @objc func onClickLotteRent(sender: UITapGestureRecognizer){
        print("lotte btn pressed")
        self.delegate?.showLotteRentCertificateView()
    }
    
    private func pinBackground(_ view: UIView, to stackView: UIStackView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertSubview(view, at: 0)
        view.pin(to: stackView)
    }
    
    private func getBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8548362255, green: 0.8549391627, blue: 0.8548011184, alpha: 1)
        view.layer.cornerRadius = 10.0
        return view
    }
}

public extension UIView {
  public func pin(to view: UIView) {
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: view.leadingAnchor),
      trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topAnchor.constraint(equalTo: view.topAnchor),
      bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ])
  }
}

protocol PartnershipJoinViewDelegate {
    func showMembershipIssuanceView()
    func showSKMemberQRView()
    func showLotteRentCertificateView()
}

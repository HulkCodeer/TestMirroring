//
//  PartnershipListView.swift
//  evInfra
//
//  Created by SH on 2020/10/06.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyJSON

protocol PartnershipListViewDelegate {
    func addNewPartnership()
    func showEvinfraMembershipInfo(info : MemberPartnershipInfo)
    func showLotteRentInfo()
    func moveMembershipUseGuideView()
    func moveReissuanceView(info: MemberPartnershipInfo)
    func paymentStatusInfo() -> PaymentStatus
}

internal final class PartnershipListView : UIView {
    // MARK: UI
    
    @IBOutlet var viewEvinfraList: UIView!
    @IBOutlet var labelCardStatus: UILabel!
    @IBOutlet var labelCardNum: UILabel!
    @IBOutlet var labelCarNo: UILabel!
    @IBOutlet var labelContrDate: UILabel!
    @IBOutlet var viewAddBtn: UIView!
    @IBOutlet var btnAddCard: UIImageView!
    @IBOutlet var membershipUseGuideBtn: UIButton!
    @IBOutlet var reissuanceBtn: UIButton!
    @IBOutlet var membershipUseGuideLbl: UILabel!
    
    // MARK: VARIABLE
    
    internal var delegate: PartnershipListViewDelegate?
    
    private var evInfraInfo : MemberPartnershipInfo = MemberPartnershipInfo(JSON.null)
    private var disposebag = DisposeBag()
    
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
        let view = loadViewFromNib()
        view.frame = self.bounds
        addSubview(view)
        initView()
        
        membershipUseGuideLbl.attributedText = NSAttributedString(string: "회원카드 사용방법이 궁금하신가요?", attributes:
                                                                    [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
        
        membershipUseGuideBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.moveMembershipUseGuideView()
            })
            .disposed(by: self.disposebag)
        
        reissuanceBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.moveReissuanceView(info: self.evInfraInfo)
            })
            .disposed(by: self.disposebag)
        
        membershipUseGuideBtn.isExclusiveTouch = true
        reissuanceBtn.isExclusiveTouch = true
    }
    
    private func loadViewFromNib() -> UIView {
        guard let view = Bundle.main.loadNibNamed("PartnershipListView", owner: self, options: nil)?.first as? UIView else { return UIView() }
        return view
    }
    
    func showInfoView(info : MemberPartnershipInfo) {
        evInfraInfo = info
        viewEvinfraList.isHidden = false
        labelCardStatus.text = info.displayStatusDescription
        
        let modString = info.cardNo!.replaceAll(of : "(\\d{4})(?=\\d)", with : "$1-")
        labelCardNum.text = modString
    }
    
    private func initView() {
        let ev_touch = UITapGestureRecognizer(target: self, action: #selector(self.onClickEvInfra))
        viewEvinfraList.addGestureRecognizer(ev_touch)
        
        let add_touch = UITapGestureRecognizer(target: self, action: #selector(self.onClickAddBtn))
        btnAddCard.addGestureRecognizer(add_touch)
    }
    
    @objc func onClickEvInfra(sender: UITapGestureRecognizer) {
        delegate?.showEvinfraMembershipInfo(info : self.evInfraInfo)
    }
    
    @objc func onClickLotteRent(sender: UITapGestureRecognizer) {
        delegate?.showLotteRentInfo()
    }
    
    @objc func onClickAddBtn(sender: UITapGestureRecognizer) {
        delegate?.addNewPartnership()
    }
}

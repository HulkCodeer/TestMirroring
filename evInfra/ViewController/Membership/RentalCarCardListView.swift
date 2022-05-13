//
//  RentalCarCardListView.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/13.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RxSwift
import RxCocoa

internal final class RentalCarCardListView : UIView {
    // MARK: UI

    
    // MARK: VARIABLE
    
    internal var delegate: PartnershipListViewDelegate?
    
    private var evInfraInfo : MemberPartnershipInfo?
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
                
    }
    
    private func loadViewFromNib() -> UIView {
        guard let view = Bundle.main.loadNibNamed("RentalCarCardListView", owner: self, options: nil)?.first as? UIView else { return UIView() }
        return view
    }
    
    func showInfoView(infoList : [MemberPartnershipInfo]) {
//        var cardCnt = 3
//        var isSKR = false
//        for item in infoList {
//            switch item.clientId {
//            case 1 : // evinfra
//                evInfraInfo = item
//                viewEvinfraList.isHidden = false
//                labelCardStatus.text = getCardStatusToString(status : item.status, issuanceDate: item.displayDate)
//
//                let modString = item.cardNo!.replaceAll(of : "(\\d{4})(?=\\d)", with : "$1-")
//                labelCardNum.text = modString
//
//                cardCnt -= 1
//                break
//
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
//            default :
//                print("out of index")
//            }
//        }
//        if cardCnt <= 0 {
//            viewAddBtn.isHidden = true
//        }
//        if !isSKR {
//            UserDefault().saveBool(key: UserDefault.Key.INTRO_SKR, value: false)
//        }
    }
    
    func getCardStatusToString(status: String, issuanceDate: String) -> String {
        switch (status) {
        case "0":
            return "발급 신청"
        case "1":
            return issuanceDate
//            return "발급 완료"
        case "2":
            return "카드 분실"
        default:
            return "상태 오류"
        }
    }
    
    private func initView() {
//        let ev_touch = UITapGestureRecognizer(target: self, action: #selector(self.onClickEvInfra))
//        viewEvinfraList.addGestureRecognizer(ev_touch)
//
//        let lotte_touch = UITapGestureRecognizer(target: self, action: #selector(self.onClickLotteRent))
//        viewLotteList.addGestureRecognizer(lotte_touch)
//
//        let add_touch = UITapGestureRecognizer(target: self, action: #selector(self.onClickAddBtn))
//        btnAddCard.addGestureRecognizer(add_touch)
    }
    
    @objc func onClickEvInfra(sender: UITapGestureRecognizer) {
        delegate?.showEvinfraMembershipInfo(info : evInfraInfo!)
    }
    
    @objc func onClickLotteRent(sender: UITapGestureRecognizer) {
        delegate?.showLotteRentInfo()
    }
    
    @objc func onClickAddBtn(sender: UITapGestureRecognizer) {
        delegate?.addNewPartnership()
    }
}

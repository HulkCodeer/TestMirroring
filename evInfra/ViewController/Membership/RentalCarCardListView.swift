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

    @IBOutlet var viewSkrList: UIView!
    @IBOutlet var viewLotteList: UIView!
    @IBOutlet var labelCarNo: UILabel!
    @IBOutlet var labelContrDate: UILabel!
    @IBOutlet var moveSkrBtn: UIButton!
    @IBOutlet var moveLotteBtn: UIButton!
    
    // MARK: VARIABLE
    
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
        
        moveLotteBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                let membershipVC = UIStoryboard(name: "Membership", bundle: nil).instantiateViewController(ofType: LotteRentInfoViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: membershipVC)
            })
            .disposed(by: self.disposebag)
    }
    
    private func loadViewFromNib() -> UIView {
        guard let view = Bundle.main.loadNibNamed("RentalCarCardListView", owner: self, options: nil)?.first as? UIView else { return UIView() }
        return view
    }
    
    func showInfoView(infoList : [MemberPartnershipInfo]) {
        
        var isSKR = false
        for item in infoList {
            switch item.clientId {
        
            case 23 : //sk rent
                viewSkrList.isHidden = false
                MemberManager.shared.setSKRentConfig()
                isSKR = true

            case 24 : //lotte rent
                viewLotteList.isHidden = false
                labelCarNo.text = item.carNo
                labelContrDate.text = item.startDate! + " ~ " + item.endDate!
                                
            default :
                print("out of index")
            }
        }
        
        if !isSKR {
            UserDefault().saveBool(key: UserDefault.Key.INTRO_SKR, value: false)
        }
    }
}

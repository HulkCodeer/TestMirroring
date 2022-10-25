//
//  ShipmentStatus .swift
//  evInfra
//
//  Created by 소프트베리 on 2022/10/23.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import SwiftyJSON
import RxSwift
import RxCocoa

internal final class ShipmentStatusView: UIView {
    
    // MARK: UI
    
    private lazy var shipmentStatusGuideLbl = UILabel().then {
        $0.text = "회원 카드 발송 현황"
    }
    
    private lazy var shipmentStepView = ShipmentStepView(frame: .zero)
    
    private lazy var shipmentInfoView = ShipmentInfoView(frame: .zero)
    
    // MARK: VARIABLE
    
    private var disposebag = DisposeBag()
    
    // MARK: SYSTEM FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
            
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    // MARK: FUNC
    
    private func makeUI() {
        
    }
    
    internal func bind(reactor: MembershipCardIssuanceCompleteReactor) {
        reactor.state.compactMap { $0.membershipCardInfo }
            .asDriver(onErrorJustReturn: MembershipCardInfo(JSON.null))
            .drive(with: self) { obj, model in
                
            }
            .disposed(by: self.disposebag)
    }
}



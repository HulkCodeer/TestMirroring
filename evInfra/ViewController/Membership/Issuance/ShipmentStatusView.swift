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
        self.addSubview(shipmentStepView)
        shipmentStepView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()            
            $0.height.greaterThanOrEqualTo(100)
        }
                        
        self.addSubview(shipmentInfoView)
        shipmentInfoView.snp.makeConstraints {
            $0.top.equalTo(shipmentStepView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-28)
        }
        
    }
    
    internal func bind(reactor: MembershipCardIssuanceCompleteReactor) {
        reactor.state.compactMap { $0.membershipCardInfo }
            .asDriver(onErrorJustReturn: MembershipCardInfo(JSON.null))
            .drive(with: self) { obj, model in
                obj.shipmentStepView.bind(model: model)
            }
            .disposed(by: self.disposebag)
    }
    
    internal func createLineView(color: UIColor? = Colors.backgroundSecondary.color) -> UIView {
        return UIView().then {
            $0.backgroundColor = color
        }
    }
}


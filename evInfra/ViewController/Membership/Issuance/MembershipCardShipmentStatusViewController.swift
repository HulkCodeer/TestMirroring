//
//  MembershipCardShipmentStatusViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/11/03.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RxSwift
import RxCocoa

internal final class MembershipCardShipmentStatusViewController: CommonBaseViewController {
    
    // MARK: UI
            
    private lazy var totalStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 0
        $0.backgroundColor = Colors.backgroundPrimary.color
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
        $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
            
    private lazy var shipmentStepView = ShipmentStepView(frame: .zero)
    
    private lazy var shipmentInfoView = ShipmentInfoView(frame: .zero)
    
    // MARK: VARIABLE
    
    private var disposebag = DisposeBag()
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        
    }
}


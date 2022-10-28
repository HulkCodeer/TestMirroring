//
//  ShipmentInfoView.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/10/25.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RxSwift
import RxCocoa

internal final class ShipmentInfoView: UIView {
    
    // MARK: UI
    
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
    
    internal func bind(model: MembershipCardInfo.Info) {
        
    }
}

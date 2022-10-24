//
//  ShipmentStatus .swift
//  evInfra
//
//  Created by 소프트베리 on 2022/10/23.
//  Copyright © 2022 soft-berry. All rights reserved.
//


internal final class ShipmentStatusView: UIView {
    
    // MARK: UI
    
    private lazy var shipmentStatusGuideLbl = UILabel().then {
        $0.text = "회원 카드 발송 현황"
    }
    
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
    
    func makeUI() {
        
    }
}



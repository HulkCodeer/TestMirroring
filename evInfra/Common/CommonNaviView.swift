//
//  CommonNaviView.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/06/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import UIKit

internal final class CommonNaviView: UIView {
    
    // MARK: UI
    
    private lazy var totalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = false
    }
    
    private lazy var navigationBackBtn = ArrowBackBtn().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
     
    // MARK: SYSTEM FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.totalView)
        self.totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(15)
        }
                
    }
    
    
}

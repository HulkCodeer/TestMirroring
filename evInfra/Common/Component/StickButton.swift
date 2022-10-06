//
//  StickButton.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/09/05.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import RxSwift

internal final class StickButton: UIView {
    
    // MARK: UI
    
    private lazy var totalView = UIView()
    
    internal lazy var rectBtn = RectButton()
            
    // MARK: VARIABLE
    
    private let disposebag = DisposeBag()
         
    // MARK: SYSTEM FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
            
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, level: RectButton.Const.Level) {
        super.init(frame: frame)
        
        self.rectBtn = RectButton(level: level)
                
        self.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        totalView.addSubview(rectBtn)
        rectBtn.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(16)
            $0.trailing.bottom.equalToSuperview().offset(-16)
        }
                                        
        totalView.setGradientColor([Colors.backgroundPrimaryTransparency.color, Colors.backgroundPrimary.color], locations: [0.0, 1.0], direction: .vertical, frame: totalView.bounds)
    }
    
}

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
    private lazy var rectBtn = RectButton()
            
    // MARK: VARIABLE
    
    private let disposebag = DisposeBag()
    internal var backClosure: (() -> Void)?
         
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
                        
        rectBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard let _backClosure = self.backClosure else {
                    GlobalDefine.shared.mainNavi?.pop()
                    return
                }
                _backClosure()
            })
            .disposed(by: self.disposebag)
        
        totalView.setGradientColor([Colors.backgroundPrimary.color], locations: [0.0, 1.0], direction: .vertical, frame: totalView.bounds)
    }
    
}

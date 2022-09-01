//
//  CommonNaviView.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/06/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

internal final class CommonNaviView: UIView {
    
    // MARK: UI
    
    private lazy var totalView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    internal lazy var naviBackBtn = NavigationClose().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    internal lazy var naviTitleLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .center
        $0.numberOfLines = 1
    }
    
    private lazy var lineView = UIView().then {        
        $0.backgroundColor = Colors.borderOpaque.color
    }
    
    // MARK: VARIABLE
    
    internal var backClosure: (() -> Void)?
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
        
        self.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        totalView.addSubview(naviBackBtn)
        naviBackBtn.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(48)
        }
               
        totalView.addSubview(naviTitleLbl)
        naviTitleLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(48)
            $0.trailing.equalToSuperview().offset(-48)
            $0.top.bottom.equalToSuperview()
            $0.center.equalToSuperview()
        }
        
        totalView.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        naviBackBtn.btn.rx.tap
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
    }
}

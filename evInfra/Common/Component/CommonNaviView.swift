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
    
    private lazy var naviBackBtn = ArrowBackBtn().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = Colors.contentPrimary.color
    }
    
    private lazy var naviTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .center
        $0.numberOfLines = 1
    }
    
    private lazy var lineView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.borderOpaque.color
    }
     
    // MARK: SYSTEM FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    init(naviTitle: String) {        
        super.init(frame: CGRect.zero)        
        naviTitleLbl.text = naviTitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(15)
        }
        
        self.addSubview(naviBackBtn)
        naviBackBtn.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(48)
        }
               
        self.addSubview(naviTitleLbl)
        naviTitleLbl.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.center.equalToSuperview()
        }
        
        self.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}

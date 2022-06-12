//
//  NewSettingsViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/06/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import UIKit
import ReactorKit

internal final class NewSettingsViewController: CommonBaseViewController, StoryboardView {
    
    // MARK: UI
    
    private lazy var naviTotalView = CommonNaviView(naviTitle: "설정").then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    init(reactor: SettingsReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
                
        GlobalDefine.shared.mainNavi?.isToolbarHidden = true
        GlobalDefine.shared.mainNavi?.isNavigationBarHidden = true
        GlobalDefine.shared.mainNavi?.setNavigationBarHidden(true, animated: false)        
        
        self.view.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
    }
    
    internal func bind(reactor: SettingsReactor) {        
                
    }
}

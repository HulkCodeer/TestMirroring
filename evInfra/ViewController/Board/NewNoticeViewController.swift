//
//  NewNoticeViewController.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/25.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import WebKit

import Then
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import WebKit

final class NewNoticeViewController: CommonBaseViewController {
    private lazy var customNaviBar = CommonNaviView()
    
    private lazy var noticeTableView = UITableView()

    override func loadView() {
        super.loadView()
        
        contentView.addSubview(customNaviBar)
        contentView.addSubview(noticeTableView)
        
        customNaviBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
//            $0.height.equalTo(Constants.view.naviHeight)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }

}

//
//  NewMyPageViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/07/21.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit

internal final class NewMyPageViewController: CommonBaseViewController, StoryboardView {
    
    // MARK: UI
    
    private lazy var naviTotalView = CommonNaviView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.naviTitleLbl.text = "개인정보 관리"
    }
    
    private lazy var profileTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(BottomSheetCell.self, forCellReuseIdentifier: "cell")
        $0.backgroundColor = UIColor.clear
        $0.separatorStyle = .none
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = 55
        $0.allowsSelection = true
        $0.allowsSelectionDuringEditing = false
        $0.isMultipleTouchEnabled = false
        $0.allowsMultipleSelection = false
        $0.allowsMultipleSelectionDuringEditing = false
        $0.contentInset = .zero
        $0.bounces = false
//        $0.delegate = self
//        $0.dataSource = self
    }
    
    // MARK: VARIABLE
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(profileTotalView)
        profileTotalView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(104)
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(reactor: MyPageReactor) {
        
    }
}

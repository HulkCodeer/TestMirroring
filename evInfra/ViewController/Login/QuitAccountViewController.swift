//
//  QuitAccountViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/06/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit

internal final class QuitAccountViewController: CommonBaseViewController, StoryboardView {
    // MARK: UI
    
    private lazy var naviTotalView = CommonNaviView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.naviTitleLbl.text = "회원탈퇴"
    }
    
    private lazy var totalScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private lazy var totalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
                    
    private lazy var nextBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("탈퇴하기", for: .normal)
        $0.setTitle("탈퇴하기", for: .disabled)
        $0.setBackgroundColor(Colors.backgroundDisabled.color, for: .disabled)
        $0.setBackgroundColor(Colors.backgroundPositive.color, for: .normal)
        $0.setTitleColor(Colors.contentPrimary.color, for: .normal)
        $0.setTitleColor(Colors.contentDisabled.color, for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.isEnabled = false
        $0.IBcornerRadius = 6
    }
    
    // MARK: SYSTEM FUNC
    
    init(reactor: QuitAccountReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
                
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(nextBtn)
        nextBtn.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        self.contentView.addSubview(totalScrollView)
        totalScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextBtn.snp.top)
            $0.width.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        totalScrollView.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.center.equalToSuperview()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
    }
            
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
                
    }
                    
    internal func bind(reactor: QuitAccountReactor) {
        
    }
}

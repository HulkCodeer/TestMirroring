//
//  NewChargerFilterViewController.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/10/24.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import SnapKit
import Then

enum SwitchViews: CaseIterable {
    case evpay
    case favorite
    case representCar
}

internal final class NewChargerFilterViewController: CommonBaseViewController, StoryboardView {
    
    // MARK: UI
    private lazy var naviTotalView = CommonNaviView().then {
        $0.naviTitleLbl.text = "필터설정"
    }
    private lazy var resetBtn = UIButton().then {
        $0.setTitle("초기화", for: .normal)
        $0.setTitleColor(Colors.contentDisabled.color, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16)
        $0.backgroundColor = .clear
    }
    private lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = true
    }
    private lazy var filterStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 16
    }
    private var switchFilterView = NewFilterSwitchesView()
    private var typeFilterView = NewFilterTypeView()
    private var placeFilterView = NewFilterPlaceView()
    private var speedFilterView = NewFilterSpeedView()
    private var roadFilterView = NewFilterRoadView()
    private lazy var saveBtn = StickButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 80),
                                           level: .primary).then {
        $0.rectBtn.setTitle("필터 설정 저장하기", for: .normal)
        $0.rectBtn.isSelected = false
    }
    
    // MARK: STSTEM FUNC
    init(reactor: MainReactor) {
        super.init()
        self.reactor = reactor
    }
//
//    override init() {
//        super.init()
//    }
    
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
        
        naviTotalView.addSubview(resetBtn)
        resetBtn.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(24)
        }
        
        self.contentView.addSubview(saveBtn)
        saveBtn.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        self.contentView.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(saveBtn.snp.top)
        }
        
        scrollView.addSubview(filterStackView)
        filterStackView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.width.equalToSuperview()
        }

        filterStackView.addArrangedSubview(switchFilterView)
        let lineView = self.createLineView(color: Colors.nt1.color)
        filterStackView.addArrangedSubview(lineView)
        filterStackView.addArrangedSubview(speedFilterView)
        filterStackView.addArrangedSubview(typeFilterView)
        filterStackView.addArrangedSubview(roadFilterView)
        filterStackView.addArrangedSubview(placeFilterView)
        switchFilterView.snp.makeConstraints {
            $0.height.equalTo(168)
        }
        lineView.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        speedFilterView.snp.makeConstraints {
            $0.height.equalTo(112)
        }
        typeFilterView.snp.makeConstraints {
            $0.height.equalTo(128)
        }
        roadFilterView.snp.makeConstraints {
            $0.height.equalTo(110)
        }
        placeFilterView.snp.makeConstraints {
            $0.height.equalTo(110)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
    
    internal func bind(reactor: MainReactor) {
        switchFilterView.bind(reactor: reactor)
        typeFilterView.bind(reactor: reactor)
        speedFilterView.bind(reactor: reactor)
        roadFilterView.bind(reactor: reactor)
        placeFilterView.bind(reactor: reactor)
    }
}

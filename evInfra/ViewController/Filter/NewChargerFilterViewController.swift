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
        $0.isUserInteractionEnabled = true
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
    private var accessFilterView = NewFilterAccessView()
    private var companyFilterView = NewFilterCompanyView()
    private var saveBtn = StickButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 80),
                                           level: .primary).then {
        $0.rectBtn.setTitle("필터 설정 저장하기", for: .normal)
        $0.rectBtn.isSelected = false
    }
    
    // MARK: STSTEM FUNC
    init(reactor: MainReactor) {
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
            $0.width.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(saveBtn.snp.top)
        }

        scrollView.addSubview(filterStackView)
        filterStackView.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.top)
            $0.bottom.equalTo(scrollView.snp.bottom)
            $0.width.equalTo(scrollView.snp.width)
            $0.centerX.equalTo(scrollView.snp.centerX)
            $0.height.equalTo(scrollView.snp.height).priority(250)
        }

        let lineView = self.createLineView(color: Colors.nt1.color)
        lineView.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        filterStackView.addArrangedSubview(switchFilterView)
        filterStackView.addArrangedSubview(lineView)
        filterStackView.addArrangedSubview(speedFilterView)
        filterStackView.addArrangedSubview(typeFilterView)
        filterStackView.addArrangedSubview(accessFilterView)
        filterStackView.addArrangedSubview(roadFilterView)
        filterStackView.addArrangedSubview(placeFilterView)
        filterStackView.addArrangedSubview(companyFilterView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable.just(GlobalFilterReactor.Action.changedFilter(false))
            .bind(to: GlobalFilterReactor.sharedInstance.action)
            .disposed(by: self.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
    
    func bind(reactor: MainReactor) {
        switchFilterView.bind(reactor: reactor)
        typeFilterView.bind(reactor: reactor)
        speedFilterView.bind(reactor: reactor)
        roadFilterView.bind(reactor: reactor)
        placeFilterView.bind(reactor: reactor)
        accessFilterView.bind(reactor: reactor)
        companyFilterView.bind(reactor: GlobalFilterReactor.sharedInstance)
        
        // 초기화 버튼
        resetBtn.rx.tap
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { obj, _ in
                obj.resetBtn.isSelected = !obj.resetBtn.isSelected
                
                let cancelBtn = UIAlertAction(title: "취소", style: .default)
                let okBtn = UIAlertAction(title: "초기화", style: .default) { _ in
                    FilterEvent.clickFilterReset.logEvent()
                    // TODO: 각 필터 초기화
                    
                    obj.roadFilterView.resetRoadFilter()
                    obj.companyFilterView.resetFilter()
                }
                var actions = [UIAlertAction]()
                actions.append(cancelBtn)
                actions.append(okBtn)
                UIAlertController.showAlert(title: "필터 초기화", message: "필터를 초기화 하시겠습니까?", actions: actions)
            }.disposed(by: self.disposeBag)
        
        // 필터 저장 버튼 bind
        GlobalFilterReactor.sharedInstance.state.compactMap { $0.isChangedFilter }
            .bind(to: saveBtn.rectBtn.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        saveBtn.rectBtn.rx.tap
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { obj, _ in
                obj.saveBtn.rectBtn.isSelected = !obj.saveBtn.rectBtn.isSelected
                printLog(out: "\(obj.saveBtn.rectBtn.isSelected)")
                
                
                // TODO: 각 필터 저장
                obj.roadFilterView.saveRoadFilter()
                obj.accessFilterView.saveAccessFilter()
                FilterManager.sharedInstance.logEventWithFilter("필터")
                GlobalDefine.shared.mainNavi?.pop()
            }.disposed(by: self.disposeBag)
            
    }
}

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

protocol NewDelegateChargerFilterView: AnyObject {
    func applyFilter()
}

protocol FilterButtonAction {
    func saveFilter()
    func resetFilter()
    func revertFilter()
}

internal final class NewChargerFilterViewController: CommonBaseViewController, StoryboardView {
    
    // MARK: UI
    private lazy var naviTotalView = CommonNaviView().then {
        $0.naviTitleLbl.text = "필터설정"
        $0.naviBackBtn.isHidden = true
    }
    private lazy var backBtn = NavigationClose()
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
    
    // MARK: VARIABLES
    internal weak var delegate: NewDelegateChargerFilterView?
    
    // MARK: STSTEM FUNC
    init(reactor: GlobalFilterReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
        naviTotalView.addSubview(backBtn)
        backBtn.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(48)
        }
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        companyFilterView.snp.updateConstraints {
            $0.height.equalTo(120 + companyFilterView.companyTableView.contentSize.height)
        }
    }
    
    func bind(reactor: GlobalFilterReactor) {
        switchFilterView.bind(reactor: reactor)
        typeFilterView.bind(reactor: reactor)
        speedFilterView.bind(reactor: reactor)
        roadFilterView.bind(reactor: reactor)
        placeFilterView.bind(reactor: reactor)
        accessFilterView.bind(reactor: reactor)
        companyFilterView.bind(reactor: reactor)
        
        switchFilterView.delegate = self
        typeFilterView.delegate = self
        speedFilterView.delegate = self
        roadFilterView.delegate = self
        placeFilterView.delegate = self
        accessFilterView.delegate = self
        companyFilterView.delegate = self
        
        // 뒤로가기 버튼
        backBtn.btn.rx.tap
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { obj, _ in
                if obj.shouldChanged() {
                    let cancelBtn = UIAlertAction(title: "취소", style: .default)
                    let okBtn = UIAlertAction(title: "나가기", style: .default) { _ in
                        
                        obj.switchFilterView.revertFilter()
                        obj.speedFilterView.revertFilter()
                        obj.typeFilterView.revertFilter()
                        obj.accessFilterView.revertFilter()
                        obj.roadFilterView.revertFilter()
                        obj.placeFilterView.revertFilter()
                        obj.companyFilterView.revertFilter()

                        GlobalDefine.shared.mainNavi?.pop()
                    }
                    var actions = [UIAlertAction]()
                    actions.append(cancelBtn)
                    actions.append(okBtn)
                    UIAlertController.showAlert(title: "뒤로가기", message: "필터를 저장하지 않고 나가시겠습니까?", actions: actions)
                } else {
                    GlobalDefine.shared.mainNavi?.pop()
                }
            }.disposed(by: self.disposeBag)
        
        // 초기화 버튼
        resetBtn.rx.tap
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { obj, _ in
                obj.resetBtn.isSelected = !obj.resetBtn.isSelected
                
                let cancelBtn = UIAlertAction(title: "취소", style: .default)
                let okBtn = UIAlertAction(title: "초기화", style: .default) { _ in
                    FilterEvent.clickFilterReset.logEvent()
                    
                    obj.switchFilterView.resetFilter()
                    obj.speedFilterView.resetFilter()
                    obj.typeFilterView.resetFilter()
                    obj.accessFilterView.resetFilter()
                    obj.roadFilterView.resetFilter()
                    obj.placeFilterView.resetFilter()
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
                
                obj.switchFilterView.saveFilter()
                obj.speedFilterView.saveFilter()
                obj.typeFilterView.saveFilter()
                obj.accessFilterView.saveFilter()
                obj.roadFilterView.saveFilter()
                obj.placeFilterView.saveFilter()
                obj.companyFilterView.saveFilter()
                obj.delegate?.applyFilter()
                
                FilterManager.sharedInstance.logEventWithFilter("필터")
                GlobalDefine.shared.mainNavi?.pop()
            }.disposed(by: self.disposeBag)
            
    }
    
    private func shouldChanged() -> Bool {
        printLog(out: "switchFilterView.shouldChange() \(switchFilterView.shouldChange())")
        printLog(out: "roadFilterView.shouldChanged \(roadFilterView.shouldChanged())")
        printLog(out: "accessFilterView.shouldChanged \(accessFilterView.shouldChanged())")
        printLog(out: "placeFilterView.shouldChanged() \(placeFilterView.shouldChanged())")
        printLog(out: "speedFilterView.shouldChanged() \(speedFilterView.shouldChanged())")
        printLog(out: "typeFilterView.shouldChange() \(typeFilterView.shouldChange())")
        printLog(out: "companyFilterView.shouldChange() \(companyFilterView.shouldChange())")
        return switchFilterView.shouldChange() || roadFilterView.shouldChanged() || accessFilterView.shouldChanged() || placeFilterView.shouldChanged() || speedFilterView.shouldChanged() || typeFilterView.shouldChange() || companyFilterView.shouldChange()
    }
}

extension NewChargerFilterViewController: NewDelegateFilterChange {
    func changedFilter() {
        Observable.just(shouldChanged())
            .bind(to: saveBtn.rectBtn.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
}
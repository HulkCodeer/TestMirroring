//
//  ChargerFilterViewController.swift
//  evInfra
//
//  Created by SH on 2021/08/02.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit

protocol DelegateChargerFilterView: AnyObject {
    func onApplyFilter()    
}

class ChargerFilterViewController: UIViewController {
    
    private lazy var customNaviBar = CommonNaviView().then {
        $0.naviTitleLbl.text = "필터설정"
    }
    private lazy var resetButton = UIButton().then {
        $0.setTitle("초기화", for: .normal)
        $0.setTitleColor(UIColor(named: "content-primary"), for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16)
    }
    
    @IBOutlet var filterStackView: UIStackView!
    @IBOutlet var accessFilter: FilterAccessView!
    @IBOutlet var typeFilter: FilterTypeView!
    @IBOutlet var speedFilter: FilterSpeedView!
    @IBOutlet var placeFilter: FilterPlaceView!
    @IBOutlet var roadFilter: FilterRoadView!
    @IBOutlet var priceFilter: FilterPriceView!
    @IBOutlet var companyFilter: FilterCompanyView!
    
    @IBOutlet weak var btnApply: UIButton!
    
    @IBOutlet var companyViewHeight: NSLayoutConstraint!
    internal weak var delegate: DelegateChargerFilterView?
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func loadView() {
        super.loadView()
        
        prepareActionBar()
        initView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        companyViewHeight.constant = companyFilter.getHeight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FilterEvent.viewFilter.logEvent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func checkChange() -> Bool{
        return typeFilter.isChanged() || speedFilter.isChanged() || roadFilter.isChanged() || placeFilter.isChanged()
            || priceFilter.isChanged() || accessFilter.isChanged() || companyFilter.isChanged()
    }
    
    @IBAction func onClickApplyBtn(_ sender: Any) {
        typeFilter.applyFilter()
        speedFilter.applyFilter()
        roadFilter.applyFilter()
        placeFilter.applyFilter()
        priceFilter.applyFilter()
        accessFilter.applyFilter()
        companyFilter.applyFilter()
        delegate?.onApplyFilter()
            
        FilterManager.sharedInstance.logEventWithFilter("필터")
        GlobalDefine.shared.mainNavi?.pop()
    }
    
    func prepareActionBar() {
        customNaviBar.backClosure = {
            if (self.checkChange()){
                let ok = UIAlertAction(title: "나가기", style: .default, handler: {(ACTION) -> Void in
                    self.navigationController?.pop()
                })
                let cancel = UIAlertAction(title: "취소", style: .default, handler: {(ACTION) -> Void in})
                var actions = Array<UIAlertAction>()
                actions.append(ok)
                actions.append(cancel)
                UIAlertController.showAlert(title: "뒤로가기", message: "필터를 저장하지 않고 나가시겠습니까?", actions: actions)
            } else {
                self.navigationController?.pop()
            }
            
        }
        
        view.addSubview(customNaviBar)
        customNaviBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(Constants.view.naviBarHeight)
        }

        resetButton.addTarget(self, action: #selector(resetFilter), for: .touchUpInside)
        customNaviBar.addSubview(resetButton)
        resetButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(10)
            $0.width.equalTo(60)
        }

    }
    
    func initView(){
        btnApply.layer.cornerRadius = 6
        
        setApplyBtnStatus(enabled: false)
                
        typeFilter.delegate = self
        speedFilter.delegate = self
        roadFilter.delegate = self
        placeFilter.delegate = self
        priceFilter.delegate = self
        accessFilter.delegate = self
        companyFilter.delegate = self
        
        typeFilter.showExpandView()        
        typeFilter.slowTypeChangeDelegate = self
        
        speedFilter.slowSpeedChangeDelegate = self
    }
    
    func setApplyBtnStatus(enabled : Bool) {
        btnApply.isEnabled = enabled
        if enabled {
            btnApply.setTitleColor(UIColor(named: "content-primary"), for: .normal)
            btnApply.backgroundColor = UIColor(named: "background-positive")
        } else {
            btnApply.setTitleColor(UIColor(named: "content-disabled"), for: .normal)
            btnApply.backgroundColor = UIColor(named: "background-disabled")
        }
    }
    
    @objc
    fileprivate func resetFilter(){
        let ok = UIAlertAction(title: "초기화", style: .default, handler: {(ACTION) -> Void in
            self.typeFilter.resetFilter()
            self.speedFilter.resetFilter()
            self.roadFilter.resetFilter()
            self.placeFilter.resetFilter()
            self.priceFilter.resetFilter()
            self.accessFilter.resetFilter()
            self.companyFilter.resetFilter()
                        
           FilterEvent.clickFilterReset.logEvent()
        })
        let cancel = UIAlertAction(title: "취소", style: .default, handler: {(ACTION) -> Void in})
        var actions = Array<UIAlertAction>()
        actions.append(cancel)
        actions.append(ok)
        UIAlertController.showAlert(title: "필터 초기화", message: "필터를 초기화 하시겠습니까?", actions: actions)
    }
}

extension ChargerFilterViewController : DelegateFilterChange {
    func onChangedFilter(type: FilterType) {
        setApplyBtnStatus(enabled: checkChange())
    }
}

extension ChargerFilterViewController : DelegateSlowTypeChange {
    func onChangeSlowType(slowOn: Bool) {
        speedFilter.setSlowOn(slowOn: slowOn)
    }
}

extension ChargerFilterViewController : DelegateSlowSpeedChange {
    func onChangeSlowSpeed(isSlow: Bool) {
        typeFilter.setSlowTypeOn(slowTypeOn: isSlow)
    }
}

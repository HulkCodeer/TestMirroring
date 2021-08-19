//
//  ChargerFilterViewController.swift
//  evInfra
//
//  Created by SH on 2021/08/02.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit
import Material
protocol DelegateChargerFilterView {
    func onApplyFilter()
}

class ChargerFilterViewController: UIViewController {
    
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
    var delegate: DelegateChargerFilterView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        initView()
    
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    func checkChange() -> Bool{
        return typeFilter.isChanged() || speedFilter.isChanged() || roadFilter.isChanged() || placeFilter.isChanged()
            || priceFilter.isChanged() || accessFilter.isChanged() || companyFilter.isChanged()
    }
    
    @IBAction func onClickApplyBtn(_ sender: Any) {
        if (checkChange()) {
            typeFilter.applyFilter()
            speedFilter.applyFilter()
            roadFilter.applyFilter()
            placeFilter.applyFilter()
            priceFilter.applyFilter()
            accessFilter.applyFilter()
            companyFilter.applyFilter()
            delegate?.onApplyFilter()
            self.navigationController?.pop()
        } else {
            let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in})
            var actions = Array<UIAlertAction>()
            actions.append(ok)
            UIAlertController.showAlert(title: "필터 저장 실패", message: "저장할 변경사항이 없습니다", actions: actions)
        }
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        let logoutButton = UIButton()
        logoutButton.setTitle("초기화", for: .normal)
        logoutButton.setTitleColor(UIColor(rgb: 0x15435C), for: .normal)
        logoutButton.titleLabel?.font = .systemFont(ofSize: 14)
        logoutButton.addTarget(self, action: #selector(resetFilter), for: .touchUpInside)
        
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "필터설정"
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.rightViews = [logoutButton]
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func initView(){
        btnApply.backgroundColor = UIColor(named: "content-positive")
        btnApply.layer.cornerRadius = 6
    }
    
    @objc
    fileprivate func handleBackButton() {
        if (checkChange()){
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
        })
        let cancel = UIAlertAction(title: "취소", style: .default, handler: {(ACTION) -> Void in})
        var actions = Array<UIAlertAction>()
        actions.append(cancel)
        actions.append(ok)
        UIAlertController.showAlert(title: "필터 초기화", message: "필터를 초기화 하시겠습니까?", actions: actions)
    }
}

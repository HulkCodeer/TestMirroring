//
//  ChargerFilterViewController.swift
//  evInfra
//
//  Created by SH on 2021/08/02.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit
import Material

class ChargerFilterViewController: UIViewController {
    
    @IBOutlet var accessFilter: FilterAccessView!
    @IBOutlet var typeFilter: FilterTypeView!
    @IBOutlet var speedFilter: FilterSpeedView!
    @IBOutlet var placeFilter: FilterPlaceView!
    @IBOutlet var roadFilter: FilterRoadView!
    @IBOutlet var priceFilter: FilterPriceView!
    @IBOutlet var companyFilter: FilterCompanyView!
    
    @IBOutlet weak var btnApply: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        initView()
    
    }
    
    @IBAction func onClickApplyBtn(_ sender: Any) {
        // check change
        typeFilter.applyFilter()
        speedFilter.applyFilter()
        roadFilter.applyFilter()
        placeFilter.applyFilter()
        priceFilter.applyFilter()
        accessFilter.applyFilter()
        companyFilter.applyFilter()
    }
    
    func prepareActionBar() {
//        let backButton = IconButton(image: Icon.cm.arrowBack)
//        backButton.tintColor = UIColor(rgb: 0x15435C)
//        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        let logoutButton = UIButton()
        logoutButton.setTitle("초기화", for: .normal)
        logoutButton.setTitleColor(UIColor(rgb: 0x15435C), for: .normal)
        logoutButton.titleLabel?.font = .systemFont(ofSize: 14)
        logoutButton.addTarget(self, action: #selector(resetFilter), for: .touchUpInside)
        
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "필터설정"
//        navigationItem.leftViews = [backButton]
        navigationItem.rightViews = [logoutButton]
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func initView(){
        btnApply.backgroundColor = UIColor(named: "content-positive")
        btnApply.layer.cornerRadius = 6
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    @objc
    fileprivate func resetFilter(){
        print("필터 초기화")
        typeFilter.resetFilter()
        speedFilter.resetFilter()
        roadFilter.resetFilter()
        placeFilter.resetFilter()
        priceFilter.resetFilter()
        accessFilter.resetFilter()
        companyFilter.resetFilter()
    }
    
}

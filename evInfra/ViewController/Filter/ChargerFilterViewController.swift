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
    @IBOutlet weak var companyFilter: UIView!
    
    @IBOutlet weak var companyHeight: NSLayoutConstraint!
    @IBOutlet weak var btnApply: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    func initView(){
        btnApply.backgroundColor = UIColor(named: "content-positive")
        btnApply.layer.cornerRadius = 6
    }
}

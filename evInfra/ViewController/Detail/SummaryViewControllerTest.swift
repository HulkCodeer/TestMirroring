//
//  SummaryViewControllerTest.swift
//  evInfra
//
//  Created by SooJin Choi on 2021/08/13.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit

class SummaryViewControllerTest: UIViewController {
    
    @IBOutlet weak var detailView: UIView!
    
    @IBOutlet var stationImg: UIImageView!
    @IBOutlet var stationNameLb: UILabel!
    @IBOutlet var favoriteBtn: UIButton!  // btn_main_favorite
    
    @IBOutlet var shareBtn: UIButton!
    @IBOutlet var addrLb: UILabel!
    @IBOutlet var copyBtn: UIButton!
    
    @IBOutlet var chargerTypeView: UIStackView!
    @IBOutlet var StateCountView: UIView!
    @IBOutlet var stateLb: UILabel!
    @IBOutlet var fastCountLb: UILabel!
    @IBOutlet var slowCountLb: UILabel!
    @IBOutlet var filterView: UIStackView!
    
    @IBOutlet var startBtn: UIButton!
    @IBOutlet var addBtn: UIButton!
    @IBOutlet var endBtn: UIButton!
    @IBOutlet var navigationBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
    override func viewWillLayoutSubviews() {
        true ? layoutMainSummary() : layoutDetailSummary()
    }
    
    func layoutMainSummary() {
        
    }
    
    func layoutDetailSummary() {
        
    }
    

    func initView() {
        
    }
}

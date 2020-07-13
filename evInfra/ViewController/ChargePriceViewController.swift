//
//  ChargePriceViewController.swift
//  evInfra
//
//  Created by SooJin Choi on 2020/07/13.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import UIKit
import Material

class ChargePriceViewController: UIViewController {
    @IBOutlet weak var tvChargePriceMb: UITableView!
    @IBOutlet weak var tvInquiryLink: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let testCompany = ["test", "test", "test", "test","test", "test", "test", "test"]
    let testPrice = ["0.0", "0.0", "0.0", "0.0","0.0", "0.0", "0.0", "0.0"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        
        initView()
        scrollView.delegate = self
        tvChargePriceMb.dataSource = self
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
    }
    
    func initView() {
        tvChargePriceMb.frame.size = tvChargePriceMb.contentSize
        tvInquiryLink.frame.size = tvInquiryLink.contentSize
        //        tvInquiryLink.isScrollEnabled = false
    }
    
     func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M"
        let nameOfMonth = dateFormatter.string(from: now)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = nameOfMonth+"월 충전요금 안내"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
}

extension ChargePriceViewController: UITableViewDataSource{
//    table row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testCompany.count
    }
    
//    row data setting
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChargePriceTableViewCell") as! ChargePriceTableViewCell
        
        cell.lbChargePrice.text = testPrice[indexPath.row]
        cell.lbChargeCompany.text = testCompany[indexPath.row]
        
        return cell
    }
    
}
extension ChargePriceViewController: UITableViewDelegate{
    
}

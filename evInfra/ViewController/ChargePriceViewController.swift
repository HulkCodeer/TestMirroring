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
    
    @IBOutlet weak var tvEVRowCompany: UIStackView!
    @IBOutlet weak var tvEvRowPrice: UIStackView!
    
    @IBOutlet weak var lbEVRowKor: UILabel!
    @IBOutlet weak var lbEVRowGS: UILabel!
    @IBOutlet weak var lbEVRowSt: UILabel!
    @IBOutlet weak var lbEVKorPrice: UILabel!
    @IBOutlet weak var lbEVRowGSPrice: UILabel!
    @IBOutlet weak var lbEVRowStPrice: UILabel!
    
    let testCompany = ["test", "test", "test", "test","test", "test", "test", "test"]
    let testPrice = ["0.0", "0.0", "0.0", "0.0","0.0", "0.0", "0.0", "0.0"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
    }

//    override func viewWillLayoutSubviews(){
//        super.viewWillLayoutSubviews()
//    }

    override func viewDidLayoutSubviews() {
        setEVRowBorder()
        prepareTableView()
    }
    
    func setEVRowBorder() {
        lbEVRowKor.setBorderRadius(.topLeft, radius: 4, borderColor: UIColor.lightGray, borderWidth: 1)
        lbEVRowGS.setBorderRadius(.allCorners, radius: 0, borderColor: UIColor.lightGray, borderWidth: 1)
        lbEVRowSt.setBorderRadius(.topRight, radius: 4, borderColor: UIColor.lightGray, borderWidth: 1)

        lbEVKorPrice.setBorderRadius(.bottomLeft, radius: 4, borderColor: UIColor.lightGray, borderWidth: 1)
        lbEVRowGSPrice.setBorderRadius(.allCorners, radius: 0, borderColor: UIColor.lightGray, borderWidth: 1)
        lbEVRowStPrice.setBorderRadius(.bottomRight, radius: 4, borderColor: UIColor.lightGray, borderWidth: 1)
        
        lbEVRowKor.layer.backgroundColor = UIColor.lightGray.cgColor
        lbEVRowGS.layer.backgroundColor = UIColor.lightGray.cgColor
        lbEVRowSt.layer.backgroundColor = UIColor.lightGray.cgColor
//        lbEVKorPrice.layer.backgroundColor = UIColor.lightGray.cgColor
//        lbEVRowGS.layer.backgroundColor = UIColor.lightGray.cgColor
//        lbEVRowSt.layer.backgroundColor = UIColor.lightGray.cgColor
    }
    
//    func initView() {
//        tvChargePriceMb.frame.size = tvChargePriceMb.contentSize
//        tvInquiryLink.frame.size = tvInquiryLink.contentSize
//    }
    
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
    func prepareTableView() {
        tvChargePriceMb.delegate = self
        tvChargePriceMb.dataSource = self
    }
    
//    table row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testCompany.count
    }
    
//    row data setting
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChargePriceTableViewCell") as! ChargePriceTableViewCell
    
        cell.lbChargeCompany.text = testCompany[indexPath.row]
        cell.lbChargePrice.text = testPrice[indexPath.row]
        
        if indexPath.row == 0{
            // first row
            cell.lbChargeCompany.setBorderRadius(.topLeft, radius: 6, borderColor: UIColor.lightGray, borderWidth: 2)
            cell.lbChargePrice.setBorderRadius(.topRight, radius: 6, borderColor: UIColor.white, borderWidth: 2)
            
        }else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1 {
            // last row
            cell.lbChargeCompany.setBorderRadius(.bottomLeft, radius: 6, borderColor: UIColor.lightGray, borderWidth: 2)
            cell.lbChargePrice.setBorderRadius(.bottomRight, radius: 6, borderColor: UIColor.white, borderWidth: 2)
            
        }else{
            // center
            cell.lbChargeCompany.setBorderRadius(.allCorners , radius: 0, borderColor: UIColor.lightGray, borderWidth: 2)
            cell.lbChargePrice.setBorderRadius(.allCorners, radius: 0, borderColor: UIColor.white, borderWidth: 2)
        }
        
        return cell
    }
}

extension ChargePriceViewController: UITableViewDelegate{
    
}


//
//  ChargePriceViewController.swift
//  evInfra
//
//  Created by SooJin Choi on 2020/07/13.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON

class ChargePriceViewController: UIViewController {
    
    @IBOutlet weak var tvChargePriceMb: UITableView!
    @IBOutlet weak var tvInquiryLink: UITextView!
    
    @IBOutlet weak var tvEVRowCompany: UIStackView!
    @IBOutlet weak var tvEvRowPrice: UIStackView!
    
    @IBOutlet weak var lbEVRowKor: UILabel!
    @IBOutlet weak var lbEVRowGS: UILabel!
    @IBOutlet weak var lbEVRowSt: UILabel!
    @IBOutlet weak var lbEVKorPrice: UILabel!
    @IBOutlet weak var lbEVRowGSPrice: UILabel!
    @IBOutlet weak var lbEVRowStPrice: UILabel!
    
    @IBOutlet weak var lbEVTableTitle: UILabel!
    @IBOutlet weak var lbMBTableTitle: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContent: UIView!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lbStackHeight: NSLayoutConstraint!
    
    let dbManager = DBManager.sharedInstance
       
    var chargePriceData: JSON!
    
    struct Constants {
        static let cellHeight: CGFloat = 40
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        
        self.getEvChargePrice()
        self.getMbChargePrice()
       
        initView()
    }

    // TableView Border, BGcolor, Management cell, Resize Height
    override func viewDidLayoutSubviews() {
        setEVRowBorder()
        prepareTableView()
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
    
    func initView() {
        // UILabel title round
        lbEVTableTitle.roundCorners(.allCorners, radius: 4)
        lbMBTableTitle.roundCorners(.allCorners, radius: 4)
    }
    
    func setEVRowBorder() {
        // EV member charge price table BG color, round board
        lbEVRowKor.setBorderRadius(.topLeft, radius: 4, borderColor:  UIColor(hex: "#DCDCDC"), borderWidth: 2)
        lbEVRowGS.setBorderRadius(.allCorners, radius: 0, borderColor:  UIColor(hex: "#DCDCDC"), borderWidth: 2)
        lbEVRowSt.setBorderRadius(.topRight, radius: 4, borderColor:  UIColor(hex: "#DCDCDC"), borderWidth: 2)

        lbEVKorPrice.setBorderRadius(.bottomLeft, radius: 4, borderColor:  UIColor(hex: "#DCDCDC"), borderWidth: 2)
        lbEVRowGSPrice.setBorderRadius(.allCorners, radius: 0, borderColor:  UIColor(hex: "#DCDCDC"), borderWidth: 2)
        lbEVRowStPrice.setBorderRadius(.bottomRight, radius: 4, borderColor:  UIColor(hex: "#DCDCDC"), borderWidth: 2)
        
        lbEVRowKor.backgroundColor = UIColor(hex: "#F5F5F5")
        lbEVRowGS.backgroundColor = UIColor(hex: "#F5F5F5")
        lbEVRowSt.backgroundColor = UIColor(hex: "#F5F5F5")
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
}

extension ChargePriceViewController{
    // Get charge price data for EV member
    internal func getEvChargePrice() {
        Server.getChargePriceForEvInfra() { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if let code = json["code"].int {
                    if code == 1000 {
                        if let kor = json["0"].string{
                            if !kor.isEmpty {
                                self.lbEVKorPrice.text = kor+" 원"
                            }
                        }
                        if let gs = json["41"].string {
                            if !gs.isEmpty {
                                self.lbEVRowGSPrice.text = gs+" 원"
                            }
                        }
                        if let st = json["L"].string {
                            if !st.isEmpty {
                                self.lbEVRowStPrice.text = st+" 원"
                            }
                        }
                    }
                }
                self.tvChargePriceMb.reloadData()
            }
        }
    }
    
    func getMbChargePrice() {
        // Get chargePrice for each company members
        Server.getMembershipCahrgePrice() { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if let code = json["code"].int {
                    if code == 1000 {
                        self.chargePriceData = json["list"]
                    }
                }
                self.tvChargePriceMb.reloadData()
                self.adjustTableview()
            }
        }
    }
    
    func adjustTableview() {
        if self.tvChargePriceMb.contentSize.height > 0.0 {
            self.tableViewHeight.constant = self.tvChargePriceMb.contentSize.height
            tvChargePriceMb.layoutIfNeeded()
        }
    }
}

extension ChargePriceViewController: UITableViewDataSource{
    func prepareTableView() {
        tvChargePriceMb.delegate = self
        tvChargePriceMb.dataSource = self
        
        tvChargePriceMb.autoresizingMask = UIViewAutoresizing.flexibleHeight
    }
    
    // Table row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.chargePriceData == nil {
            return 0
        }

        if (self.chargePriceData.arrayValue.count == 0 || self.chargePriceData == JSON.null) {
            return 0
        }
        
        return self.chargePriceData.arrayValue.count
    }
    
    // Row data setting
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chargePrice = self.chargePriceData.arrayValue[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChargePriceTableViewCell") as! ChargePriceTableViewCell
        cell.lbChargeCompany.text = dbManager.getCompanyName(companyId: chargePrice["company_id"].stringValue)
        cell.lbChargePrice.text = chargePrice["price"].stringValue
        
        cell.lbChargeCompany.backgroundColor = UIColor(hex: "#F2F2F2")
        if indexPath.row == 0 {
            // First row
            cell.lbChargeCompany.setBorderRadius(.topLeft, radius: 6, borderColor: UIColor(hex: "#DCDCDC"), borderWidth: 2)
            cell.lbChargePrice.setBorderRadius(.topRight, radius: 6, borderColor: UIColor(hex: "#DCDCDC"), borderWidth: 2)
        } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1 {
            // Last row
            cell.lbChargeCompany.setBorderRadius(.bottomLeft, radius: 6, borderColor: UIColor(hex: "#DCDCDC"), borderWidth: 2)
            cell.lbChargePrice.setBorderRadius(.bottomRight, radius: 6, borderColor: UIColor(hex: "#DCDCDC"), borderWidth: 2)
            
        } else {
            // Center
            cell.lbChargeCompany.setBorderRadius(.allCorners , radius: 0, borderColor: UIColor(hex: "#DCDCDC"), borderWidth: 2)
            cell.lbChargePrice.setBorderRadius(.allCorners, radius: 0, borderColor: UIColor(hex: "#DCDCDC"), borderWidth: 2)
        }
        
        return cell
    }
    
    // Set tableView height, scrollView heigth
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension ChargePriceViewController: UITableViewDelegate{
    
}


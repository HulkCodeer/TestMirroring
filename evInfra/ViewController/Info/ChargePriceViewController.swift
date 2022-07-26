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
    @IBOutlet var lbChargePriceTitle: UILabel!
    @IBOutlet var lbChargePriceMsg: UILabel!
    
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
       
    var chargePriceData: JSON!
    
    struct Constants {
        static let cellHeight: CGFloat = 40
    }
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareTableView()
        
        self.getEvChargePrice()
        self.getMbChargePrice()
       
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // TableView Border, BGcolor, Management cell, Resize Height
    override func viewDidLayoutSubviews() {
        setEVRowBorder()
    }
    
    func prepareActionBar() {
       let backButton = IconButton(image: Icon.cm.arrowBack)
       backButton.tintColor = UIColor(named: "content-primary")
       backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
       
       let now = Date()
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "M"
       let nameOfMonth = dateFormatter.string(from: now)
       
       navigationItem.leftViews = [backButton]
       navigationItem.hidesBackButton = true
       navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
       navigationItem.titleLabel.text = nameOfMonth + "월 충전요금 안내"
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

extension ChargePriceViewController {
    // Get charge price data for EV member
    internal func getEvChargePrice() {
        Server.getChargePriceForEvInfra() { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if let code = json["code"].int {
                    if code == 1000 {
                        if let env = json["0"].string{
                            if !env.isEmpty {
                                self.lbEVKorPrice.text = env + " 원"
                            }
                        }
                        if let gsc = json["41"].string {
                            if !gsc.isEmpty {
                                self.lbEVRowGSPrice.text = gsc + " 원"
                            }
                        }
                        if let straffic = json["L"].string {
                            if !straffic.isEmpty {
                                self.lbEVRowStPrice.text = straffic + " 원"
                            }
                        }
                        if let strTitle = json["title"].string {
                            if !strTitle.isEmpty {
                                self.lbChargePriceTitle.text = strTitle
                            }
                        }
                        if let strMsg = json["msg"].string {
                            if !strMsg.isEmpty {
                                self.lbChargePriceMsg.text = strMsg
                            }
                        }
                    }else{
                        self.lbChargePriceTitle.text = "충전요금 인상 안내"
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

extension ChargePriceViewController: UITableViewDataSource, UITableViewDelegate {
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
        let cName = ChargerManager.sharedInstance.getCompanyName(companyID: chargePrice["company_id"].stringValue)
        cell.lbChargeCompany.text = cName
        cell.lbChargePrice.text = chargePrice["price"].stringValue
        
        cell.lbChargeCompany.backgroundColor = UIColor(hex: "#F2F2F2")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let priceCell = cell as! ChargePriceTableViewCell
        priceCell.layoutIfNeeded()

        if indexPath.row == 0 {
            // First row
            priceCell.lbChargeCompany.setBorderRadius(.topLeft, radius: 6, borderColor: UIColor(hex: "#DCDCDC"), borderWidth: 2)
            priceCell.lbChargePrice.setBorderRadius(.topRight, radius: 6, borderColor: UIColor(hex: "#DCDCDC"), borderWidth: 2)
        } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            // Last row
            priceCell.lbChargeCompany.setBorderRadius(.bottomLeft, radius: 6, borderColor: UIColor(hex: "#DCDCDC"), borderWidth: 2)
            priceCell.lbChargePrice.setBorderRadius(.bottomRight, radius: 6, borderColor: UIColor(hex: "#DCDCDC"), borderWidth: 2)
        } else {
            // Center
            priceCell.lbChargeCompany.setBorderRadius(.allCorners , radius: 0, borderColor: UIColor(hex: "#DCDCDC"), borderWidth: 2)
            priceCell.lbChargePrice.setBorderRadius(.allCorners, radius: 0, borderColor: UIColor(hex: "#DCDCDC"), borderWidth: 2)
        }
    }
    
    // Set tableView height, scrollView heigth
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

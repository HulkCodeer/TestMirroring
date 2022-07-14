//
//  LotteRentIntoViewController.swift
//  evInfra
//
//  Created by SH on 2021/01/13.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON
import Material
import UIKit
class LotteRentInfoViewController: UIViewController {
    @IBOutlet var labelCarNo: UILabel!
    @IBOutlet var labelContrDate: UILabel!
    @IBOutlet var labelPoint: UILabel!
    var activeTextView: Any? = nil
    
    var memberInfo : MemberPartnershipInfo?
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
            guard let self = self else { return }
            if isLogin {
                self.checkLotteRentInfo()
            } else {
                MemberManager.shared.showLoginAlert()
            }
        }
    }
    
    func checkLotteRentInfo() {
        Server.getLotteRentInfo {(isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].stringValue.elementsEqual("1000") {
                    self.labelCarNo.text = json["car_no"].stringValue
                    self.labelContrDate.text = json["start_date"].stringValue + " ~ " + json["end_date"].stringValue
                    self.labelPoint.text = json["point"].stringValue.currency() + " 원"
                }
            }
        }
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "등록된 카드 정보"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
}

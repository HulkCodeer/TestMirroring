//
//  CouponCodeViewController.swift
//  evInfra
//
//  Created by SooJin Choi on 2021/03/08.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import UIKit
import Material
import SwiftyJSON

class CouponCodeViewController: UIViewController {
    @IBOutlet var registerCouponBtn: UIButton!
    @IBOutlet var editField: UITextField!
    @IBOutlet var errorLb: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
    }
    
    override func viewWillLayoutSubviews() {
        registerCouponBtn.setDefaultBackground(cornerRadius: 10)
    }
    
    @IBAction func onClickRegisterCoupon(_ sender: Any) {
        if let editCode = editField.text{
            let couponCode = editCode.trimmingCharacters(in: .whitespaces)
            if !couponCode.isEmpty{
                Server.registerCoupon(couponCode: couponCode) { (isSuccess, value) in
                    if isSuccess {
                        self.couponRegiResponse(json: JSON(value))
                    }
                }
            }else{
                errorLb.text = "쿠폰번호를 입력해주세요."
            }
        }
    }
    
    func couponRegiResponse(json: JSON) {
        switch json["code"].intValue {
        case 1000:  // 베리 적립 성공
            errorLb.text = ""
            Snackbar().show(message: "베리가 적립되었습니다.")
        case 1304:  // DB/마더브레인 데이터 오류
            errorLb.text = "오류로 인해 베리 적립에 실패하였습니다. \n\n자세한 사항은 고객센터(070-0000-0000)로 \n문의 바랍니다. "
        case 1302:  // 이미 등록된 쿠폰
            errorLb.text = "이미 등록된 쿠폰번호 입니다."
        case 1303:  // 진행중인 이벤트가 아님
            errorLb.text = "진행중인 이벤트가 아닙니다."
        case 1301:
            errorLb.text = "유효하지 않은 쿠폰입니다.\n쿠폰번호를 다시 확인해 주세요."
            break
        default:
            break
        }
    }
}

extension CouponCodeViewController {
    func prepareActionBar() {
        var backButton: IconButton!
        backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(onClickBackBtn), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "쿠폰 번호 등록"
        self.navigationController?.isNavigationBarHidden = false
    }
    @objc
    fileprivate func onClickBackBtn() {
        self.navigationController?.pop()
    }
}

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
        registerCouponBtn.layer.cornerRadius = 4
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
          self.view.endEditing(true)
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
        let msg:String = json["msg"].stringValue
        switch json["code"].intValue {
        case 1000:  // 베리 적립 성공
            errorLb.text = ""
            Snackbar().show(message: msg)
        case 1301,  // 쿠폰번호 없음
            1302,  // 이미 등록된 회원
            1303,  // 진행중인 이벤트가 아님
            1304:  // 마더브레인 데이터 오류 혹은 DB 수정 오류 (event_coupons.value == 0)
            errorLb.text = msg
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
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(onClickBackBtn), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "쿠폰 번호 등록"
        self.navigationController?.isNavigationBarHidden = false
    }
    @objc
    fileprivate func onClickBackBtn() {
        self.navigationController?.pop()
    }
}

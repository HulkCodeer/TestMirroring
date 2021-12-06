//
//  RepayResultViewController.swift
//  evInfra
//
//  Created by SH on 2021/11/19.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit
import SwiftyJSON
import Material
import M13Checkbox

protocol RepaymentResultDelegate {
    func onConfirmBtnPressed()
}
class RepayResultViewController: UIViewController {
    @IBOutlet weak var ivResultIcon: UIImageView!
    @IBOutlet weak var viewFailMsg: UIButton!
    @IBOutlet weak var lbResultTitle: UILabel!
    @IBOutlet weak var lbResultSubTitle: UILabel!
    @IBOutlet weak var btnConfirm: UIButton!
    var delegate: RepaymentResultDelegate?
    var payResult: ChargingStatus?
    var isSuccess: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let payResult = payResult {
            isSuccess = (payResult.resultCode == 1000)
        } else {
            self.navigationController?.pop()
        }
        
        if isSuccess {
            UserDefault().saveBool(key: UserDefault.Key.HAS_FAILED_PAYMENT, value: false)
        }
        prepareActionBar()
        prepareView()
    }
    
    override func viewDidLayoutSubviews() {
        viewFailMsg.layer.cornerRadius = 8
        btnConfirm.layer.cornerRadius = 6
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        if isSuccess {
            navigationItem.titleLabel.text = "미수금 결제 완료"
        } else {
            navigationItem.titleLabel.text = "제한 해제 불가"
        }
        self.navigationController?.isNavigationBarHidden = false
    }
        
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
        if isSuccess {
            self.delegate?.onConfirmBtnPressed()
        }
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        self.navigationController?.pop()
        if isSuccess {
            self.delegate?.onConfirmBtnPressed()
        }
    }
    
    func prepareView() {
        if let result = payResult {
            if result.resultCode == 1000 { // success
                let point = Int(result.totalPoint ?? "0" as String) ?? 0
                if point > 0 {
                    lbResultTitle.text = "미수금 결제가 완료되었습니다. \n남은 베리 \(point) 베리"
                } else {
                    lbResultTitle.text = "미수금 결제가 완료되었습니다."
                    lbResultSubTitle.isHidden = true
                }
                viewFailMsg.isHidden = true
            } else {
                ivResultIcon.image = UIImage(named: "icon_exclamation_circle_xl")
                lbResultTitle.text = "제한 해지가 불가합니다"
                viewFailMsg.setTitle(result.payResultMsg, for: .normal)
                lbResultSubTitle.text = "카드 상태 확인후 다시 시도해주시기 바랍니다."
            }
        }
    }
}

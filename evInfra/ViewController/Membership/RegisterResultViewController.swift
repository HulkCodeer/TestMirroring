//
//  RegisterResultViewController.swift
//  evInfra
//
//  Created by SH on 2020/10/08.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import UIKit
import Material
class RegisterResultViewController : UIViewController {
    @IBOutlet var imgResult: UIImageView!
    @IBOutlet var imgCallCenter: UIImageView!
    @IBOutlet var btnComplete: UIButton!
    @IBOutlet var retryBtnContainer: UIStackView!
    @IBOutlet var tvResult: UITextView!
    @IBOutlet var btnRetry: UIButton!
    @IBOutlet var btnGoMain: UIButton!
    
    @IBAction func onClickCompleteBtn(_ sender: Any) {
        self.navigationController?.pop()
        self.delegate?.onConfirmBtnPressed(code: self.requestCode)
    }
    
    @IBAction func onClickRetryBtn(_ sender: Any) {
        self.navigationController?.pop()
    }
    
    @IBAction func onClickGoMainBtn(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    var requestCode : Int = -1
    var imgType : String = ""
    var showRetry : Bool = false
    var showCallBtn : Bool = false
    var message : String = ""
    internal weak var delegate : RegisterResultDelegate?
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("img : " + imgType)
        switch imgType {
        case "SUCCESS" :
            imgResult.image = UIImage(named: "result_check_img")
            break
        case "ERROR" :
            imgResult.image = UIImage(named: "result_noset_img")
            break
        case "QUESTION" :
            imgResult.image = UIImage(named: "result_already_img")
            break
        default :
            print("out of index")
        }
        
        if showRetry {
            retryBtnContainer.isHidden = false
            btnComplete.isHidden = true
        } else {
            retryBtnContainer.isHidden = true
            btnComplete.isHidden = false
        }
        
        tvResult.text = message
        
        if showCallBtn {
            imgCallCenter.isHidden = false
        } else {
            imgCallCenter.isHidden = true
        }
    }
    
    func prepareActionBar() {
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "조회 결과"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    override func viewWillLayoutSubviews() {
        btnComplete.layer.cornerRadius = 4
        btnRetry.layer.cornerRadius = 4
        btnRetry.layer.borderWidth = 1
        btnRetry.layer.borderColor = UIColor(named: "border-opaque")!.cgColor
        btnGoMain.layer.cornerRadius = 4
    }
    
    func initView() {
        tvResult.isScrollEnabled = false
        let callBtnTouch = UITapGestureRecognizer(target: self, action: #selector(self.onClickCallBtn))
        imgCallCenter.addGestureRecognizer(callBtnTouch)
    }
    
    @objc func onClickCallBtn(sender: UITapGestureRecognizer) {
        guard let number = URL(string : "tel://" + "070-8633-9009") else {
            return
        }
        UIApplication.shared.open(number)
    }
}
protocol RegisterResultDelegate: class {
    func onConfirmBtnPressed(code : Int)
}



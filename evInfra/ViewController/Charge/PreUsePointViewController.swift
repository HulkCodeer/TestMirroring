//
//  PreUsePointViewController.swift
//  evInfra
//
//  Created by SH on 2021/09/28.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation

import UIKit
import Material
import SwiftyJSON
class PreUsePointViewController: UIViewController {
    
    @IBOutlet weak var tfUsePoint: UITextField!
    
    @IBOutlet weak var btnAddOne: UIButton!
    @IBOutlet weak var btnAddFive: UIButton!
    @IBOutlet weak var btnAddTen: UIButton!
    @IBOutlet weak var btnAddAll: UIButton!
    @IBOutlet weak var btnSavePoint: UIButton!
    
    private var preUsePoint: Int = 0
    private var oldUsePoint: Int = 0
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareView()
        prepareTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if MemberManager.shared.isLogin {
            getUsePoint()
        } else {
            MemberManager.shared.showLoginAlert()
        }
    }
    
    override func viewDidLayoutSubviews() {
        btnAddOne.layer.cornerRadius = 12
        btnAddOne.layer.borderColor = UIColor(named: "border-opaque")?.cgColor
        btnAddOne.layer.borderWidth = 1
        btnAddFive.layer.cornerRadius = 12
        btnAddFive.layer.borderColor = UIColor(named: "border-opaque")?.cgColor
        btnAddFive.layer.borderWidth = 1
        btnAddTen.layer.cornerRadius = 12
        btnAddTen.layer.borderColor = UIColor(named: "border-opaque")?.cgColor
        btnAddTen.layer.borderWidth = 1
        btnAddAll.layer.cornerRadius = 12
        btnAddAll.layer.borderColor = UIColor(named: "border-opaque")?.cgColor
        btnAddAll.layer.borderWidth = 1
    }
    
    func prepareView() {
        let tap_touch = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        view.addGestureRecognizer(tap_touch)
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        let settingButton = UIButton()
        settingButton.setTitle("초기화", for: .normal)
        settingButton.setTitleColor(UIColor(named: "content-primary")!, for: .normal)
        settingButton.titleLabel?.font = .systemFont(ofSize: 14)
        settingButton.addTarget(self, action: #selector(handleResetButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.rightViews = [settingButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "베리 설정"
        navigationController?.isNavigationBarHidden = false
    }
    
    @objc fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    @objc
    fileprivate func handleResetButton() {
        // 설정된 값이 0이 아니면 초기화
        if oldUsePoint != 0 {
            preUsePoint = 0
            saveUsePoint()
        } else if preUsePoint != 0 {
            preUsePoint = 0
            updateView()
        }
    }
    
    @objc
    fileprivate func handleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func getUsePoint() {
        Server.getUsePoint{ (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].stringValue == "1000" {
                    self.preUsePoint = json["use_point"].intValue
                    self.oldUsePoint = json["use_point"].intValue
                    self.updateView()
                }
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료 후 재시도 바랍니다.")
            }
        }
    }
    
    @IBAction func onClickSaveBtn(_ sender: Any) {
        saveUsePoint()
    }
    
    @IBAction func onClickAddOne(_ sender: Any) {
        addUsePoint(point: 1000)
        updateView()
    }
    @IBAction func onClickAddFive(_ sender: Any) {
        addUsePoint(point: 5000)
        updateView()
    }
    @IBAction func onClickAddTen(_ sender: Any) {
        addUsePoint(point: 10000)
        updateView()
    }
    @IBAction func onClickAddAll(_ sender: Any) {
        preUsePoint = -1
        updateView()
    }
    
    func saveUsePoint() {
        Server.setUsePoint (usePoint: preUsePoint, useNow: true) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].stringValue == "1000" {
                    self.oldUsePoint = self.preUsePoint
                    Snackbar().show(message: "설정이 저장되었습니다.")
                    self.updateView()
                }
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료 후 재시도 바랍니다.")
            }
        }
    }
    
    func addUsePoint(point: Int) {
        if preUsePoint + point < 100000 {
            if (preUsePoint == -1) {
                preUsePoint = point
            } else {
                preUsePoint += point
            }
        } else {
            Snackbar().show(message: "베리 입력은 100,000원을 초과하여 입력하실 수 없습니다.")
        }
    }
    
    func updateView() {
        tfUsePoint.borderColor = UIColor(named: "content-disabled")
        if preUsePoint == -1 {
            tfUsePoint.text = "전액"
        } else {
            tfUsePoint.text = "\(self.preUsePoint)"
        }
        
        updateBtn()
    }
    
    func updateBtn() {
        if preUsePoint != oldUsePoint {
            btnSavePoint.isEnabled = true
            btnSavePoint.backgroundColor = UIColor(named: "content-positive")
            btnSavePoint.setTitleColor(UIColor(named: "content-primary"), for: .normal)
        } else {
            btnSavePoint.isEnabled = false
            btnSavePoint.backgroundColor = UIColor(named: "background-disabled")
            btnSavePoint.setTitleColor(UIColor(named: "content-disabled"), for: .normal)
        }
    }
}

extension PreUsePointViewController: UITextFieldDelegate {
    
    func prepareTextField() {
        self.tfUsePoint.delegate = self
        self.tfUsePoint.keyboardType = .numberPad
        
        self.tfUsePoint.layer.cornerRadius = 6
        self.tfUsePoint.layer.masksToBounds = true
        self.tfUsePoint.layer.borderColor = UIColor(named: "content-disabled")?.cgColor
        self.tfUsePoint.layer.borderWidth = 1.0
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        var newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        newString = newString.replacingOccurrences(of: ",", with: "") as NSString
        if newString.length > 5 {
            tfUsePoint.borderColor = UIColor(named: "content-negative")
            Snackbar().show(message: "베리 입력은 100,000원을 초과하여 입력하실 수 없습니다.")
            return false
        }
        
        tfUsePoint.borderColor = UIColor(named: "content-disabled")
        if newString.length > 0 {
            if !newString.isEqual(to: "전액") {
                if let point = Int(newString as String) {
                    preUsePoint = point
                    updateBtn()
                    if newString.hasPrefix("0"){
                        tfUsePoint.text = String(preUsePoint)
                        return false
                    }
                    return true
                } else {
                    preUsePoint = 0
                    tfUsePoint.text = String(preUsePoint)
                    updateBtn()
                    return false
                }
            }
        }
        return true
    }
}

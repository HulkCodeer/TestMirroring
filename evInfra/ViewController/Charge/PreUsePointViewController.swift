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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareTextField()
        getUsePoint()
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
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "베리 설정"
        navigationController?.isNavigationBarHidden = false
    }
    
    @objc fileprivate func handleBackButton() {
        self.navigationController?.pop()
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
    
    func updateView() {
        if preUsePoint == -1 {
            tfUsePoint.text = "전액"
        } else {
            tfUsePoint.text = "\(self.preUsePoint)".currency()
        }
        
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
    
    @IBAction func onClickSaveBtn(_ sender: Any) {
        Server.setUsePoint (usePoint: preUsePoint) { (isSuccess, value) in
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
    
    func addUsePoint(point: Int) {
        if (preUsePoint == -1) {
            preUsePoint = point
        } else {
            preUsePoint += point
        }
    }
}

extension PreUsePointViewController: UITextFieldDelegate {
    
    func prepareTextField() {
        self.tfUsePoint.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        var newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        newString = newString.replacingOccurrences(of: ",", with: "") as NSString
        if newString.length > 7 {
            return false
        }
        if newString.length > 0 {
            if !newString.isEqual(to: "전액") {
                if let point = Int(newString as String) {
                    preUsePoint = point
                } else {
                    preUsePoint = 0
                }
                tfUsePoint.text = String(preUsePoint).currency()
                return false
            }
        }
        return true
    }
}

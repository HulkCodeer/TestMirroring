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
        super.viewWillAppear(animated)
        MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
            guard let self = self else { return }
            if isLogin {
                self.getUsePoint()
            } else {
                MemberManager.shared.showLoginAlert()
            }
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
        PaymentEvent.clickResetBerry.logEvent()
        
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
//        let hasPayment = MemberManager.shared.hasPayment
//        let hasMembership = MemberManager.shared.hasMembership
        
        // TEST CODE
        let hasPayment = false
        let hasMembership = false
        
        switch (hasPayment, hasMembership) {
        case (false, false): // 피그마 case 1
            let popupModel = PopupModel(title: "EV Pay카드를 발급하시겠어요?",
                                        message: "베리는 EV Pay카드 발급 후\n충전 시 베리로 할인 받을 수 있어요.",
                                        confirmBtnTitle: "네 발급할게요.", cancelBtnTitle: "다음에 할게요.",
                                        confirmBtnAction: {
                let viewcon = MembershipGuideViewController()
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
            }, textAlignment: .center)
                
            let popup = VerticalConfirmPopupViewController(model: popupModel)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
            })
            
        case (false, true), (true, false), (true, true) : // 피그마 나머지 케이스 // 미수금 체크
            Server.getPayRegisterStatus { [weak self] (isSuccess, value) in
                guard let self = self else { return }
                if isSuccess {
                    let json = JSON(value)
                    let payCode = json["pay_code"].intValue
                    switch PaymentStatus(rawValue: payCode) {
                    case .PAY_FINE_USER:
                        switch (hasPayment, hasMembership) {
                        case (false, true): // 피그마 case 2
                            let popupModel = PopupModel(title: "결제 카드를 확인해주세요",
                                                        message: "현재 회원님의 결제정보에 오류가 있어\n다음 충전 시 베리를 사용할 수 없어요.",
                                                        confirmBtnTitle: "결제정보 확인하러가기", cancelBtnTitle: "다음에 할게요.",
                                                        confirmBtnAction: {
                                
                                Server.getPayRegisterStatus { (isSuccess, value) in
                                    if isSuccess {
                                        let json = JSON(value)
                                        let payCode = json["pay_code"].intValue
                                        switch PaymentStatus(rawValue: payCode) {
                                        case .PAY_NO_CARD_USER, .PAY_NO_USER: // 카드등록 아니된 멤버
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                                let viewcon = UIStoryboard(name : "Member", bundle: nil).instantiateViewController(ofType: MyPayinfoViewController.self)
                                                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                                            })
                                                                
                                        case .PAY_DEBTOR_USER: // 돈안낸 유저
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                                let viewcon = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(ofType: RepayListViewController.self)
                                                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                                            })
                                            
                                        default: self.dismiss(animated: true)
                                        }
                                    } else {
                                        self.dismiss(animated: true)
                                        Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
                                    }
                                }
                                
                            }, cancelBtnAction: {
                                self.dismiss(animated: true)
                            }, textAlignment: .center)
                                                    
                            let popup = VerticalConfirmPopupViewController(model: popupModel)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                            })
                            
                        case (true, false): // 피그마 case 3
                            UserDefault().saveBool(key: UserDefault.Key.IS_SHOW_BERRYSETTING_CASE3_POPUP, value: true)
                            let popupModel = PopupModel(title: "더 많은 충전소에서\n베리를 적립해보세요!",
                                                        message: "EV Pay카드 발급 시 환경부, 한국전력 등\n더 많은 충전소에서 적립할 수 있어요.",
                                                        confirmBtnTitle: "EV Pay카드 안내 보러가기", cancelBtnTitle: "다음에 할게요.",
                                                        confirmBtnAction: {
                                let viewcon = MembershipGuideViewController()
                                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                            }, textAlignment: .center)
                                
                            let popup = VerticalConfirmPopupViewController(model: popupModel)
                            GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                            
                        case (true, true): // 피그마 case 4
                            Server.setUsePoint (usePoint: self.preUsePoint, useNow: true) { [weak self] (isSuccess, value) in
                                guard let self = self else { return }
                                if isSuccess {
                                    let json = JSON(value)
                                    if json["code"].stringValue == "1000" {
                                        self.oldUsePoint = self.preUsePoint
                                        Snackbar().show(message: "설정이 저장되었습니다.")
                                        self.updateView()
                                        
                                        let setBerryAmount: String = self.preUsePoint == -1 ? "전액" : "\(self.preUsePoint)"
                                        let property: [String: Any] = ["setberryAmount": setBerryAmount]
                                        PaymentEvent.clickSetUpBerry.logEvent(property: property)
                                    }
                                } else {
                                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료 후 재시도 바랍니다.")
                                }
                            }
                            
                        default: break
                        }
                                                                                                    
                    case .PAY_DEBTOR_USER: // 돈안낸 유저
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            let viewcon = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(ofType: RepayListViewController.self)
                            GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                        })
                                                                                    
                    default: self.dismiss(animated: true)
                    }
                } else {
                    self.dismiss(animated: true)
                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
                }
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

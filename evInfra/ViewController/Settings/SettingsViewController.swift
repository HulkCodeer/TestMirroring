//
//  SettingsViewController.swift
//  evInfra
//
//  Created by bulacode on 30/10/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON

internal final class SettingsViewController: UIViewController {
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var alarmLocalSwitch: UISwitch!
    @IBOutlet weak var alarmMarketingSwitch: UISwitch!
    @IBOutlet var clusteringSwitch: UISwitch!
    
    let defaults = UserDefault()
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareSwitchs()
    }

    private func prepareActionBar() {
        var backButton: IconButton!
        backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "전체 설정"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func prepareSwitchs() {
        alarmSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        alarmLocalSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        alarmMarketingSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        clusteringSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        changeAllNotifications(isRecieve: defaults.readBool(key: UserDefault.Key.SETTINGS_ALLOW_NOTIFICATION))
        changeLocalNotifications(isRecieve: defaults.readBool(key: UserDefault.Key.SETTINGS_ALLOW_JEJU_NOTIFICATION))
        changeMarketingNotifications(isRecieve: defaults.readBool(key: UserDefault.Key.SETTINGS_ALLOW_MARKETING_NOTIFICATION))
        clusteringSwitch.isOn = defaults.readBool(key: UserDefault.Key.SETTINGS_CLUSTER)
    }
    
    @IBAction func onChangeAlarmSwitch(_ sender: Any) {
        alarmSwitchChanged(state: alarmSwitch.isOn)
    }
    
    @IBAction func onChangeAlarmLocalSwitch(_ sender: Any) {
        alarmLocalSwitchChanged(state: alarmLocalSwitch.isOn)
    }
    
    @IBAction func onChangeAlarmMarketingSwitch(_ sender: Any) {
        alarmMarketingSwitchChanged(state: alarmMarketingSwitch.isOn)
    }
    
    @IBAction func onChangeClusteringSwitch(_ sender: UISwitch) {
        defaults.saveBool(key: UserDefault.Key.SETTINGS_CLUSTER, value: sender.isOn)
    }
    
    @objc fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }

    private func alarmSwitchChanged(state: Bool) {
        Server.updateNotificationState(state: state) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let code = json["code"].stringValue
                if code.elementsEqual("1000") {
                    let isReceivePush = json["receive"].boolValue
                    self.defaults.saveBool(key: UserDefault.Key.SETTINGS_ALLOW_NOTIFICATION, value: isReceivePush)
                    self.changeAllNotifications(isRecieve: isReceivePush)
                }
            }
        }
    }
    
    private func alarmLocalSwitchChanged(state: Bool) {
        Server.updateJejuNotificationState(state: state) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let code = json["code"].stringValue
                if code.elementsEqual("1000") {
                    let isReceivePush = json["receive"].boolValue
                    self.defaults.saveBool(key: UserDefault.Key.SETTINGS_ALLOW_JEJU_NOTIFICATION, value: isReceivePush)
                    self.changeLocalNotifications(isRecieve: isReceivePush)
                }
            }
        }
    }
    
    private func alarmMarketingSwitchChanged(state: Bool) {
        Server.updateMarketingNotificationState(state: state) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let code = json["code"].stringValue
                if code.elementsEqual("1000") {
                    let isReceivePush = json["receive"].boolValue
                    self.defaults.saveBool(key: UserDefault.Key.SETTINGS_ALLOW_MARKETING_NOTIFICATION, value: isReceivePush)
                    self.changeMarketingNotifications(isRecieve: isReceivePush)
                    
                    let currDate = DateUtils.getFormattedCurrentDate(format: "yyyy년 MM월 dd일")
                    if (isReceivePush) {
                        Snackbar().show(message: "[EV Infra] " + currDate + "마케팅 수신 동의 처리가 완료되었어요! ☺️ 더 좋은 소식 준비할게요!")
                    } else {
                        Snackbar().show(message: "[EV Infra] " + currDate + "마케팅 수신 거부 처리가 완료되었어요. ")
                    }
                }
            }
        }
    }
    
    private func changeAllNotifications(isRecieve: Bool) {
        guard isRecieve else {
            alarmSwitch.setOn(false, animated: false)
            return
        }
        alarmSwitch.setOn(true, animated: false)
    }
    
    private func changeLocalNotifications(isRecieve: Bool) {
        guard isRecieve else {
            alarmLocalSwitch.setOn(false, animated: false)
            return
        }
        alarmLocalSwitch.setOn(true, animated: false)
    }
    
    private func changeMarketingNotifications(isRecieve: Bool) {
        guard isRecieve else {
            alarmMarketingSwitch.setOn(false, animated: false)
            return
        }
        alarmMarketingSwitch.setOn(true, animated: false)
    }
}

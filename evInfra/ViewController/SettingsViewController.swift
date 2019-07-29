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

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var alarmAllImg: UIImageView!
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var clusteringSwitch: UISwitch!
    
    let defaults = UserDefault()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareClusteringSettings()
        prepareSwitchs()
    }

    func prepareActionBar() {
        var backButton: IconButton!
        backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "전체 설정"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareClusteringSettings() {
        clusteringSwitch.isOn = defaults.readBool(key: UserDefault.Key.SETTINGS_CLUSTER)
    }
    
    func prepareSwitchs() {
        alarmSwitch.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        clusteringSwitch.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        changeAllNotifications(isRecieve: defaults.readBool(key: UserDefault.Key.SETTINGS_ALLOW_NOTIFICATION))
    }
    
    @IBAction func onChangeAlarmSwitch(_ sender: Any) {
        alarmSwitchChanged(state: alarmSwitch.isOn)
    }
    
    @IBAction func onChangeClusteringSwitch(_ sender: UISwitch) {
        defaults.saveBool(key: UserDefault.Key.SETTINGS_CLUSTER, value: sender.isOn)
    }
    
    @objc fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }

    func alarmSwitchChanged(state: Bool) {
        Server.updateNotificationState(state: state) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let isCommit = json["code"].stringValue
                if isCommit.elementsEqual("1000") {
                    let isReceivePush = json["receive"].boolValue
                    self.defaults.saveBool(key: UserDefault.Key.SETTINGS_ALLOW_NOTIFICATION, value: isReceivePush)
                    self.changeAllNotifications(isRecieve: isReceivePush)
                }
            }
        }
    }
    
    func changeAllNotifications(isRecieve: Bool) {
        if isRecieve {
            alarmSwitch.setOn(true, animated: false)
            alarmAllImg.image = UIImage(named: "ic_notifications_active")
        } else {
            alarmSwitch.setOn(false, animated: false)
            alarmAllImg.image = UIImage(named: "ic_notifications_off")
        }
    }
}

//
//  ABTestManager.swift
//  evInfra
//
//  Created by youjin kim on 2022/11/04.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig
import FirebaseInstallations
import SwiftyJSON

internal final class ABTestManager {
    static let shared = ABTestManager()
    
    let remoteConfig = RemoteConfig.remoteConfig()
    let setting = RemoteConfigSettings()
    
    enum TestType: String {
        case a = "A"
        case b = "B"
        case c = "C"
    }
    
    enum ConditionType: String {
        case mainBottomEVPay = "tooltip_msg_evpay"
    }
    
    private init() {
        setting.minimumFetchInterval = 0
        
        remoteConfig.configSettings = setting
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
    }
    
    
    internal func reqData(_ type: ConditionType) -> (TestType, String)? {
        let remote = remoteConfig[type.rawValue]
        
        do {
            let json = try JSON(data:remote.dataValue, options: .fragmentsAllowed)
            let type = TestType(rawValue: json["type"].stringValue)! //json["title"]
            let message = json["title"].stringValue
            printLog("reqData config data : \(json), \(type), \(message)")
            
            return (type, message)
        } catch let error {
            printLog(out: "Error reqData parsing : \(error)")
            
            return nil
        }
        
    }

    internal func fetch() {
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: 0) { status, error in
            if let error = error {
                printLog(out: "Error fetching config: \(error)")
            }
            printLog(out: "Config fetch completed with status: \(status)")
            self.setAppearance()
            
        }
        
#if DEBUG
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(printInstallationsID),
                                               name: .InstallationIDDidChange,
                                               object: nil)
#endif
    }
    
    private func setAppearance() {
        RemoteConfig.remoteConfig().activate { activated, error in
            let configValue = RemoteConfig.remoteConfig()["hello"]
            printLog(out: "Config value: \(configValue.stringValue))")
            printLog(out: "Config activated: \(activated)")
        }
    }
    
    @objc private func printInstallationsID() {
#if DEBUG
        Installations.installations().authTokenForcingRefresh(true) { token, error in
            if let error = error {
                printLog(out: "Error fetching token: \(error)")
                return
            }
            guard let token = token else { return }
            printLog(out: "Installation auth token: \(token.authToken)")
        }
        Installations.installations().installationID { identifier, error in
            if let error = error {
                printLog(out: "Error fetching installations ID: \(error)")
            } else if let identifier = identifier {
                printLog(out: "Remote installations ID: \(identifier)")
            }
        }
#endif
    }
}

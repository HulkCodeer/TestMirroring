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

internal final class ABTestManager {
    static let shared = ABTestManager()
    
    let remoteConfig = RemoteConfig.remoteConfig()
    let setting = RemoteConfigSettings()
    
    enum TestType: String {
        case mainBottomEVPay = "tooltip_msg_evpay"
    }
    
    private init() {
        setting.minimumFetchInterval = 0
        
        remoteConfig.configSettings = setting
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
    }
    
    internal func reqMessage(_ type: TestType) -> String {
        let requestMessage = remoteConfig[type.rawValue].stringValue ?? String()
            
        return requestMessage.replacingOccurrences(of: "\\n", with: "\n")
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

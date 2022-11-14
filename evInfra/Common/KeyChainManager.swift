//
//  KeyChainManager.swift
//  evInfra
//
//  Created by 이신광 on 14/11/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import Foundation
import KeychainSwift

internal final class KeyChainManager {
    public static let KEY_DEVICE_UUID = "device_uuid"
    
    static func get(key:String) -> String? {
        return KeychainSwift().get(key)
    }
    
    static func set(value:String, forKey: String) {
        KeychainSwift().set(value, forKey: forKey)
    }
}

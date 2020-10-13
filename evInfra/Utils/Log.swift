//
//  Log.swift
//  evInfra
//
//  Created by Michael Lee on 2020/06/09.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation

class Log {
    
    public static var DEBUG = true
    public static var DEBUG_PREFIXG = "EVInfra"
    
    static func d(tag : String, msg : String) {
        if (DEBUG == false || StringUtils.isNullOrEmpty(msg)) {
            return
        } else {
            NSLog(DEBUG_PREFIXG + "[D]" + tag + " : %@" , msg)
            //print(, );
        }
    }
    
    static func i(tag : String, msg : String) {
        if (DEBUG == false || StringUtils.isNullOrEmpty(msg)) {
            return
        } else {
            NSLog(DEBUG_PREFIXG + "[I]" + tag + " : %@" , msg)
            //print("[I]" + tag + " : ", msg);
        }
    }
    
    static func w(tag : String, msg : String) {
        if (DEBUG == false || StringUtils.isNullOrEmpty(msg)) {
            return
        } else {
            NSLog(DEBUG_PREFIXG + "[W]" + tag + " : %@" , msg)
            //print("[W]" + tag + " : ", msg);
        }
    }
    
    static func v(tag : String, msg : String) {
        if (DEBUG == false || StringUtils.isNullOrEmpty(msg)) {
            return
        } else {
            NSLog(DEBUG_PREFIXG + "[V]" + tag + " : %@" , msg)
            //print("[W]" + tag + " : ", msg);
        }
    }
    
    static func e(tag : String, msg : String) {
        if (DEBUG == false || StringUtils.isNullOrEmpty(msg)) {
            return
        } else {
            NSLog(DEBUG_PREFIXG + "[E]" + tag + " : %@" , msg)
            //print("[E]" + tag + " : ", msg);
        }
    }
}

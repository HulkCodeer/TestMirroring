//
//  EVIcon.swift
//  evInfra
//
//  Created by bulacode on 2018. 2. 20..
//  Copyright © 2018년 soft-berry. All rights reserved.
//


import UIKit
import Material

public struct EVIcon {
    /// Get the icon by the file name.
    public static func icon(_ name: String) -> UIImage? {
        return UIImage(named: name)
    }
    
    /// EV Infra Icon
    public static var navigation_mode = EVIcon.icon("navigation_mode")
    
    
}


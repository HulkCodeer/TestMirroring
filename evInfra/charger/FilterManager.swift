//
//  FilterManager.swift
//  evInfra
//
//  Created by SH on 2021/08/13.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation

class FilterManager {
    
    static let sharedInstance = FilterManager()
    
    private var filter: ChargerFilter
    
    public init() {
        filter = ChargerFilter.init()
    }
}

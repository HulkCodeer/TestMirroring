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
    
    let defaults = UserDefault()
    
    public init() {
        filter = ChargerFilter.init()
        
        filter.isFree = defaults.readBool(key: UserDefault.Key.FILTER_FREE)
        filter.isPaid = defaults.readBool(key: UserDefault.Key.FILTER_PAID)
        
        filter.isPublic = defaults.readBool(key: UserDefault.Key.FILTER_PUBLIC)
        filter.isNonPublic = defaults.readBool(key: UserDefault.Key.FILTER_NONPUBLIC)
        
        filter.minSpeed = defaults.readInt(key: UserDefault.Key.FILTER_MIN_SPEED)
        filter.maxSpeed = defaults.readInt(key: UserDefault.Key.FILTER_MAX_SPEED)
        
        filter.dcDemo = defaults.readBool(key: UserDefault.Key.FILTER_DC_DEMO)
        filter.dcCombo = defaults.readBool(key: UserDefault.Key.FILTER_DC_COMBO)
        filter.ac3 = defaults.readBool(key: UserDefault.Key.FILTER_AC)
        filter.slow = defaults.readBool(key: UserDefault.Key.FILTER_SLOW)
        filter.superCharger = defaults.readBool(key: UserDefault.Key.FILTER_SUPER_CHARGER)
        filter.destination = defaults.readBool(key: UserDefault.Key.FILTER_DESTINATION)
        
        filter.isGeneralWay = defaults.readBool(key: UserDefault.Key.FILTER_GENERAL_WAY)
        filter.isHighwayUp = defaults.readBool(key: UserDefault.Key.FILTER_HIGHWAY_UP)
        filter.isHighwayDown = defaults.readBool(key: UserDefault.Key.FILTER_HIGHWAT_DOWN)
        
        let companyList = ChargerManager.sharedInstance.getCompanyInfoListAll()!
        for company in companyList {
            if let companyId = company.company_id {
                filter.companies.updateValue(company.is_visible, forKey: companyId)
            }
        }
    }
}

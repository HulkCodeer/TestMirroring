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
    
    public var filter: ChargerFilter
    
    let defaults = UserDefault()
    
    public init() {
        // set default value
        defaults.registerBool(key: UserDefault.Key.FILTER_FREE, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_PAID, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_PUBLIC, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_NONPUBLIC, val: false)
        defaults.registerInt(key: UserDefault.Key.FILTER_MIN_SPEED, val: 0)
        defaults.registerInt(key: UserDefault.Key.FILTER_MAX_SPEED, val: 350)
        defaults.registerBool(key: UserDefault.Key.FILTER_INDOOR, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_OUTDOOR, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_CANOPY, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_DC_DEMO, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_DC_COMBO, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_AC, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_SLOW, val: false)
        defaults.registerBool(key: UserDefault.Key.FILTER_SUPER_CHARGER, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_DESTINATION, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_GENERAL_WAY, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_HIGHWAY_UP, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_HIGHWAT_DOWN, val: true)
        
        // set filter value
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
        
        filter.isIndoor = defaults.readBool(key: UserDefault.Key.FILTER_INDOOR)
        filter.isOutdoor = defaults.readBool(key: UserDefault.Key.FILTER_OUTDOOR)
        filter.isCanopy = defaults.readBool(key: UserDefault.Key.FILTER_CANOPY)
        
        let companyList = ChargerManager.sharedInstance.getCompanyInfoListAll()!
        for company in companyList {
            if let companyId = company.company_id {
                filter.companies.updateValue(company.is_visible, forKey: companyId)
            }
        }
    }
    
    func savePriceFilter(free: Bool, paid:Bool) {
        if (filter.isFree != free){
            filter.isFree = free
            defaults.saveBool(key: UserDefault.Key.FILTER_FREE, value: free)
        }
        if (filter.isPaid != paid) {
            filter.isPaid = paid
            defaults.saveBool(key: UserDefault.Key.FILTER_PAID, value: paid)
        }
    }
    
    func savePlaceFilter(indoor: Bool, outdoor:Bool, canopy:Bool) {
        if (filter.isIndoor != indoor){
            filter.isIndoor = indoor
            defaults.saveBool(key: UserDefault.Key.FILTER_INDOOR, value: indoor)
        }
        if (filter.isOutdoor != outdoor) {
            filter.isOutdoor = outdoor
            defaults.saveBool(key: UserDefault.Key.FILTER_OUTDOOR, value: outdoor)
        }
        if (filter.isCanopy != canopy) {
            filter.isCanopy = canopy
            defaults.saveBool(key: UserDefault.Key.FILTER_CANOPY, value: canopy)
        }
    }
    
    func saveRoadFilter(general: Bool, highUp:Bool, highDown:Bool) {
        if (filter.isGeneralWay != general){
            filter.isGeneralWay = general
            defaults.saveBool(key: UserDefault.Key.FILTER_GENERAL_WAY, value: general)
        }
        if (filter.isHighwayUp != highUp) {
            filter.isHighwayUp = highUp
            defaults.saveBool(key: UserDefault.Key.FILTER_HIGHWAY_UP, value: highUp)
        }
        if (filter.isHighwayDown != highDown) {
            filter.isHighwayDown = highDown
            defaults.saveBool(key: UserDefault.Key.FILTER_HIGHWAT_DOWN, value: highDown)
        }
    }
    
    func saveAccessFilter(isPublic: Bool, nonPublic:Bool) {
        if (filter.isPublic != isPublic){
            filter.isPublic = isPublic
            defaults.saveBool(key: UserDefault.Key.FILTER_PUBLIC, value: isPublic)
        }
        if (filter.isNonPublic != nonPublic) {
            filter.isNonPublic = nonPublic
            defaults.saveBool(key: UserDefault.Key.FILTER_NONPUBLIC, value: nonPublic)
        }
    }
    
    func saveSpeedFilter(min: Int, max: Int) {
        if (filter.minSpeed != min){
            filter.minSpeed = min
            defaults.saveInt(key: UserDefault.Key.FILTER_MIN_SPEED, value: min)
        }
        if (filter.maxSpeed != max) {
            filter.maxSpeed = max
            defaults.saveInt(key: UserDefault.Key.FILTER_MAX_SPEED, value: max)
        }
    }
    
    func saveTypeFilter(index: Int, val: Bool){
        print("save type index: \(index)")
        switch index {
        case 0:
            defaults.saveBool(key: UserDefault.Key.FILTER_DC_COMBO, value: val)
            filter.dcCombo = val
        case 1:
            defaults.saveBool(key: UserDefault.Key.FILTER_DC_DEMO, value: val)
            filter.dcDemo = val
        case 2:
            defaults.saveBool(key: UserDefault.Key.FILTER_AC, value: val)
            filter.ac3 = val
        case 3:
            defaults.saveBool(key: UserDefault.Key.FILTER_SLOW, value: val)
            filter.slow = val
            
            print("save slow with value : \(val)")
        case 4:
            defaults.saveBool(key: UserDefault.Key.FILTER_SUPER_CHARGER, value: val)
            filter.superCharger = val
        case 5:
            defaults.saveBool(key: UserDefault.Key.FILTER_DESTINATION, value: val)
            filter.destination = val
        default:
            break
        }
    }
}

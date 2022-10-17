//
//  FilterManager.swift
//  evInfra
//
//  Created by SH on 2021/08/13.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation

internal final class FilterManager {
    
    static let sharedInstance = FilterManager()
    
    internal var filter: ChargerFilter
    
    private let defaults = UserDefault()
    
    public init() {
        // set default value
        defaults.registerBool(key: UserDefault.Key.FILTER_FREE, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_PAID, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_PUBLIC, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_NONPUBLIC, val: true)
        defaults.registerInt(key: UserDefault.Key.FILTER_MIN_SPEED, val: 50)
        defaults.registerInt(key: UserDefault.Key.FILTER_MAX_SPEED, val: 350)
        defaults.registerBool(key: UserDefault.Key.FILTER_INDOOR, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_OUTDOOR, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_CANOPY, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_GENERAL_WAY, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_HIGHWAY_UP, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_HIGHWAT_DOWN, val: true)
        defaults.registerBool(key: UserDefault.Key.FILTER_MEMBERSHIP_CARD, val: false)
        
        // set filter value
        filter = ChargerFilter.init()
        
        filter.isFree = defaults.readBool(key: UserDefault.Key.FILTER_FREE)
        filter.isPaid = defaults.readBool(key: UserDefault.Key.FILTER_PAID)
        
        filter.isPublic = defaults.readBool(key: UserDefault.Key.FILTER_PUBLIC)
        filter.isNonPublic = defaults.readBool(key: UserDefault.Key.FILTER_NONPUBLIC)
        
        filter.minSpeed = defaults.readInt(key: UserDefault.Key.FILTER_MIN_SPEED)
        filter.maxSpeed = defaults.readInt(key: UserDefault.Key.FILTER_MAX_SPEED)
                        
        var defValue = defaults.readString(key: UserDefault.Key.FILTER_DC_DEMO)
        if defValue.isEmpty {
            filter.dcDemo = true
        } else {
            filter.dcDemo = defValue.equals("Checked")
        }
            
        defValue = defaults.readString(key: UserDefault.Key.FILTER_DC_COMBO)
        if defValue.isEmpty {
            filter.dcCombo = true
        } else {
            filter.dcCombo = defValue.equals("Checked")
        }
        
        defValue = defaults.readString(key: UserDefault.Key.FILTER_AC)
        if defValue.isEmpty {
            filter.ac3 = true
        } else {
            filter.ac3 = defValue.equals("Checked")
        }
        
        defValue = defaults.readString(key: UserDefault.Key.FILTER_SLOW)
        if defValue.isEmpty {
            filter.slow = false
        } else {
            filter.slow = defValue.equals("Checked")
        }
                
        defValue = defaults.readString(key: UserDefault.Key.FILTER_SUPER_CHARGER)
        if defValue.isEmpty {
            filter.superCharger = true
        } else {
            filter.superCharger = defValue.equals("Checked")
        }
        
        defValue = defaults.readString(key: UserDefault.Key.FILTER_DESTINATION)
        if defValue.isEmpty {
            filter.destination = false
        } else {
            filter.destination = defValue.equals("Checked")
        }
                                
        filter.isGeneralWay = defaults.readBool(key: UserDefault.Key.FILTER_GENERAL_WAY)
        filter.isHighwayUp = defaults.readBool(key: UserDefault.Key.FILTER_HIGHWAY_UP)
        filter.isHighwayDown = defaults.readBool(key: UserDefault.Key.FILTER_HIGHWAT_DOWN)
        
        filter.isIndoor = defaults.readBool(key: UserDefault.Key.FILTER_INDOOR)
        filter.isOutdoor = defaults.readBool(key: UserDefault.Key.FILTER_OUTDOOR)
        filter.isCanopy = defaults.readBool(key: UserDefault.Key.FILTER_CANOPY)
        
        filter.isMembershipCardChecked = defaults.readBool(key: UserDefault.Key.FILTER_MEMBERSHIP_CARD)
        
        let companyList = ChargerManager.sharedInstance.getCompanyInfoListAll()!
        
        if MemberManager.shared.isPartnershipClient(clientId: RentClientType.skr.rawValue) {
            for company in companyList {
                switch company.company_id {
                    case "0", "1", "3", "O", "D":
                        company.is_visible = true
                        break
                    default:
                        company.is_visible = false
                }
                if let companyId = company.company_id {
                    filter.companyDictionary[companyId] = company
                }
            }
        } else {
            for company in companyList {
                if let companyId = company.company_id {
                    filter.companyDictionary[companyId] = company
                }
            }
        }
    }
    
    internal func saveIsMembershipCardChecked(_ isChecked: Bool) {        
        filter.isMembershipCardChecked = isChecked
        defaults.saveBool(key: UserDefault.Key.FILTER_MEMBERSHIP_CARD, value: isChecked)                
    }
    
    internal func getIsMembershipCardChecked() -> Bool {
        return filter.isMembershipCardChecked
    }
    
    internal var groupList: Array<CompanyGroup>? {
        get {
            return defaults.getUserDefault(UserDefault.Key.FILTER_CHARGING_PROVIDER_LIST_SAVE) as? Array<CompanyGroup>
        }
        set {
            defaults.setUserDefault(UserDefault.Key.FILTER_CHARGING_PROVIDER_LIST_SAVE, value: newValue)
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
    
    func saveIndoor(with isSelect: Bool) {
        if filter.isIndoor != isSelect {
            filter.isIndoor = isSelect
            defaults.saveBool(key: UserDefault.Key.FILTER_INDOOR, value: isSelect)
        }
    }
    
    func saveOutdoor(with isSelect: Bool) {
        if filter.isOutdoor != isSelect {
            filter.isOutdoor = isSelect
            defaults.saveBool(key: UserDefault.Key.FILTER_OUTDOOR, value: isSelect)
        }
    }
    
    func saveCanopy(with isSelect: Bool) {
        if filter.isCanopy != isSelect {
            filter.isCanopy = isSelect
            defaults.saveBool(key: UserDefault.Key.FILTER_CANOPY, value: isSelect)
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
        switch index {
        case Const.CHARGER_TYPE_DCCOMBO:
            filter.dcCombo = val
            defaults.saveString(key: UserDefault.Key.FILTER_DC_COMBO, value: val ? "Checked" : "Unchecked")
        case Const.CHARGER_TYPE_DCDEMO:
            filter.dcDemo = val
            defaults.saveString(key: UserDefault.Key.FILTER_DC_DEMO, value: val ? "Checked" : "Unchecked")
        case Const.CHARGER_TYPE_AC:
            filter.ac3 = val
            defaults.saveString(key: UserDefault.Key.FILTER_AC, value: val ? "Checked" : "Unchecked")
        case Const.CHARGER_TYPE_SLOW:
            filter.slow = val
            defaults.saveString(key: UserDefault.Key.FILTER_SLOW, value: val ? "Checked" : "Unchecked")
        case Const.CHARGER_TYPE_SUPER_CHARGER:
            filter.superCharger = val
            defaults.saveString(key: UserDefault.Key.FILTER_SUPER_CHARGER, value: val ? "Checked" : "Unchecked")
        case Const.CHARGER_TYPE_DESTINATION:
            filter.destination = val
            defaults.saveString(key: UserDefault.Key.FILTER_DESTINATION, value: val ? "Checked" : "Unchecked")
        default:
            break
        }
    }
    
    func updateCompanyFilter() {
        let companyList = ChargerManager.sharedInstance.getCompanyInfoListAll()!
        for company in companyList {
            setCompany(companyId: company.company_id!, visible: company.is_visible)
        }
    }
    
    func setCompany(companyId: String, visible: Bool) {
        let companies = Array(filter.companyDictionary.values)
        for company in companies {
            if let id = company.company_id, companyId.equals(id) {
                company.is_visible = visible
                filter.companyDictionary[companyId] = company
            }
        }
    }
    
    func getPriceTitle() -> String {
        var title = ""
        // 둘다 설정 or 해제 시 기본 타이틀
        if ((filter.isPaid && filter.isFree) || !(filter.isPaid || filter.isFree)) {
            title = "유료/무료"
        } else {
            title = filter.isPaid ? "유료" : "무료"
        }
        return title
    }
    
    func getSpeedTitle() -> String {
        var title = ""
        if (filter.minSpeed == 0 && filter.maxSpeed == 350) {
            title = "충전속도"
        } else if (filter.minSpeed == filter.maxSpeed){
            if (filter.minSpeed == 0) {
                title = "완속~완속"
            } else {
                title = "\(filter.minSpeed)kW"
            }
        } else {
            if (filter.minSpeed == 0) {
                title = "완속 ~ \(filter.maxSpeed)kW"
            } else {
                title = "\(filter.minSpeed) ~ \(filter.maxSpeed)kW"
            }
        }
        return title
    }
    
    func getPlaceTitle() -> String {
        var title = ""
        if ((filter.isIndoor && filter.isOutdoor && filter.isCanopy)
                || !(filter.isIndoor || filter.isOutdoor || filter.isCanopy)){
            title = "설치형태"
        } else {
            if (filter.isIndoor) {
                title = "실내"
            }
            if (filter.isOutdoor) {
                title += title.isEmpty ? "실외" : ", 실외"
            }
            if (filter.isCanopy) {
                title += title.isEmpty ? "캐노피" : ", 캐노피"
            }
        }
        return title
    }
    
    internal func getPlaceChanged() -> Bool {
        guard (filter.isIndoor || filter.isOutdoor || filter.isCanopy) else { return false }
        return true
    }
    
    func getRoadTitle() -> String {
        var title = ""
        if ((filter.isGeneralWay && filter.isHighwayUp && filter.isHighwayDown)
                || !(filter.isGeneralWay || filter.isHighwayUp || filter.isHighwayDown)){
            title = "도로"
        } else {
            if (filter.isGeneralWay) {
                title = "일반도로"
            }
            if (filter.isHighwayUp) {
                title += title.isEmpty ? "고속도로(상)" : ", 고속도로(상)"
            }
            if (filter.isHighwayDown) {
                title += title.isEmpty ? "고속도로(하)" : ", 고속도로(하)"
            }
        }
        return title
    }
    
    func getTypeTitle() -> String {
        var title = ""
        if !filter.dcCombo, !filter.dcDemo, !filter.ac3, !filter.slow, !filter.superCharger, !filter.destination {
            title = "충전기타입"
        } else {
            if (filter.dcCombo) {
                title = "DC콤보"
            }
            if (filter.dcDemo) {
                title += title.isEmpty ? "DC차데모" : ", DC차데모"
            }
            if (filter.ac3) {
                title += title.isEmpty ? "AC 3상" : ", AC 3상"
            }
            if (filter.slow) {
                title += title.isEmpty ? "완속" : ", 완속"
            }
            if (filter.superCharger) {
                title += title.isEmpty ? "슈퍼차저" : ", 슈퍼차저"
            }
            if (filter.destination) {
                title += title.isEmpty ? "데스티네이션" : ", 데스티네이션"
            }
        }
        return title
    }
    
    func saveTypeFilterForCarType() {
        let carType = UserDefault().readInt(key: UserDefault.Key.MB_CAR_TYPE);
        if carType != 8 {
            
            filter.dcDemo = false
            filter.dcCombo = false
            filter.ac3 = false
            filter.slow = false
            filter.superCharger = false
            filter.destination = false
            
            switch(carType) {
            case Const.CHARGER_TYPE_DCDEMO:
                filter.dcDemo = true

            case Const.CHARGER_TYPE_DCCOMBO:
                filter.dcCombo = true

            case Const.CHARGER_TYPE_AC:
                filter.ac3 = true

            case Const.CHARGER_TYPE_SUPER_CHARGER:
                filter.superCharger = true

            case Const.CHARGER_TYPE_SLOW:
                filter.slow = true
                
            case Const.CHARGER_TYPE_DESTINATION:
                filter.destination = true

            default:
                filter.dcDemo = true
                break
            }
        }
        defaults.saveString(key: UserDefault.Key.FILTER_DC_COMBO, value: filter.dcCombo ? "Checked" : "Unchecked")
        defaults.saveString(key: UserDefault.Key.FILTER_DC_DEMO, value: filter.dcDemo ? "Checked" : "Unchecked")
        defaults.saveString(key: UserDefault.Key.FILTER_AC, value: filter.ac3 ? "Checked" : "Unchecked")
        defaults.saveString(key: UserDefault.Key.FILTER_SLOW, value: filter.slow ? "Checked" : "Unchecked")
        defaults.saveString(key: UserDefault.Key.FILTER_SUPER_CHARGER, value: filter.superCharger ? "Checked" : "Unchecked")
        defaults.saveString(key: UserDefault.Key.FILTER_DESTINATION, value: filter.destination ? "Checked" : "Unchecked")
    }
    
    internal func getSocketType() -> [String] {
        let types = getTypeTitle().split(separator: ",").map { String($0) }
        return types
    }
    
    internal func getAccessibility() -> [String] {
        var accesType: [String] = [String]()
        if filter.isPublic {
            accesType.append("개방")
        }
        if filter.isNonPublic {
            accesType.append("비개방")
        }
        return accesType
    }
    
    internal func getSelectedMyCar() {
        
    }
    
    internal func getChargingSpeed() -> (Int, Int) {
        return (filter.minSpeed, filter.maxSpeed)
    }
    
    internal func getLocationType() -> [String] {
        return getPlaceTitle().split(separator: ",").map { String($0) }
    }
    
    internal func getRoadType() -> [String] {
        return getRoadTitle().split(separator: ",").map { String($0) }
    }
    
    internal func getIsPaid() -> [String] {
        var types: [String] = [String]()
        if filter.isPaid {
            types.append("유료")
        }
        if filter.isFree {
            types.append("무료")
        }
        return types
    }
    
    internal func getChargingStations() -> [String] {
        return filter.companyDictionary.values.filter({ return $0.is_visible }).map { $0.name ?? "" }
    }
}

extension FilterManager {
    internal func logEventWithFilter(_ source: String) {
        let property: [String: Any] = ["selectedAccessibility": getAccessibility(),
                                       "selectedSocketType": getSocketType(),
                                       "filterMyCar": UserDefault().readBool(key: UserDefault.Key.FILTER_MYCAR),
                                       "minChargingSpeed": getChargingSpeed().0 == 0 ? "완속" : getChargingSpeed().0,
                                       "maxChargingSpeed": getChargingSpeed().1 == 0 ? "완속" : getChargingSpeed().1,
                                       "setLocation": getLocationType(),
                                       "road": getRoadType(),
                                       "price": getIsPaid(),
                                       "chargingStation": getChargingStations(),
                                       "source": source]
        
       FilterEvent.clickFilterSave.logEvent(property: property)
    }
}

//
//  ChargerFilter.swift
//  evInfra
//
//  Created by Shin Park on 2018. 3. 19..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation

protocol DelegateFilterChange: AnyObject {
    func onChangedFilter(type: FilterType)
}

protocol NewDelegateFilterChange: AnyObject {
    func changedFilter()
}

class ChargerFilter {
    var isFree = true
    var isPaid = true
    
    var isPublic = true
    var isNonPublic = false
    
    var minSpeed = 0
    var maxSpeed = 350
    
    var isIndoor = true
    var isOutdoor = true
    var isCanopy = true
    
    var isGeneralWay = true
    var isHighwayUp = true
    var isHighwayDown = true
    
    var dcDemo = true
    var dcCombo = true
    var ac3 = true
    var superCharger = true
    var slow = true
    var destination = true
    
    var isMembershipCardChecked = true
    var isFavoriteChecked = true
    var isRepresentCarChecked = false
    
    var companyDictionary: [String: CompanyInfoDto] = [:]
    
    func copy() -> ChargerFilter {
        let filter = ChargerFilter()
        filter.isFree = self.isFree
        filter.isPaid = self.isPaid
        filter.isPublic = self.isPublic
        filter.isNonPublic = self.isNonPublic
        filter.minSpeed = self.minSpeed
        filter.maxSpeed = self.maxSpeed
        filter.isIndoor = self.isIndoor
        filter.isOutdoor = self.isOutdoor
        filter.isCanopy = self.isCanopy
        filter.isGeneralWay = self.isGeneralWay
        filter.isHighwayUp = self.isHighwayUp
        filter.isHighwayDown = self.isHighwayDown
        filter.dcDemo = self.dcDemo
        filter.dcCombo = self.dcCombo
        filter.ac3 = self.ac3
        filter.superCharger = self.superCharger
        filter.slow = self.slow
        filter.destination = self.destination
        filter.companyDictionary = self.companyDictionary
        return filter
    }
    
    func getCompanySelected(companyId: String) -> Bool {
        return companyDictionary[companyId]?.is_visible ?? false
    }
    
    func isSame(filter : ChargerFilter?) -> Bool{
        guard let ft = filter else{
            return false
        }

        if self.isPublic != ft.isPublic{
            return false
        }
        if self.isNonPublic != ft.isNonPublic{
            return false
        }
        
        if self.minSpeed != ft.minSpeed{
            return false
        }
        if self.maxSpeed != ft.maxSpeed{
            return false
        }
        
        if self.isIndoor != ft.isIndoor{
            return false
        }
        if self.isOutdoor != ft.isOutdoor{
            return false
        }
        if self.isCanopy != ft.isCanopy{
            return false
        }
        
        if self.isGeneralWay != ft.isGeneralWay{
            return false
        }
        if self.isHighwayUp != ft.isHighwayUp{
            return false
        }
        if self.isHighwayDown != ft.isHighwayDown{
            return false
        }
        
        if self.isFree != ft.isFree{
            return false
        }
        if self.isPaid != ft.isPaid{
            return false
        }
        
        if self.dcDemo != ft.dcDemo{
            return false
        }
        if self.dcCombo != ft.dcCombo{
            return false
        }
        if self.ac3 != ft.ac3{
            return false
        }
        if self.superCharger != ft.superCharger{
            return false
        }
        if self.slow != ft.slow{
            return false
        }
        if self.destination != ft.destination{
            return false
        }
        
        return true
    }
}

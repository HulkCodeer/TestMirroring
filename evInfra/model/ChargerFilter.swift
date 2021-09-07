//
//  ChargerFilter.swift
//  evInfra
//
//  Created by Shin Park on 2018. 3. 19..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation

protocol DelegateFilterChange {
    func onChangedFilter(type: FilterType)
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
    
    var companies: [String: Bool] = [:]
    
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
        filter.companies = self.companies
        return filter
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
        
        for (key, _) in self.companies{
            if self.companies[key] != ft.companies[key]{
                return false
            }
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

extension ChargerFilter{
    //필터 저장을 하기 위한 루틴... 어레이 순서 바꾸어 주려면 여기서 하세요...
    //어레이 반환은 딕셔너리 값을 반환할 것임...
    public static let WAY_ALL = 0
    public static let WAY_HIGH = 1
    public static let WAY_NORMAL = 2
    public static let WAY_HIGH_UP = 5
    public static let WAY_HIGH_DOWN = 6
    
    public static let PAY_ALL = 0
    public static let PAY_YOU = 1
    public static let PAY_MOO = 2
    public static let PAY_FAST = 3
    
    //필터 추가시 여기 딕셔너리에다가 숫자랑 스트링 저장하세요.
    public static let WAY_FILTER_DIC:[Int: String] = [ChargerFilter.WAY_ALL: "전체도로", ChargerFilter.WAY_HIGH: "고속도로", ChargerFilter.WAY_NORMAL: "일반도로", ChargerFilter.WAY_HIGH_UP: "고속도로(상)", ChargerFilter.WAY_HIGH_DOWN: "고속도로(하)"]
    
    public static let PAY_FILTER_DIC:[Int: String] = [ChargerFilter.PAY_ALL: "모든 충전소", ChargerFilter.PAY_YOU: "유료 충전소", ChargerFilter.PAY_MOO: "무료 충전소", ChargerFilter.PAY_FAST: "초급속 충전소"]
    
    public func getWayFiltersName() -> Array<String>{
        var wayFilterNames = Array<String>();
        for index in self.getWayFiltersId(){
            wayFilterNames.append(ChargerFilter.WAY_FILTER_DIC[index]!)
        }
        return wayFilterNames
        
    }
    
    public func getWayFiltersId() -> Array<Int>{
        var wayFilterIds = Array<Int>();
        // 박신팀장님 요청사항인 부분 : 뺄 필터 빼고 추가할 필터를 여기서 편집합니다. 딕셔너리의 키값을 저장함으로 어떤게 빠지더라도 상관 없음.. 페이랑 웨이 모두 같습니다..
        wayFilterIds.append(ChargerFilter.WAY_ALL)
        wayFilterIds.append(ChargerFilter.WAY_NORMAL)
        wayFilterIds.append(ChargerFilter.WAY_HIGH)
        wayFilterIds.append(ChargerFilter.WAY_HIGH_UP)
        wayFilterIds.append(ChargerFilter.WAY_HIGH_DOWN)
        return wayFilterIds
    }
    
    public func getPayFiltersName()  -> Array<String> {
        var payFilterNames = Array<String>();
        for index in self.getPayFiltersId(){
            payFilterNames.append(ChargerFilter.PAY_FILTER_DIC[index]!)
        }
        return payFilterNames
    }
    
    public func getPayFiltersId() -> Array<Int> {
        var payFilterIds = Array<Int>();
        payFilterIds.append(ChargerFilter.PAY_ALL)
        payFilterIds.append(ChargerFilter.PAY_YOU)
        payFilterIds.append(ChargerFilter.PAY_MOO)
        payFilterIds.append(ChargerFilter.PAY_FAST)
        return payFilterIds
    }
}

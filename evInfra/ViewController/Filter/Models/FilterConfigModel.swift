//
//  FilterConfigModel.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/11/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

protocol Filter: Equatable {
    typealias Property = (image: UIImage?, imgUnSelectColor: UIColor, imgSelectColor: UIColor)
    var isSelected: Bool { get set }
    var typeTilte: String { get }
    var typeImageProperty: Property { get }
    var displayImageColor: UIColor { get }
    init(isSelected: Bool)
}

extension Filter {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.isSelected == rhs.isSelected
    }
    
    func isEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}

//enum DetailFilterType {
//    case Road(model: String, isSeleted: Bool)
//    case road(model: String, isSeleted: Bool)
//    case installType(model: String, isSeleted: Bool)
//    case chargerType(model: String, isSeleted: Bool)
//}

internal final class FilterConfigModel {
    var accessibilityFilters: [any Filter] = []
    var roadFilters: [any Filter] = []
    var placeFilters: [any Filter] = []
    
    var minSpeed: Int = 50
    var maxSpeed: Int = 350
    var isEvPayFilter: Bool = false
    var isFavoriteFilter: Bool = false
    var numberOfFavorites: Int = 0
    var isRepresentCarFilter: Bool = false
    var chargerTypes: [NewTag] = []
    
    convenience init(isConvert: Bool) {
        self.init()
        
        let accessbilityFactory = AccessibilityFilterFactory()
        accessibilityFilters.append(accessbilityFactory.createAccessibilityFilter(isSelected: FilterManager.sharedInstance.filter.isPublic, type: .publicType))
        accessibilityFilters.append(accessbilityFactory.createAccessibilityFilter(isSelected: FilterManager.sharedInstance.filter.isNonPublic, type: .nonPublicType))
                
        let roadFactory = RoadFilterFactory()
        roadFilters.append(roadFactory.createRoadFilter(isSelected: FilterManager.sharedInstance.filter.isGeneralWay, type: .general))
        roadFilters.append(roadFactory.createRoadFilter(isSelected: FilterManager.sharedInstance.filter.isHighwayUp, type: .highwayUp))
        roadFilters.append(roadFactory.createRoadFilter(isSelected: FilterManager.sharedInstance.filter.isHighwayDown, type: .highwayDown))
        
        let placeFactory = PlaceFilterFactory()
        placeFilters.append(placeFactory.createPlaceFilter(isSelected: FilterManager.sharedInstance.filter.isIndoor, type: .indoor))
        placeFilters.append(placeFactory.createPlaceFilter(isSelected: FilterManager.sharedInstance.filter.isOutdoor, type: .outdoor))
        placeFilters.append(placeFactory.createPlaceFilter(isSelected: FilterManager.sharedInstance.filter.isCanopy, type: .canopy))
        
        minSpeed = FilterManager.sharedInstance.filter.minSpeed
        maxSpeed = FilterManager.sharedInstance.filter.maxSpeed
        isEvPayFilter = FilterManager.sharedInstance.isMembershipCardChecked()
        isFavoriteFilter = FilterManager.sharedInstance.filter.isFavoriteChecked
        numberOfFavorites = ChargerManager.sharedInstance.getChargerStationInfoList().filter { $0.mFavorite }.count
        isRepresentCarFilter = FilterManager.sharedInstance.filter.isRepresentCarChecked
        chargerTypes = ChargerType.allCases.compactMap {
            if $0.uniqueKey == Const.CHARGER_TYPE_DCCOMBO || $0.uniqueKey == Const.CHARGER_TYPE_DCDEMO || $0.uniqueKey == Const.CHARGER_TYPE_AC || $0.uniqueKey == Const.CHARGER_TYPE_SUPER_CHARGER {
                return NewTag(title: $0.typeTitle, selected: true, uniqueKey: $0.uniqueKey, image: $0.typeImageProperty?.image)
            } else {
                return NewTag(title: $0.typeTitle, selected: false, uniqueKey: $0.uniqueKey, image: $0.typeImageProperty?.image)
            }
        }
    }
    
    init() {}
    
    internal func convertToData() -> FilterConfigModel {
        let accessbilityFactory = AccessibilityFilterFactory()
        accessibilityFilters.append(accessbilityFactory.createAccessibilityFilter(isSelected: FilterManager.sharedInstance.filter.isPublic, type: .publicType))
        accessibilityFilters.append(accessbilityFactory.createAccessibilityFilter(isSelected: FilterManager.sharedInstance.filter.isNonPublic, type: .nonPublicType))
                
        let roadFactory = RoadFilterFactory()
        roadFilters.append(roadFactory.createRoadFilter(isSelected: FilterManager.sharedInstance.filter.isGeneralWay, type: .general))
        roadFilters.append(roadFactory.createRoadFilter(isSelected: FilterManager.sharedInstance.filter.isHighwayUp, type: .highwayUp))
        roadFilters.append(roadFactory.createRoadFilter(isSelected: FilterManager.sharedInstance.filter.isHighwayDown, type: .highwayDown))
        
        let placeFactory = PlaceFilterFactory()
        placeFilters.append(placeFactory.createPlaceFilter(isSelected: FilterManager.sharedInstance.filter.isIndoor, type: .indoor))
        placeFilters.append(placeFactory.createPlaceFilter(isSelected: FilterManager.sharedInstance.filter.isOutdoor, type: .outdoor))
        placeFilters.append(placeFactory.createPlaceFilter(isSelected: FilterManager.sharedInstance.filter.isCanopy, type: .canopy))
        
        return self
    }
    
    internal func resetFilter() {
        accessibilityFilters.removeAll(keepingCapacity: true)
        roadFilters.removeAll(keepingCapacity: true)
        placeFilters.removeAll(keepingCapacity: true)
        
        let accessbilityFactory = AccessibilityFilterFactory()
        accessibilityFilters.append(accessbilityFactory.createAccessibilityFilter(isSelected: true, type: .publicType))
        accessibilityFilters.append(accessbilityFactory.createAccessibilityFilter(isSelected: true, type: .nonPublicType))
                
        let roadFactory = RoadFilterFactory()
        roadFilters.append(roadFactory.createRoadFilter(isSelected: true, type: .general))
        roadFilters.append(roadFactory.createRoadFilter(isSelected: true, type: .highwayUp))
        roadFilters.append(roadFactory.createRoadFilter(isSelected: true, type: .highwayDown))
        
        let placeFactory = PlaceFilterFactory()
        placeFilters.append(placeFactory.createPlaceFilter(isSelected: true, type: .indoor))
        placeFilters.append(placeFactory.createPlaceFilter(isSelected: true, type: .outdoor))
        placeFilters.append(placeFactory.createPlaceFilter(isSelected: true, type: .canopy))
        
        self.minSpeed = 50
        self.maxSpeed = 350
        self.isEvPayFilter = false
        self.isFavoriteFilter = false
        self.isRepresentCarFilter = false
        
        self.chargerTypes = ChargerType.allCases.compactMap {
            if $0.uniqueKey == Const.CHARGER_TYPE_DCCOMBO || $0.uniqueKey == Const.CHARGER_TYPE_DCDEMO || $0.uniqueKey == Const.CHARGER_TYPE_AC || $0.uniqueKey == Const.CHARGER_TYPE_SUPER_CHARGER {
                return NewTag(title: $0.typeTitle, selected: true, uniqueKey: $0.uniqueKey, image: $0.typeImageProperty?.image)
            } else {
                return NewTag(title: $0.typeTitle, selected: false, uniqueKey: $0.uniqueKey, image: $0.typeImageProperty?.image)
            }
        }
    }
}

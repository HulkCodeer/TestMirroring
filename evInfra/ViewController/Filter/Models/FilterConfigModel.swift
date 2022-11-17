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
    static func == (lhs: any Filter, rhs: any Filter) -> Bool {
        lhs.isSelected == rhs.isSelected &&
        lhs.typeTilte == rhs.typeTilte
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

internal final class FilterConfigModel: Equatable {
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
    var isSlowTypeOn: Bool = false
    
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
        
        let myCarType: Int = UserDefault().readInt(key: UserDefault.Key.MB_CAR_TYPE)
        let hasMyCar: Bool = UserDefault().readInt(key: UserDefault.Key.MB_CAR_ID) != 0
        let isRepresentCarFilter = self.isRepresentCarFilter
        let isSlowTypeOn: Bool = self.isSlowTypeOn
        
        if isRepresentCarFilter {
            if hasMyCar {
                for type in ChargerType.allCases {
                    chargerTypes.append(NewTag(title: type.typeTitle, selected: myCarType == type.uniqueKey, uniqueKey: type.uniqueKey, image: type.typeImageProperty?.image))
                }
            } else {
                for type in ChargerType.allCases {
                    chargerTypes.append(NewTag(title: type.typeTitle, selected: type.selected, uniqueKey: type.uniqueKey, image: type.typeImageProperty?.image))
                }
            }
        } else {
            if isSlowTypeOn {
                for type in ChargerType.allCases {
                    if type == .slow || type == .destination {
                        chargerTypes.append(NewTag(title: type.typeTitle, selected: true, uniqueKey: type.uniqueKey, image: type.typeImageProperty?.image))
                    } else {
                        chargerTypes.append(NewTag(title: type.typeTitle, selected: type.selected, uniqueKey: type.uniqueKey, image: type.typeImageProperty?.image))
                    }
                }
            } else {
                for type in ChargerType.allCases {
                    chargerTypes.append(NewTag(title: type.typeTitle, selected: type.selected, uniqueKey: type.uniqueKey, image: type.typeImageProperty?.image))
                }
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
    
    static func == (lhs: FilterConfigModel, rhs: FilterConfigModel) -> Bool {
        var isEqualAccess = true
        
        for (index, filter) in lhs.accessibilityFilters.enumerated() {
            if filter.isSelected != rhs.accessibilityFilters[index].isSelected {
                isEqualAccess = false
                break
            }
        }
        
        var isEqualRoad = true
        
        for (index, filter) in lhs.roadFilters.enumerated() {
            if filter.isSelected != rhs.roadFilters[index].isSelected {
                isEqualRoad = false
                break
            }
        }
        
        var isEqualPlace = true
        
        for (index, filter) in lhs.placeFilters.enumerated() {
            if filter.isSelected != rhs.placeFilters[index].isSelected {
                isEqualPlace = false
                break
            }
        }
        
        printLog(out: "\(isEqualAccess)")
        printLog(out: "\(isEqualRoad)")
        printLog(out: "\(isEqualPlace)")
        printLog(out: "\(lhs.minSpeed == rhs.minSpeed)")
        printLog(out: "\(lhs.maxSpeed == rhs.maxSpeed)")
        printLog(out: "\(lhs.isEvPayFilter == rhs.isEvPayFilter)")
        printLog(out: "\(lhs.isFavoriteFilter == rhs.isFavoriteFilter)")
        printLog(out: "\(lhs.numberOfFavorites == rhs.numberOfFavorites)")
        printLog(out: "\(lhs.isRepresentCarFilter == rhs.isRepresentCarFilter)")
        printLog(out: "\(lhs.chargerTypes == rhs.chargerTypes)")
        
        return isEqualAccess &&
        isEqualRoad &&
        isEqualPlace &&
        lhs.minSpeed == rhs.minSpeed &&
        lhs.maxSpeed == rhs.maxSpeed &&
        lhs.isEvPayFilter == rhs.isEvPayFilter &&
        lhs.isFavoriteFilter == rhs.isFavoriteFilter &&
        lhs.numberOfFavorites == rhs.numberOfFavorites &&
        lhs.isRepresentCarFilter == rhs.isRepresentCarFilter &&
        lhs.chargerTypes == rhs.chargerTypes
    }
}

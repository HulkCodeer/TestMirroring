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
    
    required init() {
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
    }
}

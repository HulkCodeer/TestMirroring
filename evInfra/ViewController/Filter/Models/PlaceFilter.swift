//
//  PlaceFilter.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/11/17.
//  Copyright © 2022 soft-berry. All rights reserved.
//

internal class IndoorFilter: Filter {
    var isSelected: Bool
                    
    var typeImageProperty: Property {
        return (image: Icons.iconInside.image, imgUnSelectColor: Colors.contentTertiary.color, imgSelectColor: Colors.contentPositive.color)
    }
    
    var displayImageColor: UIColor {
        self.isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
    }
    
    var typeTilte: String {
        "실내"
    }
    
    required init(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    static func == (lhs: IndoorFilter, rhs: IndoorFilter) -> Bool {
        lhs.isSelected == rhs.isSelected &&
        lhs.typeTilte == rhs.typeTilte
    }
}

internal class OutdoorFilter: Filter {
    var isSelected: Bool
            
    var typeImageProperty: Property {
        return (image: Icons.iconOutside.image, imgUnSelectColor: Colors.contentTertiary.color, imgSelectColor: Colors.contentPositive.color)
    }
    
    var displayImageColor: UIColor {
        isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
    }
    
    var typeTilte: String {
        "실외"
    }
    
    required init(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    static func == (lhs: OutdoorFilter, rhs: OutdoorFilter) -> Bool {
        lhs.isSelected == rhs.isSelected &&
        lhs.typeTilte == rhs.typeTilte
    }
}

internal class CanopyFilter: Filter {
    var isSelected: Bool
            
    var typeImageProperty: Property {
        return (image: Icons.iconCanopy.image, imgUnSelectColor: Colors.contentTertiary.color, imgSelectColor: Colors.contentPositive.color)
    }
    
    var displayImageColor: UIColor {
        isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
    }
    
    var typeTilte: String {
        "캐노피"
    }
    
    required init(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    static func == (lhs: CanopyFilter, rhs: CanopyFilter) -> Bool {
        lhs.isSelected == rhs.isSelected &&
        lhs.typeTilte == rhs.typeTilte
    }
}

protocol PlaceFilterCreator {
    func createPlaceFilter(isSelected: Bool, type: PlaceType) -> any Filter
}

enum PlaceType: CaseIterable {
    case indoor
    case outdoor
    case canopy
}

class PlaceFilterFactory: PlaceFilterCreator {
    func createPlaceFilter(isSelected: Bool, type: PlaceType) -> any Filter {
        switch type {
        case .indoor:
            return IndoorFilter(isSelected: isSelected)
        case .outdoor:
            return OutdoorFilter(isSelected: isSelected)
        case .canopy:
            return CanopyFilter(isSelected: isSelected)
        }
    }
}

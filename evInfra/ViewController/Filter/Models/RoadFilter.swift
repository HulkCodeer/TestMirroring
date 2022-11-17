//
//  RoadFilter.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/11/17.
//  Copyright © 2022 soft-berry. All rights reserved.
//

internal class GeneralFilter: Filter {
    var isSelected: Bool
                    
    var typeImageProperty: Property {
        return (image: Icons.iconGeneralRoad.image, imgUnSelectColor: Colors.contentTertiary.color, imgSelectColor: Colors.contentPositive.color)
    }
    
    var displayImageColor: UIColor {
        self.isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
    }
    
    var typeTilte: String {
        "일반도로"
    }
    
    required init(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    static func == (lhs: GeneralFilter, rhs: GeneralFilter) -> Bool {
        lhs.isSelected == rhs.isSelected &&
        lhs.typeTilte == rhs.typeTilte
    }
}

internal class HighwayUpFilter: Filter {
    var isSelected: Bool
            
    var typeImageProperty: Property {
        return (image: Icons.iconHighwayTop.image, imgUnSelectColor: Colors.contentTertiary.color, imgSelectColor: Colors.contentPositive.color)
    }
    
    var displayImageColor: UIColor {
        isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
    }
    
    var typeTilte: String {
        "고속도로(상)"
    }
    
    required init(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    static func == (lhs: HighwayUpFilter, rhs: HighwayUpFilter) -> Bool {
        lhs.isSelected == rhs.isSelected &&
        lhs.typeTilte == rhs.typeTilte
    }
}

internal class HighwayDownFilter: Filter {
    var isSelected: Bool
            
    var typeImageProperty: Property {
        return (image: Icons.iconHighwayBottom.image, imgUnSelectColor: Colors.contentTertiary.color, imgSelectColor: Colors.contentPositive.color)
    }
    
    var displayImageColor: UIColor {
        isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
    }
    
    var typeTilte: String {
        "고속도로(하)"
    }
    
    required init(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    static func == (lhs: HighwayDownFilter, rhs: HighwayDownFilter) -> Bool {
        lhs.isSelected == rhs.isSelected &&
        lhs.typeTilte == rhs.typeTilte
    }
}

protocol RoadFilterCreator {
    func createRoadFilter(isSelected: Bool, type: RoadType) -> any Filter
}

enum RoadType: CaseIterable {
    case general
    case highwayUp
    case highwayDown
}

class RoadFilterFactory: RoadFilterCreator {
    func createRoadFilter(isSelected: Bool, type: RoadType) -> any Filter {
        switch type {
        case .general:
            return GeneralFilter(isSelected: isSelected)
        case .highwayUp:
            return HighwayUpFilter(isSelected: isSelected)
        case .highwayDown:
            return HighwayDownFilter(isSelected: isSelected)
        }
    }
}

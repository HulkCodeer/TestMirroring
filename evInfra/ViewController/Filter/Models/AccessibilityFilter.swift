//
//  File.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/11/17.
//  Copyright © 2022 soft-berry. All rights reserved.
//

internal class PublicFilter: Filter {
    var isSelected: Bool
                    
    var typeImageProperty: Property {
        return (image: Icons.iconAccessPublic.image, imgUnSelectColor: Colors.contentTertiary.color, imgSelectColor: Colors.contentPositive.color)
    }
    
    var displayImageColor: UIColor {
        self.isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
    }
    
    var typeTilte: String {
        "개방 충전소"
    }
    
    required init(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    static func == (lhs: PublicFilter, rhs: PublicFilter) -> Bool {
        lhs.isSelected == rhs.isSelected &&
        lhs.typeTilte == rhs.typeTilte
    }
}

internal class NonPublicFilter: Filter {
    var isSelected: Bool
            
    var typeImageProperty: Property {
        return (image: Icons.iconAccessNonpublic.image, imgUnSelectColor: Colors.contentTertiary.color, imgSelectColor: Colors.contentPositive.color)
    }
    
    var displayImageColor: UIColor {
        isSelected ? typeImageProperty.imgSelectColor : typeImageProperty.imgUnSelectColor
    }
    
    var typeTilte: String {
        "비개방 충전소"
    }
    
    required init(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    static func == (lhs: NonPublicFilter, rhs: NonPublicFilter) -> Bool {
        lhs.isSelected == rhs.isSelected &&
        lhs.typeTilte == rhs.typeTilte
    }
}

protocol AccessibilityFilterCreator {
    func createAccessibilityFilter(isSelected: Bool, type: AccessibilityType) -> any Filter
}

enum AccessibilityType: CaseIterable {
    case publicType
    case nonPublicType
}

class AccessibilityFilterFactory: AccessibilityFilterCreator {
    func createAccessibilityFilter(isSelected: Bool, type: AccessibilityType) -> any Filter {
        switch type {
        case .publicType:
            return PublicFilter(isSelected: isSelected)
        case .nonPublicType:
            return NonPublicFilter(isSelected: isSelected)
        }
    }
}

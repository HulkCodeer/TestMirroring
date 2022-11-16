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

class OpenFilter: Filter {
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
}

class CloseFilter: Filter {
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
}

protocol AccessibilityFilterCreator {
    func createAccessibilityFilter(isSelected: Bool, type: AccessibilityType) -> any Filter
}

enum AccessibilityType: CaseIterable {
    case openType
    case closeType
}

class AccessibilityFilterFactory: AccessibilityFilterCreator {
    func createAccessibilityFilter(isSelected: Bool, type: AccessibilityType) -> any Filter {
        switch type {
        case .openType:
            return OpenFilter(isSelected: isSelected)
        case .closeType:
            return CloseFilter(isSelected: isSelected)
        }
    }
}

enum DetailFilterType {
    case accessibility(model: String, isSeleted: Bool)
    case road(model: String, isSeleted: Bool)
    case installType(model: String, isSeleted: Bool)
    case chargerType(model: String, isSeleted: Bool)
}

internal final class FilterConfigModel {
    var accessibilityFilters: [any Filter] = []
    
    required init() {
        let factory = AccessibilityFilterFactory()
        accessibilityFilters.append(factory.createAccessibilityFilter(isSelected: true, type: .openType))
        accessibilityFilters.append(factory.createAccessibilityFilter(isSelected: true, type: .closeType))
    }
}

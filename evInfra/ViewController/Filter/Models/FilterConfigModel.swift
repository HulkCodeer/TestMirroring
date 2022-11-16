//
//  FilterConfigModel.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/11/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

protocol Filter: Equatable {
    var isSelected: Bool { get set }
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
    
    required init(isSelected: Bool) {
        self.isSelected = isSelected
    }
}

class CloseFilter: Filter {
    var isSelected: Bool
    
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
    var roadFilters: [any Filter] = []
    
    required init() {
        let factory = AccessibilityFilterFactory()
        roadFilters.append(factory.createAccessibilityFilter(isSelected: true, type: .openType))
        roadFilters.append(factory.createAccessibilityFilter(isSelected: true, type: .closeType))
    }
}

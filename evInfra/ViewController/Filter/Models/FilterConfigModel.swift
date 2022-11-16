//
//  FilterConfigModel.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/11/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

enum DetailFilterType {
    case accessibility
    case road
    case installType
    case chargerType
}

internal final class FilterConfigModel {
    var test: String
    var filterTypes: Set<String> = []
    
    required init(test: String) {
        self.test = test
    }
}

//
//  EvPoint.swift
//  evInfra
//
//  Created by Shin Park on 11/10/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

class EvPoint: Decodable {
    /// 0: none, 1: charging, 2: event, 3: reward
    var point: String?
    var action: String?
    var date: String?
    var desc: String?
    var type: Int?
}
// MARK: Point

extension EvPoint {
    
    func loadPointType() -> PointType {
        switch type {
        case 0:
            return .none
        case 1:
            return .charging
        case 2:
            return .event
        case 3:
            return .reward
        default:
            return .unknown
        }
    }
    
    enum PointType {
        case none        // default value
        case charging   // 충전
        case event      // event
        case reward    // 보상형 광고
        
        case unknown     // EvPoint type Optional 관련
        
        init(_ type: Int?) {
            switch type {
            case 0:
                self = .none
            case 1:
                self = .charging
            case 2:
                self = .event
            case 3:
                self = .reward
            default:
                self = .unknown
            }
        }
    }
}

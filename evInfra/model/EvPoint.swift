//
//  EvPoint.swift
//  evInfra
//
//  Created by Shin Park on 11/10/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

struct EvPoint: Decodable {
    let point: String?
    /// "save": 적립, "used": 사용, 그외 -> 기타.
    let pointType: String?
    let date: String?
    let desc: String?
    /// 0: none, 1: charging, 2: event, 3: reward
    let pointCategory: Int?
    
    private enum CodingKeys: String, CodingKey {
        case point, date, desc
        case pointType = "action"
        case pointCategory = "type"
    }
    
}

extension EvPoint {
    
    // MARK: Action
    
    func loadPointType() -> PointType {
        return PointType(self.pointType)
    }
    
    func loadPointCategoryType() -> PointCategoryType {
        return PointCategoryType(self.pointCategory)
    }
    
    // MARK: Object
    
    /// "save": 적립, "used": 사용
    enum PointType: CaseIterable {
        case all
        case savePoint
        case usePoint
        
        init(_ type: String?) {
            switch type {
            case "save":
                self = .savePoint
            case "used":
                self = .usePoint
            default:
                self = .all
            }
        }
        
        var value: String {
            switch self {
            case .all:
                return "전체"
            case .usePoint:
                return "사용"
            case .savePoint:
                return "저장"
            }
        }
    }
    
    enum PointCategoryType {
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

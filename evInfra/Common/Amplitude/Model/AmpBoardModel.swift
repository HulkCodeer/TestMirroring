//
//  AmpBoardModel.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/08/29.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

internal struct AmpBoardModel {
    var mid: String = ""
    var chargerId: String = ""
    var documentSrl: String = ""
    var isFromDetailView: Bool = false
    var source: String = ""
    
    private func getBoardType() -> String {
        let filteredType = Board.CommunityType.allCases.filter {
            $0.rawValue == self.mid
        }.first ?? .FREE
        
        switch filteredType {
        case .CHARGER: return "충전소 게시판"
        case .FREE: return "자유 게시판"
        case .NOTICE: return "EV Infra 공지"
        case .CORP_GS: return "GS칼텍스"
        case .CORP_JEV: return "제주전기차서비스"
        case .CORP_STC: return "에스트래픽"
        case .CORP_SBC: return "EV Infra"
        }
    }
    
    private func getStationName() -> String? {
        let filteredType = Board.CommunityType.allCases.filter {
            $0.rawValue == self.mid
        }.first ?? .FREE
        
        switch filteredType {
        case .CHARGER:
            guard !self.chargerId.isEmpty else { return nil }
            return ChargerManager
                .sharedInstance
                .getStationInfoById(id: self.chargerId)
                .map { $0.mSnm ?? "" }
        default: return nil
        }
    }
    
    private func isViewedFromChargerDetail() -> Bool? {
        let filteredType = Board.CommunityType.allCases.filter {
            $0.rawValue == self.mid
        }.first ?? .FREE
        
        switch filteredType {
        case .CHARGER:
            guard !self.chargerId.isEmpty else { return nil }
            return isFromDetailView
        default: return false
        }
    }
    
    internal var toProperty: [String: Any?] {
        [
            "boardType": getBoardType(),
            "sourceStation": isViewedFromChargerDetail(),
            "stationName": getStationName(),
            "postID": documentSrl
        ]
    }
}

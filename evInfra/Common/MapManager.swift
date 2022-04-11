//
//  MapManager.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/03/30.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import NMapsMap

class MapManager {
    private var mapView: NMFMapView?
//    private let clusterManager = ClusterManager()
    private let chargerManager = ChargerManager.sharedInstance
    // markers
    
    init(mapView: NMFMapView) {
        self.mapView = mapView
    }
    
    // drawMarker
    func drawMapMarker() {
        print("drawMapMarker")
        guard chargerManager.isReady() else { return }
        
        let stations = chargerManager.getChargerStationInfoList()
    }
}


//
//  NaverMapView.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/04/04.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import NMapsMap

class NaverMapView: NMFNaverMapView {
    private let locationManager = CLLocationManager()
    private let defaults = UserDefault()
    
    var zoomLevel: Double = 15 // default zoom level
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        let coordinate = locationManager.getCurrentCoordinate()
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let nmgLatLng = NMGLatLng(lat: latitude, lng: longitude)
        
        if defaults.readInt(key: UserDefault.Key.MAP_ZOOM_LEVEL) > 0 {
            zoomLevel = Double(defaults.readInt(key: UserDefault.Key.MAP_ZOOM_LEVEL))
        }
        
        let defaultPosition = NMFCameraPosition(nmgLatLng, zoom: zoomLevel, tilt: 0, heading: 0)
        mapView.moveCamera(NMFCameraUpdate(position: defaultPosition))
    }
}

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
    static let shared = MapManager()
    var naverMapView = NMFNaverMapView()
    var zoomLevel: Double = 15

    let locationManager = CLLocationManager()
    let defaults = UserDefault()
    
    init() {
        let coordinate = getCoordinate()
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let nmgLatLng = NMGLatLng(lat: latitude, lng: longitude)
        
        if defaults.readInt(key: UserDefault.Key.MAP_ZOOM_LEVEL) > 0 {
            zoomLevel = Double(defaults.readInt(key: UserDefault.Key.MAP_ZOOM_LEVEL))
        }
        
        let defaultPosition = NMFCameraPosition(nmgLatLng, zoom: zoomLevel, tilt: 0, heading: 0)
        naverMapView.mapView.moveCamera(NMFCameraUpdate(position: defaultPosition))
    }
    
    func getCoordinate() -> CLLocationCoordinate2D {
        guard let location = locationManager.location else { return CLLocationCoordinate2D(latitude: 0, longitude: 0) }
        return location.coordinate
    }
    
    public func moveToMyLocation() {
        let coordinate = getCoordinate()
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let nmgLatLng = NMGLatLng(lat: latitude, lng: longitude)
        let defaultPosition = NMFCameraPosition(nmgLatLng, zoom: zoomLevel, tilt: 0, heading: 0)
        naverMapView.mapView.moveCamera(NMFCameraUpdate(position: defaultPosition))
    }
    
    public func moveToCenter(with position: (Double, Double)) {
        let latitude = position.0
        let longitude = position.1
        
        let nmgLatLng = NMGLatLng(lat: latitude, lng: longitude)
        let defaultPosition = NMFCameraPosition(nmgLatLng, zoom: zoomLevel, tilt: 0, heading: 0)
        naverMapView.mapView.moveCamera(NMFCameraUpdate(position: defaultPosition))
    }
}


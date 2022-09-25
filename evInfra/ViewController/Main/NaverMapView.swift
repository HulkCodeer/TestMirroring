//
//  NaverMapView.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/04/04.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import NMapsMap
import CoreLocation

class NaverMapView: NMFNaverMapView {
    
    var clusterManager: ClusterManager?
    var startMarker: Marker?
    var endMarker: Marker?
    var midMarker: Marker?
    var searchMarker: Marker?
    var viaList: [POIObject] = []
    var start: POIObject?
    var destination: POIObject?
    var path: NMFPath?
    
    let locationManager = CLLocationManager()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        self.showCompass = false
        self.showZoomControls = true
        mapView.positionMode = .normal
        mapView.mapType = .basic
        mapView.extent = NMGLatLngBounds(southWestLat: 31.43, southWestLng: 122.37, northEastLat: 44.35, northEastLng: 132)
        mapView.logoAlign = .leftBottom
        mapView.logoMargin = UIEdgeInsets(top: 0, left: 0, bottom: 85, right: 0)
        mapView.logoInteractionEnabled = false
        mapView.minZoomLevel = 5
        mapView.maxZoomLevel = 18
    }
    
    func moveToCurrentPostiion() {
        self.moveToPosition(with: 14)
    }
    
    func moveToCenterPosition() {
        self.moveToPosition(with: 10)
    }
    
    func moveToPosition(with zoomLevel: Double) {
//        let coordinate = locationManager.getCurrentCoordinate()
//        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude), zoomTo: zoomLevel)
//        cameraUpdate.animation = .fly
//        mapView.moveCamera(cameraUpdate)
//        
//        let locationOverlay = mapView.locationOverlay
//        locationOverlay.location = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
//        locationOverlay.hidden = false
    }
    
    func moveToCamera(with poistion: NMGLatLng, zoomLevel: Double) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: poistion, zoomTo: zoomLevel)
        cameraUpdate.animation = .fly
        mapView.moveCamera(cameraUpdate)
    }
    
    func isInJeju() -> Bool {
        let currentCoordinate = NMGLatLng(from: locationManager.getCurrentCoordinate())
        // 제주 지역
        let southWestOfJeju = NMGLatLng(lat: 33.11, lng: 126.13)
        let northEastOfJeju = NMGLatLng(lat: 33.969, lng: 126.99)
        // 서울 지역
//        let southWestOfJeju = NMGLatLng(lat: 37.485765, lng: 127.014262)
//        let northEastOfJeju = NMGLatLng(lat: 37.504895, lng: 127.045919)
        
        let boundsOfJeju = NMGLatLngBounds(southWest: southWestOfJeju, northEast: northEastOfJeju)
        return boundsOfJeju.hasPoint(currentCoordinate)
    }
}

//
//  CLLocationCoordinate2D.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/04/07.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

extension CLLocationCoordinate2D {
    /// Returns distance from coordianate in meters.
    /// - Parameter from: coordinate which will be used as end point.
    /// - Returns: Returns distance in meters.
    func distance(to: CLLocationCoordinate2D) -> CLLocationDistance {
        let locationManager = CLLocationManager()
        guard let location = locationManager.location else { return -1.0 }
        
        let from = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
    
    func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {        
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
}

extension CLLocationManager {
    func getCurrentCoordinate() -> CLLocationCoordinate2D {
        guard let location = self.location else { return CLLocationCoordinate2D(latitude: 0, longitude: 0) }
        return location.coordinate
    }
}

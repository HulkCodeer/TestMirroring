//
//  Marker.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/04/07.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import NMapsMap

enum RoutePosition {
    case start
    case mid
    case end
    case search
}

class Marker: NMFMarker {
    private var routePosition: RoutePosition?
    private var overlayImage: NMFOverlayImage?
    
    convenience init(_ position: NMGLatLng, _ route: RoutePosition) {
        self.init()
        
        switch route {
        case .start:
            overlayImage = NMFOverlayImage(image: UIImage(named: "ic_route_start")!)
        case .mid:
            overlayImage = NMFOverlayImage(image: UIImage(named: "ic_route_add")!)
        case .end:
            overlayImage = NMFOverlayImage(image: UIImage(named: "ic_route_end")!)
        case .search:
            overlayImage = NMFOverlayImage(image: UIImage(named: "marker_search")!)
        }
        
        self.position = position
        self.iconImage = overlayImage!
        self.anchor = CGPoint(x: 0.5, y: 0.5)
        self.zIndex = 100
    }
}

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
    case none
}

class Marker: NMFMarker {
    private var routePosition: RoutePosition?
    private var overlayImage: NMFOverlayImage?
    
    convenience init(_ position: NMGLatLng, _ route: RoutePosition) {
        self.init()
        
        switch route {
        case .start:
            overlayImage = NMFOverlayImage(image: UIImage(named: "icon_start_marker")!)
        case .mid:
            overlayImage = NMFOverlayImage(image: UIImage(named: "icon_via_marker")!)
        case .end:
            overlayImage = NMFOverlayImage(image: UIImage(named: "icon_end_marker")!)
        case .search:
            overlayImage = NMFOverlayImage(image: UIImage(named: "marker_search")!)
        case .none:
            break
        }
        
        self.position = position
        self.iconImage = overlayImage!
        self.anchor = CGPoint(x: 0.5, y: 0.5)
        self.zIndex = 100
    }
}

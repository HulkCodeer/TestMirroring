//
//  Region.swift
//  evInfra
//
//  Created by Shin Park on 2018. 3. 22..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

class Regions {
    
    struct Region {
        // 지역명
        var name: String
        
        // 시, 도 구분
        var region: Int
        
        // 위도
        var latitude: Double
        
        // 경도
        var longitude: Double
        
        // 지역에 따른 zoom level
        var zoomLevel: Float
    }

    private var arrayRegion = Array<Region>()
    
    init() {
        if let asset = NSDataAsset(name: "regionList", bundle: Bundle.main) {
            let list = JSON(asset.data)["regionList"]
            for (_, item):(String, JSON) in list {
                let name = item["name"].stringValue
                let region = 0
                let zoomLevel = item["zoom"].floatValue
                
                let latitude = item["lat"].doubleValue
                let longitude = item["lon"].doubleValue
                
                let regionData = Region(name: name, region: region, latitude: latitude, longitude: longitude, zoomLevel: zoomLevel)
                
                self.arrayRegion.append(regionData)
            }
        }
    }
    
    func getNameList() -> Array<String> {
        var arrayRegionName = Array<String>()
        for region in self.arrayRegion {
            arrayRegionName.append(region.name)
        }
        return arrayRegionName
    }
    
    func getZoomLevel(index: Int) -> Float {
        return self.arrayRegion[index].zoomLevel
    }
    
    func getTmapPoint(index: Int) -> TMapPoint {
        let lat = self.arrayRegion[index].latitude
        let lon = self.arrayRegion[index].longitude
        
        return TMapPoint.init(lon: lon, lat: lat)
    }
}

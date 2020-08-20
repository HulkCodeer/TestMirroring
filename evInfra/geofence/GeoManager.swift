//
//  GeoManager.swift
//  evInfra
//
//  Created by 임은주 on 2020/08/20.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

class GeoManager{
	static var locationManager:CLLocationManager = CLLocationManager.init()
	static func start(){
		var regionList = [GeoRegion]()
		Server.getGeoRegion(){(isSuccess, value) in
			let json = JSON(value)
			if(isSuccess){
			  if json["code"] == 1000 {
				let regions = json["data"]
                for json in regions.arrayValue {
                    let regionData = GeoRegion(bJson: json)
                    regionList.append(regionData)
					print("LEJ get \(regionData.charger_id)")
				}
				self.initGeo(regions:regionList)
			  }
			}else{
			  print("LEJ GEO UPDATE isSuccess FAILED..")
			}
		}
	}
	
	static func initGeo(regions:Array<GeoRegion>) {
	   self.locationManager.requestAlwaysAuthorization()
	   locationManager.requestAlwaysAuthorization()            // 위치 권한 받아옴.
	   locationManager.startUpdatingLocation()                 // 위치 업데이트 시작
	   locationManager.allowsBackgroundLocationUpdates = true  // 백그라운드에서도 위치를 체크할 것인지에 대한 여부. 필요없으면 false로 처리하자.
	   locationManager.pausesLocationUpdatesAutomatically = false  // 이걸 써줘야 백그라운드에서 멈추지 않고 돈다

		for region in regions{
			let geofenceRegionCenter = CLLocationCoordinate2D(
				latitude: Double(region.latitude) ?? 0.0,
				longitude: Double(region.longitude) ?? 0.0
			)
			let geofenceRegion = CLCircularRegion(
				center: geofenceRegionCenter,
				radius: 100,
				identifier: region.charger_id
			)
			geofenceRegion.notifyOnEntry = true
			geofenceRegion.notifyOnExit = true
			//지정된 지역 모니터링 시작
			self.locationManager.startMonitoring(for: geofenceRegion)
		}
	}
}

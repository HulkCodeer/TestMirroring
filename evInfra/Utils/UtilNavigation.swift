//
//  UtilNavigation.swift
//  evInfra
//
//  Created by SooJin Choi on 2020/12/07.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation

public class UtilNavigation {
    func showNavigation(vc: UIViewController, startPoint: POIObject, endPoint: POIObject, viaList: [POIObject]) {
        var property: [String: Any?] = [:]
        if let vc = vc as? MainViewController, let charger = vc.selectCharger {
            property = AmpChargerStationModel(charger).toProperty
        }
        
        let optionMenu = UIAlertController(title: nil, message: "네비게이션", preferredStyle: .alert)
        let kakaoMap = UIAlertAction(title: "카카오맵(KAKAO MAP)", style: .default) { _ in
            self.openKakaoNavigation(startPoint: startPoint, endPoint: endPoint, viaList: viaList)
            property["navigationType"] = "카카오맵"
            AmplitudeManager.shared.logEvent(type: .route(.clickStationStartNavigaion), property: property)
        }
        let tMap = UIAlertAction(title: "티맵(T MAP)", style: .default) { _ in
            self.tmapNavigation(startPoint: startPoint, endPoint: endPoint, viaList: viaList)
            property["navigationType"] = "티맵"
            AmplitudeManager.shared.logEvent(type: .route(.clickStationStartNavigaion), property: property)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
       
        optionMenu.addAction(kakaoMap)
        optionMenu.addAction(tMap)
        optionMenu.addAction(cancelAction)
        
        vc.present(optionMenu, animated: true, completion: nil)
    }
    
    private func openKakaoNavigation(startPoint: POIObject, endPoint: POIObject, viaList: [POIObject]) {
        let destination = KNVLocation(name: endPoint.name, x: endPoint.lng as NSNumber, y: endPoint.lat as NSNumber)
        var via: [KNVLocation] = []
        
        let options = KNVOptions()
        options.coordType = .WGS84
        options.rpOption = .fast
        options.startX = startPoint.lng as NSNumber
        options.startY = startPoint.lat as NSNumber

        if !viaList.isEmpty {
            viaList.forEach {
                let location = KNVLocation(name: $0.name, x: $0.lng as NSNumber, y: $0.lat as NSNumber)
                via.append(location)
            }
        }
        
        let params = KNVParams(destination: destination, options: options, viaList: via)
        if KNVNaviLauncher.shared().canOpenKakaoNavi() {
            KNVNaviLauncher.shared().navigate(with: params) { error in
                print("KAKAO NAVI ERROR: \(error.debugDescription)")
            }
        } else {
            UIApplication.shared.open(KNVNaviLauncher.appStoreURL, options: [:], completionHandler: nil)
        }
    }
    
    private func tmapNavigation(startPoint: POIObject, endPoint: POIObject, viaList: [POIObject]) {
        if TMapTapi.isTmapApplicationInstalled() {
            var routeInfo = Dictionary<String, Any>()
            routeInfo["rGoName"] = endPoint.name
            routeInfo["rGoX"] = String(endPoint.lng)
            routeInfo["rGoY"] = String(endPoint.lat)
            routeInfo["rStartName"] = startPoint.name
            routeInfo["rStartX"] = String(startPoint.lng)
            routeInfo["rStartY"] = String(startPoint.lat)

            if !viaList.isEmpty {
                for (index, via) in viaList.enumerated() {
                    routeInfo["rV\(index+1)Name"] = via.name
                    routeInfo["rV\(index+1)Y"] = String(via.lat)
                    routeInfo["rV\(index+1)X"] = String(via.lng)
                }
            }
            
            TMapTapi.invokeRoute(routeInfo)
        } else {
            let tmapURL = TMapTapi.getTMapDownUrl()
            if let url = URL(string: tmapURL!), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: {(success: Bool) in
                    if success {
                        print("Launching \(url) was successful")
                    }
                })
            }
        }
    }
}

struct POIObject {
    var name: String
    var lat: Double
    var lng: Double
}



//
//  UtilNavigation.swift
//  evInfra
//
//  Created by SooJin Choi on 2020/12/07.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation

public class UtilNavigation{
    
    func showNavigation(vc:UIViewController, snm:String, lat:Double, lng:Double){
        
        if !snm.isEmpty && lat != 0.0 && lng != 0.0{
            //action sheet title 지정s
            let optionMenu = UIAlertController(title: nil, message: "네비게이션", preferredStyle: .alert)
               
            //옵션 초기화
            let kakaoMap = UIAlertAction(title: "카카오맵(KAKAO MAP)", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.kakaoNavigation(snm: snm, lat: lat, lng: lng)
            })
        
            let tMap = UIAlertAction(title: "티맵(T MAP)", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.tmapNavigation(snm: snm, lat: lat, lng: lng)
            })
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
           
            //action sheet에 옵션 추가.
            optionMenu.addAction(kakaoMap)
            optionMenu.addAction(tMap)
            optionMenu.addAction(cancelAction)
            
            vc.present(optionMenu, animated: true, completion: nil)
        }
            
    }
    
    
    private func kakaoNavigation(snm:String, lat:Double, lng:Double){
        let destination = KNVLocation(name: snm, x: lng as NSNumber, y: lat as NSNumber)
        
        let options = KNVOptions()
        options.coordType = KNVCoordType.WGS84
        let params = KNVParams(destination: destination, options: options)
        KNVNaviLauncher.shared().navigate(with: params) { (error) in
            print("UtilNavi_kakaoNavi_ERROR")
        }
    }

    private func tmapNavigation(snm:String, lat:Double, lng:Double) {
        if (TMapTapi.isTmapApplicationInstalled()) {
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            TMapTapi.invokeRoute(snm, coordinate: coordinate)
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


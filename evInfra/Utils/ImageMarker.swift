//
//  ImageMarker.swift
//  evInfra
//
//  Created by bulacode on 2018. 3. 6..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import UIKit

public class ImageMarker {
    
    public static let stateNormal = "marker_state_normal"
    public static let markerHere = "marker_here"
    
    public static var markers: [String: UIImage] = [String: UIImage]()

    public static func loadMarkers() {
        let stateIcons = ["marker_state_normal", "marker_state_charging", "marker_state_no_op", "marker_state_no_connect"]
        
        let evFileManager = EVFileManager.sharedInstance
        let companyArray = DBManager.sharedInstance.getCompanyInfoList()
        
        for company in companyArray {
            for icon in stateIcons {
                if let companyId = company.id {
                    if companyId.elementsEqual("A") { // A(기타)인 경우 마커 없음
                        continue
                    }
                    let markerName = "\(icon)_\(companyId)"
                    if let image = evFileManager.loadImageWithoutScale(name: markerName + ".png")?.withRenderingMode(.alwaysOriginal) {
                        ImageMarker.markers[markerName] = image
                    }
                }
            }
        }
    }
    
    /// Get the icon by the file name.
    public static func resizeMarker(path: String) -> UIImage? {
        let size = CGSize(width: 34, height: 34)
        let image = UIImage(named: path)!
        
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(origin: .zero, size: size))
        let marker = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return marker
    }
    
    public static func marker(state: String, company: String, isCharging: Bool, isPay: Bool = false) -> UIImage? {
        let eFM = EVFileManager.sharedInstance
        let stateImage = UIImage(named: state)!
        let chargeImage = UIImage(named: "marker_lightning")!
        let payImage = UIImage(named: "marker_paid")!
        
        let size = CGSize(width: stateImage.width, height: stateImage.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        stateImage.draw(in: CGRect(origin: .zero, size: size))
        if let companyImage = eFM.getSavedImage(named: "\(company).png") {
            companyImage.draw(in: CGRect(origin: .zero, size: size))
        }
        if isCharging {
            chargeImage.draw(in: CGRect(origin: .zero, size: size))
        }
        if isPay {
            payImage.draw(in: CGRect(origin: .zero, size: size))
        }
        
        let marker = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return marker
    }
    
    /// Google icons.
    public static let NORMAL = resizeMarker(path: stateNormal);
    public static let SELECTED_MARKER = resizeMarker(path: markerHere);
}

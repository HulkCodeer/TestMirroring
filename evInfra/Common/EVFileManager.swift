//
//  EVFileManager.swift
//  evInfra
//
//  Created by bulacode on 2018. 7. 9..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation

class EVFileManager {
    
    static let sharedInstance = EVFileManager()
    
    // CompanyInfo Query Strings
    private init() {
    }
    
    func deleteFile(named: String) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
        let filePath = documentsPath.appendingPathComponent(named)
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                // Delete file
                try fileManager.removeItem(atPath: filePath)
            } else {
                print("File does not exist")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func isFileExist(named: String) -> Bool {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
        let filePath = documentsPath.appendingPathComponent(named)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            return true
        } else {
            return false
        }
    }
    
    func getFilePath(named : String) -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
        return documentsPath.appendingPathComponent(named)
    }
    
    func saveImage(image: UIImage, name: String) -> Bool {
        guard let data = image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent(name)!)
            return true
        } catch {
            return false
        }
    }

    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    func loadImageWithoutScale(name:String) -> UIImage? {
        guard let docmentDir = FileManager.default.urls(for:.documentDirectory, in:.userDomainMask).first else { return nil}
        let imageUrl = docmentDir.appendingPathComponent(name)
        do {
            let imageData = try Data(contentsOf: imageUrl)
            return UIImage(data: imageData, scale: UIScreen.main.scale)
        } catch let err as NSError {
            print("image loading error:\(err)")
        }
        return nil
    }
    
    func makeMarkerImage(companyIcon: String, companyId: String) {
        let stateIcons = ["marker_state_normal", "marker_state_charging", "marker_state_no_op", "marker_state_no_connect"]
        let evFileManager = EVFileManager.sharedInstance
        for stateIcon in stateIcons {
            let iconName = "\(stateIcon)_\(companyId).png"
            if(!evFileManager.isFileExist(named: iconName)) {
                let stateImage = UIImage(named: stateIcon)!.withRenderingMode(.alwaysOriginal)
                let chargeImage = UIImage(named: "marker_lightning.png")!.withRenderingMode(.alwaysOriginal)
                
                let size = CGSize(width: stateImage.width, height: stateImage.height)
                UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
                
                stateImage.draw(in: CGRect(origin: .zero, size: size))
                if let companyImage = evFileManager.getSavedImage(named: "\(companyIcon).png")?.withRenderingMode(.alwaysOriginal) {
                    companyImage.draw(in: CGRect(x: 7, y: 1, width: 20, height: 20))
                }
                if stateIcon.elementsEqual("marker_state_charging") {
                    chargeImage.draw(in: CGRect(origin: .zero, size: size))
                }
                if let marker = UIGraphicsGetImageFromCurrentImageContext() {
                    if evFileManager.saveImage(image: marker, name: iconName) {
                        print("make MarkerIcon SUCCESS: " + iconName)
                    } else {
                        print("make MarkerIcon FAIL: " + iconName)
                    }
                }
                UIGraphicsEndImageContext()
            }
        }
    }
}

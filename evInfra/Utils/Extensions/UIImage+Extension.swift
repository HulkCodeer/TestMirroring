//
//  UIImage.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 9..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(withWidth newWidth: CGFloat) -> UIImage! {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func isEqual(other: UIImage) -> Bool {
        guard let data1 = UIImagePNGRepresentation(self) else { return false }
        guard let data2 = UIImagePNGRepresentation(other) else { return false }
        
        return data1.elementsEqual(data2)
    }
    
    func saveImage(_ name: String){
        let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let url = URL(fileURLWithPath: path).appendingPathComponent(name)
        try! UIImagePNGRepresentation(self)?.write(to: url)
        print("Save Image at \(url)")
    }
    
    func saveImage(image: UIImage, name: String) -> Bool {
        guard let data = UIImagePNGRepresentation(image) else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent(name)!)
            return true
        } catch {
            print("saveImage Error \(error.localizedDescription)")
            return false
        }
    }
    
    func saveJPEGImage(image: UIImage, name: String) -> Bool {
        guard let data = UIImageJPEGRepresentation(image, 1.0) else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent(name)!)
            return true
        } catch {
            print("saveImage Error \(error.localizedDescription)")
            return false
        }
    }
    
    func loadImage(name:String) -> UIImage? {
        guard let docmentDir = FileManager.default.urls(for:.documentDirectory, in:.userDomainMask).first else { return nil}
        
        let imageUrl = docmentDir.appendingPathComponent(name)
        do {
            let imageData = try Data(contentsOf: imageUrl)
            
            return UIImage(data: imageData)
        } catch let err as NSError {
            print("image loading error:\(err)")
        }
        return nil
    }

    // crop Image
    func cropImage(image: UIImage, posX: CGFloat, posY: CGFloat, width: Double, height: Double) -> UIImage {
        let cgimage = image.cgImage!
        
        let cgwidth: CGFloat = CGFloat(width)
        let cgheight: CGFloat = CGFloat(height)

        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

        let imageRef: CGImage = cgimage.cropping(to: rect)!

        let resultImage: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        return resultImage
    }    
}

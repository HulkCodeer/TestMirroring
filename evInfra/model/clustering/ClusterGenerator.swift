//
//  ClusteringImage.swift
//  evInfra
//
//  Created by bulacode on 10/01/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

class ClusterGenerator {
    let qImage = UIImage(named: "ic_clustor")!
    let aImage = UIImage(named: "ic_cluster_name")!
    
    var areaView: UIImageView!
    var clusterView: UIImageView!
    
    init() {
        areaView = UIImageView(image: aImage)
        areaView.backgroundColor = UIColor.clear
        areaView.frame = CGRect.init(x: 0, y: 0, width: aImage.size.width, height: aImage.size.height)
        clusterView = UIImageView(image: qImage)
        clusterView.backgroundColor = UIColor.clear
        clusterView.frame = CGRect.init(x: 0, y: aImage.size.height, width: qImage.size.width, height: qImage.size.height)
    }
    
    func generateBaseImage(area: String) -> UIImage? {
        let areaLabel = UILabel(frame: CGRect.init(x: 0, y: 0, width: areaView.frame.width, height: areaView.frame.height))
        let baseImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: qImage.size.width, height: qImage.size.height + aImage.size.height))
        areaLabel.backgroundColor = UIColor.clear
        areaLabel.textAlignment = .center
        areaLabel.textColor = UIColor(rgb: 0x15435C)
        areaLabel.text = area
        areaLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        
        UIGraphicsBeginImageContextWithOptions(baseImageView.bounds.size, false, 0);
        clusterView.layer.render(in: UIGraphicsGetCurrentContext()!)//renderInContext(UIGraphicsGetCurrentContext()!)
        areaView.layer.render(in: UIGraphicsGetCurrentContext()!)//renderInContext(UIGraphicsGetCurrentContext()!)
        areaLabel.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let baseImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return baseImage
    }
    
    func generateClusterImage(value: String, baseImage: UIImage) -> UIImage? {
        let imageView = UIImageView(image: baseImage)
        let label = UILabel(frame: clusterView.frame)
        
        imageView.backgroundColor = UIColor.clear
        imageView.frame = CGRect.init(x: 0, y: 0, width: baseImage.size.width, height: baseImage.size.height)
        
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.text = value
        label.font = UIFont.boldSystemFont(ofSize: 12.0)
        
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0);
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let clusterImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return clusterImage
    }
}

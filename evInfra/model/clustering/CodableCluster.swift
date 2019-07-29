//
//  DecCluList.swift
//  evInfra
//
//  Created by bulacode on 03/12/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import Foundation

class CodableCluster: Codable {
    var lists: [Cluster]
    
    class Cluster : Codable {
        var id: Int?
        var name: String?
        var lng: Double?
        var lat: Double?
        var cl1_id: Int?
        var cl2_id: Int?
        var sum: Int = 0
        var marker: TMapMarkerItem!
        var baseImage: UIImage? = nil
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case lng = "lng"
            case lat = "lat"
            case cl1_id = "cl1_id"
            case cl2_id = "cl2_id"
        }
        
        required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            name = try values.decodeIfPresent(String.self, forKey: .name)
            lng = try values.decodeIfPresent(Double.self, forKey: .lng)
            lat = try values.decodeIfPresent(Double.self, forKey: .lat)
            cl1_id = try values.decodeIfPresent(Int.self, forKey: .cl1_id)
            cl2_id = try values.decodeIfPresent(Int.self, forKey: .cl2_id)
        }
        
        func addVal() {
            self.sum = self.sum + 1
        }
        
        func initSum() {
            self.sum = 0
        }
        
        func setMarker(marker: TMapMarkerItem) {
            self.marker = marker
        }
    }
}

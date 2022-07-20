//
//  ChargerSelectDelegate.swift
//  evInfra
//
//  Created by Shin Park on 12/10/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import Foundation

protocol ChargerSelectDelegate: class {
    func moveToSelected(chargerId: String)
    func moveToSelectLocation(lat: Double, lon: Double)
}

//
//  SearchAddressViewDelegate.swift
//  evInfra
//
//  Created by bulacode on 20/10/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation
protocol SearchAddressViewDelegate {
    func recieveAddressInfo(zonecode: String, fullRoadAddr: String)
}

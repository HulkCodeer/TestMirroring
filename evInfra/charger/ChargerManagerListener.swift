//
//  ChargerManagerListener.swift
//  evInfra
//
//  Created by Michael Lee on 2020/07/21.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
protocol ChargerManagerListener {
    func onComplete()
    func onError(errorMsg : String)
}

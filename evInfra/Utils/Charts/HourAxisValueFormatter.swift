//
//  HourAxisValueFormatter.swift
//  evInfra
//
//  Created by Shin Park on 28/01/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation
import Charts

public class HourAxisValueFormatter: NSObject, IAxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "\(Int(value))시"
    }
}

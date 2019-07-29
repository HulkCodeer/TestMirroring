//
//  ReportChargeViewDelegate.swift
//  evInfra
//
//  Created by 이신광 on 2018. 9. 14..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

protocol ReportChargeViewDelegate {
    func getReportInfo()
}

protocol ReportChargerAddrSearchDelegate {
    func moveToLocation(lat:Double, lon:Double)
}

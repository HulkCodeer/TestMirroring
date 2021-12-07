//
//  PaymentTableViewCell.swift
//  evInfra
//
//  Created by SH on 2021/11/19.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit

class PaymentTableViewCell: UITableViewCell {
    @IBOutlet weak var lbStationName: UILabel!
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbFailMsg: UILabel!
    
    var chargingStatus: ChargingStatus?
        
    func reloadPaymentData(payment: ChargingStatus) {
        self.chargingStatus = payment
        
        if let charging = self.chargingStatus {
            if let stationName = charging.stationName {
                self.lbStationName.text = stationName
            }
            if let fee = charging.fee {
                self.lbAmount.text = "\(fee)원"
            }
            
            if let date = charging.payAuthDate {
                self.lbDate.text = date
            }
            self.lbFailMsg.text = charging.payResultMsg
        }
    }
}

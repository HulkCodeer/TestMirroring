//
//  ChargesTableViewCell.swift
//  evInfra
//
//  Created by Shin Park on 10/07/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

protocol ChargesTableViewCellDelegate {
    func didSelectReceipt(charge: ChargingStatus)
}

class ChargesTableViewCell: UITableViewCell {

    var delegate: ChargesTableViewCellDelegate?
    
    var chargingStatus: ChargingStatus?

    @IBOutlet weak var labelStationName: UILabel!
    @IBOutlet weak var labelCardNo: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelChargingTime: UILabel!
    @IBOutlet weak var labelKwh: UILabel!
    @IBOutlet weak var labelFee: UILabel! // 충전금액
    @IBOutlet weak var labelPay: UILabel! // 결제금액
    
    @IBAction func onClickReceipt(_ sender: UIButton) {
        if let _chargingStatus = self.chargingStatus {
            if let _delegate = self.delegate {
                _delegate.didSelectReceipt(charge: _chargingStatus)
            }
        }
    }
    
    func reloadChargeData(charge: ChargingStatus) {
        self.chargingStatus = charge
        
        if let charging = self.chargingStatus {
            self.labelStationName.text = charging.stationName
            self.labelCardNo.text = charging.cardNumber
            
            let startDate = charging.startDate ?? ""
            let endDate = charging.endDate ?? ""
            self.labelDate.text = startDate + " ~ " + endDate
            
            self.labelChargingTime.text = charging.chargingTime
            
            let chargingKwh = charging.chargingKw ?? "0"
            self.labelKwh.text = chargingKwh + "kWh"
            
            let fee = charging.fee ?? "0"
            self.labelFee.text = fee.currency() + "원"
            
            let realPay = charging.payAmount ?? "0"
            self.labelPay.text = realPay.currency() + "원"
        }
    }
}

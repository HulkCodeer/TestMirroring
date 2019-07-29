//
//  ReceiptView.swift
//  evInfra
//
//  Created by Shin Park on 16/07/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

class ReceiptView: UIView {
    
    @IBOutlet weak var receiptView: UIView!
    
    @IBOutlet weak var labelCardNumber: UILabel!
    @IBOutlet weak var labelCardCo: UILabel!
    @IBOutlet weak var labelPayAuthCode: UILabel!
    
    @IBOutlet weak var labelStationName: UILabel!
    @IBOutlet weak var labelStartDate: UILabel!
    @IBOutlet weak var labelEndDate: UILabel!
    @IBOutlet weak var labelPayDate: UILabel!
    @IBOutlet weak var labelChargingKw: UILabel!
    @IBOutlet weak var labelFee: UILabel!
    
    @IBOutlet weak var labelTotalFee: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        let view = Bundle.main.loadNibNamed("ReceiptView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        self.receiptView.layer.cornerRadius = 8
        self.receiptView.clipsToBounds = true
        self.receiptView.layer.shadowRadius = 8
        self.receiptView.layer.shadowColor = UIColor.black.cgColor
        self.receiptView.layer.shadowOpacity = 0.5
        self.receiptView.layer.shadowOffset = CGSize(width: 0.5, height: 2)
        self.receiptView.layer.masksToBounds = false
    }
    
    public func update(status: ChargingStatus) {
        self.labelCardNumber.text = status.cardNumber // 카드번호
        self.labelCardCo.text = status.cardCo // 카드회사
        self.labelPayAuthCode.text = status.payAuthCode // 승인번호
        
        self.labelStationName.text = status.stationName // 충전소명
        self.labelStartDate.text = status.startDate // 충전시작시간
        self.labelEndDate.text = status.endDate // 충전종료시간
        self.labelPayDate.text = status.payAuthDate // 승인날짜
        self.labelChargingKw.text = status.chargingKw // 충전량
        self.labelFee.text = status.payAmount?.currency() // 결제금액
        
        self.labelTotalFee.text = status.payAmount?.currency()
    }
}

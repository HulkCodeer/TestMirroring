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
    @IBOutlet weak var labelUsedPoint: UILabel!
    
    @IBOutlet weak var labelTotalFee: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let view = Bundle.main.loadNibNamed("ReceiptView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        
        receiptView.layer.cornerRadius = 8
        receiptView.clipsToBounds = true
        receiptView.layer.shadowRadius = 8
        receiptView.layer.shadowColor = UIColor.black.cgColor
        receiptView.layer.shadowOpacity = 0.5
        receiptView.layer.shadowOffset = CGSize(width: 0.5, height: 2)
        receiptView.layer.masksToBounds = false
    }
    
    public func update(status: ChargingStatus) {
        labelCardNumber.text = status.cardNumber // 카드번호
        labelCardCo.text = status.cardCo // 카드회사
        labelPayAuthCode.text = status.payAuthCode // 승인번호
        
        labelStationName.text = status.stationName // 충전소명
        labelStartDate.text = status.startDate // 충전시작시간
        labelEndDate.text = status.endDate // 충전종료시간
        labelPayDate.text = status.payAuthDate // 승인날짜
        labelChargingKw.text = status.chargingKw // 충전량
        labelFee.text = status.fee?.currency() // 충전금액
        labelUsedPoint.text = status.usedPoint // 사용포인트
        
        labelTotalFee.text = status.payAmount?.currency() // 승인금액
    }
}

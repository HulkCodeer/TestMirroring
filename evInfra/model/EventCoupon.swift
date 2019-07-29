//
//  Coupon.swift
//  evInfra
//
//  Created by 이신광 on 07/11/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import Foundation

class EventCoupon {
    let COUPON_STATE_NORMAL = 0
    let COUPON_STATE_USED = 1
    let COUPON_STATE_CANCELED = 2
    
    let EVENT_STATE_NORMAL = 0
    let EVENT_STATE_CANCEL = 1
    
    // event
    var eventId: Int?
    var couponCount: Int?

    // copon
    var coponId: Int?
    var c_state: Int?
    
    // event copon common
    var e_state: Int?
    var endDate: Date?
    var imagePath: String?
    var description: String?
    
    init() {
        // event
        eventId = 0
        couponCount = 0
        
        // copon
        coponId = 0
        c_state = COUPON_STATE_NORMAL
        
        // event copon common
        e_state = EVENT_STATE_NORMAL
        endDate = Date()
        imagePath = ""
        description = ""
    }
    
    func getImageUrl() -> String {
        if let url = imagePath, !url.isEmpty {
            return Const.EV_SERVER_IP + "/" + url
        }
        return ""
    }
    
    func checkCouponStatus(imageView: UIImageView) -> Bool {
        // 이벤트 진행중이 아닐경우 - 이벤트사의 이벤트 취소 ( 쿠폰 사용 X )
        if self.e_state != EVENT_STATE_NORMAL {
            imageView.image = UIImage(named: "ic_event_end")
            return false
        }
        
        // 쿠폰 사용 기간 만료 ( 쿠폰 사용 X )
        let date = Date()
        
        if let eDate = self.endDate, eDate <= date {
            imageView.image = UIImage(named: "ic_event_outdate")
            return false
        }
        
        // 사용자에의한 구매 취소
        if self.c_state == COUPON_STATE_CANCELED {
            imageView.image = UIImage(named: "ic_event_canceled")
            return false
        }
        
        // 사용 완료
        if self.c_state == COUPON_STATE_USED {
            imageView.image = UIImage(named: "ic_event_used")
            return false
        }
        
        return true
    }
    
    func checkEventStatus(imageView: UIImageView) -> Bool {
        // 이벤트 진행 종료
        if self.e_state != EVENT_STATE_NORMAL {
            imageView.image = UIImage(named: "ic_event_end")
            return false
        }
        
        // 이벤트 기간 만료
        let date = Date()
        
        if let eDate = self.endDate, eDate <= date {
            imageView.image = UIImage(named: "ic_event_end")
            return false
        }
        
        if let count = self.couponCount, count < 1 {
            imageView.image = UIImage(named: "ic_event_soldout")
            return false
        }
        
        return true
    }
}

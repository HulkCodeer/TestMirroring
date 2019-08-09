//
//  Coupon.swift
//  evInfra
//
//  Created by bulacode on 06/08/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

class Coupon{
    // 쿠폰 primary key
    var couponId : Int = 0
    // 쿠폰의 상태. 0: 사용가능, 1: 사용완료,  2: 사용기간만료, 3: 이벤트 취소 *특정 사정으로 인해 업체와의 연계가 끊어져... 4: 취소 쿠폰
    var state : Int = 0
    // 쿠폰사용 종료 날짜
    var endDate : String = ""
    // 쿠폰 설명
    var description : String = ""
    // 쿠폰 이미지
    var imagePath : String = ""
    // 쿠폰 타이틀
    var title: String = ""
}

//
//  Event.swift
//  evInfra
//
//  Created by bulacode on 26/07/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

class Event {
    
    // 이벤트 primary key
    var eventId : Int = 0
    
    // 이벤트 상태. 0:진행중, 1:종료, 2:솔다웃
    var state : Int = 0
    
    // 이벤트 종료 날짜
    var endDate : String = ""
    
    // 이벤트 설명
    var description : String = ""
    
    // 이벤트 이미지
    var imagePath : String = ""
    
    // 이벤트 타입
    var eventType : Int = 0
    
    // 이벤트 타입에 따른 StantardValue
    var standardValue : Int = 0
    
    // 이벤트 타이틀
    var title : String = ""
}

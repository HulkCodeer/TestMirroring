//
//  DateConstant.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/11.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

enum DateConstants: String {
    // . :  d
    // 한글 : ko
    // - : s

    case yyyyMMddhhmmssSSSSSS = "yyyy-MM-dd hh:mm:ss.SSSSSS"
    
    /// yyyy.MM.dd HH:mmD
    case yyyyMMddHHmmD = "yyyy.MM.dd HH:mm"
    /// yyyy년 MM월 dd일
    case yyyyMMddKo = "yyyy년 MM월 dd일"
    /// yyyy-MM-dd
    case yyyyMMddS = "yyyy-MM-dd"
    
    /// MM.dd
    case mmddD = "MM.dd"
    /// HH:mm
    case hhmm = "HH:mm"
    
    /// yyyy
    case year = "yyyy"
    /// MM
    case month = "MM"
    /// M
    case monthShort = "M"
    /// dd
    case day = "dd"
            
}

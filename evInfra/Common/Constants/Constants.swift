//
//  Constants.swift
//  evInfra
//
//  Created by youjin kim on 2022/09/15.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

enum Constants {
    static let date = DateConstants.self
    static let view = ViewConstants.self
    
    enum ViewConstants {
        static let naviBarHeight: CGFloat = 56
        static let naviBarItemPadding: CGFloat = 10
        static let naviBarItemWidth: CGFloat = 48
    }
    
    enum DateConstants: String {
        // . :  d
        // 한글 : ko
        // - : s

        /// "yyyy-MM-dd hh:mm:ss.SSSSSS"
        case yyyyMMddhhmmssSSSSSS = "yyyy-MM-dd hh:mm:ss.SSSSSS"
        /// "yyyy-MM-dd HH:mm:ss"
        case yyyyMMddHHmmssSD = "yyyy-MM-dd HH:mm:ss"
        /// "yyyyMMddHHmmss"
        case yyyyMMddHHmmss = "yyyyMMddHHmmss"
        
        /// yyyy.MM.dd HH:mmD
        case yyyyMMddHHmmD = "yyyy.MM.dd HH:mm"
        /// yyyy년 MM월 dd일
        case yyyyMMddKo = "yyyy년 MM월 dd일"
        /// yyyy-MM-dd
        case yyyyMMddS = "yyyy-MM-dd"
        /// yyyy.MM.dd
        case yyyyMMddD = "yyyy.MM.dd"
        
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
}

//
//  CompanyInfo.swift
//  evInfra
//
//  Created by bulacode on 2018. 7. 6..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation

class CompanyInfo {
    
    public static let COMPANY_ID_KEPCO      = "1" // 한전
    public static let COMPANY_ID_JEVS       = "B" // 제주전기자동차서비스
    public static let COMPANY_ID_STRAFFIC   = "L"; // 에스트래픽
    public static let COMPANY_ID_GSC        = "41" // GS 칼텍스
    
    var id: String? = nil
    var name: String?  = nil
    var iconName: String? = nil
    var homepage: String? = nil
    var appstore: String? = nil
    var isVisible: Bool = true
    
    init() {
        
    }

    init(id: String?, cname: String?, icon: String?, page: String?, store: String?, isVisible: Int32) {
        self.id = id
        self.name = cname
        self.iconName = icon
        self.homepage = page
        self.appstore = store
        self.isVisible = (isVisible == 1)
    }
}

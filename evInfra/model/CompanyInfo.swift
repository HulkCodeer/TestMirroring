//
//  CompanyInfo.swift
//  evInfra
//
//  Created by bulacode on 2018. 7. 6..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
class CompanyInfo {
    
    public static let COMPANY_ID_JEVS       = "B" // 제주전기자동차서비스
    public static let COMPANY_ID_STRAFFIC   = "L"; // 에스트래픽
    public static let COMPANY_ID_GSC        = "41" // GS 칼텍스
    public static let COMPANY_ID_EV_MOST    = "45"; // ev Most (SK네트웍스)
    
    var id: String? = nil
    var name: String?  = nil
    var iconName: String? = nil
    var homepage: String? = nil
    var appstore: String? = nil
    var isVisible: Bool = true

    init(id: String?, cname: String?, icon: String?, page: String?, store: String?, isVisible: Int32){
        self.id = id
        self.name = cname
        self.iconName = icon
        self.homepage = page
        self.appstore = store
        if(isVisible == 1){
            self.isVisible = true
        }else{
            self.isVisible = false
        }
    }
}

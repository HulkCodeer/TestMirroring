//
//  CompanyInfoDto.swift
//  evInfra
//
//  Created by Michael Lee on 2020/06/09.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
import GRDB
import SwiftyJSON
class CompanyInfoDto : Record{
    required init(row: Row) {
        company_id = row["company_id"]
        name = row["name"]
        tel = row["tel"]
        icon_name = row["icon_name"]
        icon_date = row["icon_date"]
        homepage = row["homepage"]
        market = row["market"]
        appstore = row["appstore"]
        is_visible = row["is_visible"]
        sort = row["sort"]
        del = row["del"]
        super.init(row: row)
    }
    
    override init() {
        super.init()
    }
    
    override class var databaseTableName: String {
        return "CompanyInfo"
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container["company_id"] = company_id
        container["name"] = name
        container["tel"] = tel
        container["icon_name"] = icon_name
        
        container["icon_date"] = icon_date
        container["homepage"] = homepage
        container["market"] = market
        container["appstore"] = appstore
        container["is_visible"] = is_visible
        container["sort"] = sort
        container["del"] = del
    }
    
    public var company_id : String?

    public var name : String?
    
    public var tel : String?

    public var icon_name : String?

    public var icon_date : String?

    public var homepage : String?

    public var market : String?
    
    public var appstore : String?

    public var is_visible : Bool = true

    public var sort : Int?

    public var del : Bool?

    public func isChangeIcon() -> Bool{
        let updateDate = UserDefault().readString(key: UserDefault.Key.COMPANY_ICON_UPDATE_DATE)
        return StringUtils.isNullOrEmpty(updateDate) || (updateDate.compare(self.icon_date!).rawValue > 0)
    }
    
    public func setCompanyInfo(json : JSON){
        let company_id = json["id"]
        let name = json["name"]
        let tel = json["tel"]
        let icon_name = json["ic_name"]
        let icon_date = json["ic_date"]
        let homepage = json["hp"]
        let market = json["mk"]
        let appstore = json["as"]
        //let is_visible = json["is_visible"]
        let sort = json["sort"]
        let del = json["del"]
        
        self.company_id = company_id.stringValue
        self.name = name.stringValue
        self.tel = tel.stringValue
        self.icon_name = icon_name.stringValue
        self.icon_date = icon_date.stringValue
        self.homepage = homepage.stringValue
        self.market = market.stringValue
        self.appstore = appstore.stringValue
        //self.is_visible = is_visible.boolValue
        self.sort = sort.intValue
        self.del = del.boolValue
    }

}

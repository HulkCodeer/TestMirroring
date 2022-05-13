//
//  JSON+Extension.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/13.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import SwiftyJSON

extension JSON {
    // Non-optional string
    public var dateValue: Date {
        get {
            let getString = self.object as? String ?? ""
            if getString == "" {
                return Date()
            }

            return getString.toDate(dateFormat: "yyyy-MM-dd HH:mm:ss") ?? Date()
        }
        set {}
    }
}

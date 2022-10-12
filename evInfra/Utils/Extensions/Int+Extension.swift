//
//  Int+Extension.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/10/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

extension Int {
    func toPrice() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let makeString = numberFormatter.string(from: NSNumber(value: self)) ?? ""
        return "\(makeString)"
    }        
}

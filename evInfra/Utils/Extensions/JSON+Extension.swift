//
//  JSON+Extension.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/13.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import SwiftyJSON
import Foundation

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

extension JSONEncoder {
    func encodeJSONObject<T: Encodable>(_ value: T, options opt: JSONSerialization.ReadingOptions = []) throws -> Any {
        let data = try encode(value)
        return try JSONSerialization.jsonObject(with: data, options: opt)
    }
}

extension JSONDecoder {
    func decode<T: Decodable>(_: T.Type, withJSONObject object: Any, options opt: JSONSerialization.WritingOptions = []) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: object, options: opt)
        return try self.decode(T.self, from: data)
    }
}

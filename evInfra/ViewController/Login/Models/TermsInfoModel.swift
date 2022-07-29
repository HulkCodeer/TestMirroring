//
//  TermsInfoModel.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/29.
//  Copyright © 2022 soft-berry. All rights reserved.
//

struct TermsInfo: Encodable {
    var termsId: String
    var agree: Bool    
    
    enum CodingKeys: String, CodingKey {
        case termsId = "terms_id"
        case agree
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.termsId, forKey: .termsId)
        try container.encode(self.agree, forKey: .agree)
    }
    
    internal func toDict() -> [String: Any] {
        if let paramData = try? JSONEncoder().encode(self) {
            if let json = try? JSONSerialization.jsonObject(with: paramData, options: []) as? [String: Any] {
                return json ?? [:]
            } else {
                return [:]
            }
        } else {
            return [:]
        }
    }
}

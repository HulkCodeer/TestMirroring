//
//  URL+Extension.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/18.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}

extension Array where Iterator.Element == URLQueryItem {
    subscript(_ key: String) -> String? {
        first(where: { $0.name == key })?.value
    }
}

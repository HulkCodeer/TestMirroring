//
//  URL.swift
//  evInfra
//
//  Created by bulacode on 2018. 7. 26..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}

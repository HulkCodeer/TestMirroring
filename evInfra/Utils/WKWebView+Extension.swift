//
//  WKWebView+Extension.swift
//  evInfra
//
//  Created by youjin kim on 2022/09/21.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import WebKit

extension WKWebView {
    func loadHTMLStringFitSize(_ string: String, baseURL: URL? = nil) {
        let html = """
              <head>
                       <meta name='viewport' content='width=device-width,initial-scale=1,maximum-scale=1'>
                </head>
                \(string)
        """
        self.loadHTMLString(html, baseURL: baseURL)
    }
}

//
//  UIImageView+Extension.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/08/18.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

extension UIImageView {
    internal func sd_setImage(with urlString: String) {
        guard let encodedStr =  urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let url = encodedStr.hasPrefix("http") ? URL(string: encodedStr) : URL(string: "\(Const.AWS_IMAGE_SERVER)\(encodedStr)")
        self.sd_setImage(with: url)
    }
}

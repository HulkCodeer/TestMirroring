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
        let url = urlString.hasPrefix("http") ? URL(string: urlString) : URL(string: "\(Const.AWS_IMAGE_SERVER)\(urlString)")
        self.sd_setImage(with: url)
    }
}

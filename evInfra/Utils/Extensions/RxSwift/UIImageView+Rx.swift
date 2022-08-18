//
//  UIImageView+Rx.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/08/18.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension Reactive where Base: UIImageView {
    internal var bindImage: Binder<String> {
        Binder(self.base) { view, urlPath in
            view.sd_setImage(with: urlPath)
        }
    }
}

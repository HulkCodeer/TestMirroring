//
//  BannerPagerView.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/09/05.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import FSPagerView

internal final class BannerPagerView: FSPagerView {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(_ type: Promotion.Layer = .top) {
        super.init(frame: .zero)
        
        switch type {
        case .top:
            self.isInfinite = true
            self.isScrollEnabled = true
            self.automaticSlidingInterval = 4.0
            self.layer.cornerRadius = 8
            self.layer.masksToBounds = true
            self.backgroundColor = .clear
        default: break
        }
    }
}



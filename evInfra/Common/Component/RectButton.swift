//
//  RectButton.swift
//  evInfra
//
//  Created by 박현진 on 2022/07/04.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

internal final class RectButton: UIButton {
    
    
    override var isSelected: Bool {
        didSet {
            self.isSelected ? self.setTitleColor(GlobalFunctionSwift.RGB(225, 108, 45), for: .selected) :
                self.setTitleColor(Colors.contents05x333333.color, for: .normal)
        }
    }
}

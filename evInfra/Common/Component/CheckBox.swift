//
//  CheckBox.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/06/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

internal final class CheckBox: UIButton {
    override var isSelected: Bool {
        didSet {
            self.isSelected ? setImage(Icons.iconCheckOn.image, for: .selected): setImage(Icons.iconCheckOff.image, for: .normal)
        }
    }
}

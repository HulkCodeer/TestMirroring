//
//  Radio.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/15.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

internal final class Radio: UIButton {
    override var isSelected: Bool {
        didSet {
            self.isSelected ? setImage(Icons.iconRadioSelected.image, for: .selected): setImage(Icons.iconRadioUnselected.image, for: .normal)
        }
    }
}

//
//  DropDownCheckBoxCell.swift
//  evInfra
//
//  Created by bulacode on 14/01/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import DropDown
import M13Checkbox

class DropDownCheckBoxCell: DropDownCell {

    var isChecked = false
    @IBOutlet weak var dropCheckBox: M13Checkbox!

    override func awakeFromNib() {
        super.awakeFromNib()
        dropCheckBox.boxType = .square
        dropCheckBox.checkState = .checked
        dropCheckBox.tintColor = UIColor(rgb: 0x15435C)
        dropCheckBox.tag = self.tag
        dropCheckBox.isEnabled = false
    }

    func setChecked(isChecked: Bool) {
        dropCheckBox.checkState = isChecked ? .checked : .unchecked
    }
}

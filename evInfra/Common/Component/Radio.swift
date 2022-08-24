//
//  Radio.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/15.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

internal final class Radio: UIButton {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    init() {
        super.init(frame:CGRect.zero)
        self.isSelected = false        
        self.tintColor = Colors.contentPrimary.color
    }
    
    override var isSelected: Bool {
        didSet {
            self.isSelected ? setImage(Icons.iconRadioSelected.image, for: .selected): setImage(Icons.iconRadioUnselected.image, for: .normal)
            self.tintColor = self.isSelected ? Colors.contentPositive.color : Colors.contentPrimary.color
        }
    }
}

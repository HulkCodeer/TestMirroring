//
//  RectButton.swift
//  evInfra
//
//  Created by 박현진 on 2022/07/04.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

internal final class RectButton: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    init() {
        super.init(frame:CGRect.zero)
        
        self.setTitleColor(Colors.contentOnColor.color, for: .normal)
        self.setTitleColor(Colors.contentOnColor.color, for: .disabled)
    }
    
    override var isEnabled: Bool {
        didSet {
            self.isEnabled ? setBackgroundColor(Colors.backgroundPositive.color, for: .disabled) : setBackgroundColor(Colors.nt1.color, for: .disabled)
        }
    }
}

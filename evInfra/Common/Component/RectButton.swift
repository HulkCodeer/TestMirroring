//
//  RectButton.swift
//  evInfra
//
//  Created by 박현진 on 2022/07/04.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

internal final class RectButton: UIButton {
    
    enum Const {
        enum Level {
            case primary
            case secondary
            case negative
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    init(level: Const.Level) {
        super.init(frame:CGRect.zero)
        
        self.IBcornerRadius = 8
        
        switch level {
        case .primary: // enable, disable 가능
            self.setTitleColor(Colors.contentOnColor.color, for: .normal)
            self.setTitleColor(Colors.contentOnColor.color, for: .disabled)
            self.setBackgroundColor(Colors.backgroundPositive.color, for: .normal)
            self.setBackgroundColor(Colors.nt1.color, for: .disabled)
            
        case .secondary: // enable, disable 가능
            self.setTitleColor(Colors.contentPrimary.color, for: .normal)
            self.setTitleColor(Colors.nt2.color, for: .disabled)
            self.setBackgroundColor(Colors.backgroundPrimary.color, for: .normal)
            self.IBborderWidth = 1
            self.IBborderColor = Colors.borderOpaque.color
            
        case .negative: // enable만 가능
            self.setTitleColor(Colors.contentOnColor.color, for: .normal)
            self.setBackgroundColor(Colors.backgroundNegative.color, for: .normal)
        }
    }
}

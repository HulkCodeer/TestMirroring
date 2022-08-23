//
//  SwitchColorButton.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/19.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import RxCocoa

final class SwitchColorButton: UIButton {
    override var isSelected: Bool {
        willSet {
            let backgroundColor = newValue ? self.mainColor : self.unselectBackgroundColor
            let textColor = newValue ? self.selectTextColor : self.mainColor

            self.setTitleColor(textColor, for: .normal)
            self.backgroundColor = backgroundColor
        }
    }
    
    private let mainColor: UIColor = UIColor(hex: "#CECECE")
    private let unselectBackgroundColor: UIColor = UIColor.white
    private let selectTextColor: UIColor = Colors.backgroundPrimary.color
    
    // MARK: initializer
    
    init() {
        super.init(frame: .zero)
        
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        let borderWidth: CGFloat = 1
        
        let font: UIFont = .systemFont(ofSize: 14)
        self.layer.borderColor = mainColor.cgColor
        self.layer.borderWidth = borderWidth
        
        self.setTitleColor(mainColor, for: .normal)
        self.backgroundColor = unselectBackgroundColor
        self.titleLabel?.font = font
        self.clipsToBounds = true
        
    }
        
}


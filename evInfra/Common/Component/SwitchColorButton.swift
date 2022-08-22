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
    enum Const {
        static let font: UIFont = .systemFont(ofSize: 14)
        
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 8

        enum Level {
            typealias TintColor = (tintColor: UIColor, unselectBackgroundColor: UIColor, selectTextColor: UIColor)
            
            case contentPositive
            case myBerry
            
            var value: TintColor {
                switch self{
                case .myBerry:
                    return (UIColor(hex: "#CECECE"), UIColor.white, Colors.backgroundPrimary.color)
                case .contentPositive:
                    return TintColor(Colors.contentPositive.color, UIColor.white, Colors.backgroundPrimary.color)
                }
            }
        }
        
        enum RoundType {
            case round
            case sectionRound(UIView.CornerRadiusType)
            case none
        }
    }
    
    override var isSelected: Bool {
        willSet {
            let backgroundColor = newValue ? self.level.value.tintColor : self.level.value.unselectBackgroundColor
            let textColor = newValue ? self.level.value.selectTextColor : self.level.value.tintColor

            self.setTitleColor(textColor, for: .normal)
            self.backgroundColor = backgroundColor
        }
    }

    private let level: Const.Level
    
    // MARK: initializer
    
    init(level: Const.Level, roundType: Const.RoundType = .round) {
        self.level = level
        super.init(frame: .zero)
        
        setUI()
        setBorder(roundType: roundType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        
        self.setTitleColor(level.value.tintColor, for: .normal)
        self.backgroundColor = level.value.unselectBackgroundColor
        self.titleLabel?.font = Const.font
        self.clipsToBounds = true
        
    }
        
    private func setBorder(roundType type: Const.RoundType) {
        switch type {
        case .round:
            self.layer.borderColor = level.value.tintColor.cgColor
            self.layer.borderWidth = Const.borderWidth
            self.layer.cornerRadius = Const.cornerRadius
        case .sectionRound(let type):
            self.roundCorners(
                cornerType: type,
                radius:Const.cornerRadius,
                borderColor: level.value.tintColor.cgColor,
                borderWidth: Const.borderWidth)
        case .none:
            self.layer.borderColor = level.value.tintColor.cgColor
            self.layer.borderWidth = Const.borderWidth
        }
    }
    
}


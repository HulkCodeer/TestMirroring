//
//  FilterTagButton.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/09/29.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

internal final class FilterTagButton: UIButton {
    
    enum TagType {
        case select
        case action
    }
    
    private let spacingWithTitleAndImage: CGFloat = 5.5
    private let topBottomMargin: CGFloat = 4
    private let leftRightMargin: CGFloat = 12
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(type: TagType) {
        super.init(frame: .zero)
        
        self.IBcornerRadius = 15
        self.IBborderWidth = 1
        self.layer.masksToBounds = true
        
        switch type {
        case .action:
            self.setTitleColor(Colors.contentSecondary.color, for: .normal)
            self.setTitleColor(Colors.gr7.color, for: .selected)
            self.contentEdgeInsets = UIEdgeInsets(top: topBottomMargin, left: leftRightMargin + spacingWithTitleAndImage, bottom: topBottomMargin, right: leftRightMargin)
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -spacingWithTitleAndImage, bottom: 0, right: spacingWithTitleAndImage)
            self.layer.borderColor = Colors.nt1.color.cgColor
            self.semanticContentAttribute = .forceRightToLeft
            self.setBackgroundColor(Colors.backgroundPrimary.color, for: .normal)
            self.setBackgroundColor(Colors.backgroundPositiveLight.color, for: .selected)
        case .select:
            self.setTitleColor(Colors.contentSecondary.color, for: .normal)
            self.setTitleColor(Colors.gr6.color, for: .selected)
            self.contentEdgeInsets = UIEdgeInsets(top: topBottomMargin, left: leftRightMargin, bottom: topBottomMargin, right: leftRightMargin + spacingWithTitleAndImage)
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacingWithTitleAndImage, bottom: 0, right: -spacingWithTitleAndImage)
            self.layer.borderColor =  Colors.nt1.color.cgColor
            self.semanticContentAttribute = .forceLeftToRight
            self.setBackgroundColor(Colors.backgroundPrimary.color, for: .normal)
            self.setBackgroundColor(Colors.backgroundPrimary.color, for: .selected)
        }
    }
}


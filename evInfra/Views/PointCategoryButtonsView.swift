//
//  PointCategoryButtonsView.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/09.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

import SnapKit

internal final class PointCategoryButtonsView: UIView {
    private let contentsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillEqually
    }
    private let allTypeButton = UIButton().then {
        let color = UIColor(hex: "#CECECE")
        $0.roundCorners(
            [.topLeft, .bottomLeft],
            radius: 8,
            borderColor: color,
            borderWidth: 2)
        $0.setTitle("전체", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = color
    }
    private let useTypeButton = UIButton().then {
        let color = UIColor(hex: "#CECECE")
        
        $0.layer.borderColor = color.cgColor
        $0.layer.borderWidth = 2
        $0.setTitle("사용", for: .normal)
        $0.setTitleColor(color, for: .normal)
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    private let saveTypeButton = UIButton().then {
        let color = UIColor(hex: "#CECECE")
        
        $0.roundCorners(
            [.topRight, .bottomRight],
            radius: 8,
            borderColor: color,
            borderWidth: 2)
        $0.setTitle("적립", for: .normal)
        $0.setTitleColor(color, for: .normal)
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
    init() {
        super.init(frame: .zero)
        
        setUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI
    
    private func setUI() {
        self.addSubview(contentsStackView)
        
        contentsStackView.addArrangedSubview(allTypeButton)
        contentsStackView.addArrangedSubview(useTypeButton)
        contentsStackView.addArrangedSubview(saveTypeButton)
    }
    
    private func setConstraints() {
        
    }
    
}


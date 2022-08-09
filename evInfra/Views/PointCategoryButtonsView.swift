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
        $0.spacing = -1
    }
    
    let allTypeButton = UIButton().then {
        let color = UIColor(hex: "#CECECE")
        
        $0.roundCorners(
            cornerType: .left,
            radius: 8,
            borderColor: color.cgColor,
            orderWidth: 1)
        $0.setTitle("전체", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = color
    }
    let useTypeButton = UIButton().then {
        let color = UIColor(hex: "#CECECE")
        
        $0.layer.borderColor = color.cgColor
        $0.layer.borderWidth = 1
        $0.setTitle("사용", for: .normal)
        $0.setTitleColor(color, for: .normal)
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    let saveTypeButton = UIButton().then {
        let color = UIColor(hex: "#CECECE")

        $0.roundCorners(
            cornerType: .right,
            radius: 8,
            borderColor: color.cgColor,
            orderWidth: 1)
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
        allTypeButton.addTarget(self, action: #selector(didTapAllTypButton(_:)), for: .touchUpInside)
        useTypeButton.addTarget(self, action: #selector(didTapUseTypeButton(_:)), for: .touchUpInside)
        saveTypeButton.addTarget(self, action: #selector(didTapSaveTypeButton(_:)), for: .touchUpInside)
        
        self.addSubview(contentsStackView)
        
        contentsStackView.addArrangedSubview(allTypeButton)
        contentsStackView.addArrangedSubview(useTypeButton)
        contentsStackView.addArrangedSubview(saveTypeButton)
    }
    
    private func setConstraints() {
        contentsStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: Action
    
    @objc private func didTapAllTypButton(_ sender: UIButton) {
        setSelectedButton(button: allTypeButton)
        
        setUnselectedButton(useTypeButton)
        setUnselectedButton(saveTypeButton)
    }
    
    @objc private func didTapUseTypeButton(_ sender: UIButton) {
        setSelectedButton(button: useTypeButton)
        
        setUnselectedButton(allTypeButton)
        setUnselectedButton(saveTypeButton)
    }
    
    @objc private func didTapSaveTypeButton(_ sender: UIButton) {
        setSelectedButton(button: saveTypeButton)
        
        setUnselectedButton(allTypeButton)
        setUnselectedButton(useTypeButton)
    }
    
    // MARK: privateAction
    
    private func setSelectedButton(button: UIButton) {
        let color = UIColor(hex: "#CECECE")
        
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
    }
    
    private func setUnselectedButton(_ button: UIButton) {
        let color = UIColor(hex: "#CECECE")
        
        button.setTitleColor(color, for: .normal)
        button.backgroundColor = Colors.backgroundPrimary.color
    }
    
}


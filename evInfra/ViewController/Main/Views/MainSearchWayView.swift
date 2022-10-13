//
//  MainSearchWayView.swift
//  evInfra
//
//  Created by youjin kim on 2022/10/07.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

import RxCocoa
import Then
import SnapKit

final class MainSearchWayView: UIView {
    internal lazy var startTextField = UnderLineTextField().then {
        $0.placeholder = "출발지를 입력하세요."
    }
    internal lazy var startTextClearButton = startTextField.clearButton

    
    internal lazy var endTextField = UnderLineTextField().then {
        $0.placeholder = "도착지를 입력하세요."
    }
    internal lazy var endTextClearButton = endTextField.clearButton
    
    internal lazy var removeButton = UIButton().then {
        $0.setTitleColor(UIColor(hex: "#2A536D "), for: .normal)
        $0.setTitle("지우기", for: .normal)
        $0.fontSize = 15
    }
    internal lazy var searchButton = UIButton().then {
        $0.setTitleColor(UIColor(hex: "#2A536D "), for: .normal)
        $0.setTitle("경로찾기", for: .normal)
        $0.fontSize = 15
    }
    
    // MARK: - initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - makeUI
    
    private func makeUI() {
        self.backgroundColor = Colors.backgroundPrimary.color
        
        self.addSubview(startTextField)
        self.addSubview(startTextClearButton)
        self.addSubview(removeButton)

        self.addSubview(endTextField)
        self.addSubview(endTextClearButton)
        self.addSubview(searchButton)
        
        let verticalMargin: CGFloat = 4
        let horizontalMargin: CGFloat = 8
                
        let buttonWidth: CGFloat = 66
        let clearButtonSize: CGFloat = 32

        startTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(verticalMargin)
            $0.leading.equalToSuperview().inset(horizontalMargin)
            $0.trailing.equalTo(removeButton.snp.leading)
            $0.bottom.equalTo(self.snp.centerY)
        }
        startTextClearButton.snp.makeConstraints {
            $0.top.bottom.trailing.equalTo(startTextField)
            $0.width.equalTo(clearButtonSize)
        }
        removeButton.snp.makeConstraints {
            $0.centerY.equalTo(startTextField)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(startTextField)
            $0.width.equalTo(buttonWidth)
        }
        
        endTextField.snp.makeConstraints {
            $0.top.equalTo(startTextField.snp.bottom)
            $0.leading.equalToSuperview().inset(horizontalMargin)
            $0.trailing.equalTo(searchButton.snp.leading)
            $0.bottom.equalToSuperview().inset(verticalMargin)
        }
        endTextClearButton.snp.makeConstraints {
            $0.top.bottom.trailing.equalTo(endTextField)
            $0.width.equalTo(clearButtonSize)
        }
        searchButton.snp.makeConstraints {
            $0.centerY.equalTo(endTextField)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(endTextField)
            $0.width.equalTo(buttonWidth)
        }
    }
    
}

//
//  SearchWayTextField.swift
//  evInfra
//
//  Created by youjin kim on 2022/10/11.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit

/// 취소버튼, highlight 선 보유한 TextField
class SearchWayTextField: UITextField {
    private lazy var clearButton = UIButton().then {
        let image = UIImage(asset: Icons.iconCloseSm)
        $0.setImage(image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFill
        $0.isHidden = true
    }
    private lazy var highilightLine = UIView().then {
        $0.backgroundColor = Colors.backgroundPositive.color
        $0.isHidden = true
    }
    
    override var intrinsicContentSize: CGSize {
      return CGSize(width: bounds.width, height: 32)
    }
    
    // MARK: - initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
        makeAction()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - makeUI
    
    private func makeUI() {
        self.addSubview(clearButton)
        self.addSubview(highilightLine)
        
        let removeButtonSize: CGFloat = 32
        
        clearButton.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.width.equalTo(removeButtonSize)
        }
        highilightLine.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    // MARK: - Action
    
    func setHighilightColor(_ color: UIColor) {
        highilightLine.backgroundColor = color
    }
    
    private func makeAction() {
        let clearAction = UIAction { [weak self] _ in
            self?.text = String()
        }
        clearButton.addAction(clearAction, for: .touchUpInside)
        
        let highlightAction = UIAction { [weak self] _ in
            self?.highilightLine.isHidden = false
            self?.clearButton.isHidden = false
        }
        self.addAction(highlightAction, for: .touchUpInside)
        
        let editEndAction = UIAction { [weak self] _ in
            self?.highilightLine.isHidden = true
            self?.clearButton.isHidden = true
        }
        self.addAction(editEndAction, for: .editingDidEndOnExit)
    }
}

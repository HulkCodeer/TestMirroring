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
class UnderLineTextField: UITextField {
    lazy var clearButton = UIButton().then {
        let image = UIImage(asset: Icons.iconCloseSm)
        $0.setImage(image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFill
        $0.isHidden = true
    }
    private lazy var highilightLine = UIView().then {
        $0.backgroundColor = Colors.nt3.color
    }
    
    override var intrinsicContentSize: CGSize {
      return CGSize(width: bounds.width, height: 32)
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
        self.delegate = self
        
        self.addSubview(highilightLine)

        highilightLine.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }
    
}

extension UnderLineTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        highilightLine.backgroundColor = Colors.backgroundPositive.color
        highilightLine.snp.updateConstraints {
            $0.height.equalTo(1)
        }
        
        clearButton.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        highilightLine.backgroundColor = Colors.nt3.color
        highilightLine.snp.updateConstraints {
            $0.height.equalTo(0.5)
        }
        
        clearButton.isHidden = true
    }
}

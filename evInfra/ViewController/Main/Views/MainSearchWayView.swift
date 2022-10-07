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
    let startTextField = UITextField()
    let endTextField = UITextField()
    
    let removeButton = UIButton()
    let searchButton = UIButton()
    
    // MARK: - initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - makeUI
    
    private func setUI() {
        self.backgroundColor = Colors.backgroundPrimary.color

    }
    
    private func setConstraints() {
        
    }
    
}

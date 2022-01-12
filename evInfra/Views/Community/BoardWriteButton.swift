//
//  BoardWriteButton.swift
//  evInfra
//
//  Created by PKH on 2022/01/10.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class BoardWriteButton: UIButton {
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        // button
        layer.cornerRadius = 6
        layer.borderWidth = 1
        backgroundColor = UIColor(red: 255, green: 255, blue: 255)
        borderColor = UIColor(red: 215, green: 215, blue: 215)
        contentEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16)
        semanticContentAttribute = .forceLeftToRight
        translatesAutoresizingMaskIntoConstraints = false
        
        // button image
        setImage(UIImage(named: "iconWriteSm"), for: .normal)
        imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 4)
        imageView?.contentMode = .scaleAspectFit
        
        // button label
        setTitleColor(UIColor(red: 25, green: 25, blue: 25), for: .normal)
        setTitle("글쓰기", for: .normal)
        titleLabel?.font = .boldSystemFont(ofSize: 16)
    }
}

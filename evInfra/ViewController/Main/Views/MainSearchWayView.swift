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
    internal lazy var startTextField = SearchWayTextField().then {
        $0.placeholder = "출발지를 입력하세요."
    }
    internal lazy var endTextField = SearchWayTextField().then {
        $0.placeholder = "도착지를 입력하세요."
    }
    
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

    }
    
}

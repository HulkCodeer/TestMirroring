//
//  NavigationCloseBtn.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/05/30.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

internal final class NavigationCloseBtn: UIView {
    @IBInspectable var IBimageColor: UIColor? {
        get {
            self.imgView.tintColor
        }
        set {
            self.imgViewColor = newValue ?? Colors.rd1.color
            self.imgView.tintColor = newValue
        }
    }
    
    @IBInspectable var IBimageSide: CGFloat {
        get {
            self.imgViewWidth
        }
        set {
            self.imgViewWidth = newValue
        }
    }
    
    @IBInspectable var IBimageLeading: CGFloat {
        get {
            self.imgViewLeading
        }
        set {
            self.imgViewLeading = newValue
            self.imgView.snp.remakeConstraints {
                $0.leading.equalToSuperview().offset(self.imgViewLeading)
                $0.width.height.equalTo(self.imgViewWidth)
                $0.centerY.equalToSuperview()
            }
        }
    }
    
    private lazy var imgView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Icons.iconCloseSm.image
        $0.tintColor = self.imgViewColor
        $0.contentMode = .scaleToFill
    }
    
    internal lazy var btn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private var imgViewLeading: CGFloat = 0
    private var imgViewWidth: CGFloat = 24
    private var imgViewColor: UIColor = Colors.rd1.color
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    init() {
        super.init(frame: .zero)
        self.makeUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.makeUI()
    }
    
    private func makeUI() {
        self.addSubview(self.imgView)
        self.imgView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(self.imgViewLeading)
            $0.width.height.equalTo(self.imgViewWidth)
            $0.centerY.equalToSuperview()
        }
        
        self.addSubview(self.btn)
        self.btn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

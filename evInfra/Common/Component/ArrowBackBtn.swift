//
//  ArrowBackBtn.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/05/30.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

internal final class ArrowBackBtn: UIView {
    enum Const {
        enum SizeType {
            case size16
            case size20
            case size24
            case size32
            
            var getImage: UIImage {
                switch self {
                case .size16: return Icons.iconArrowLeftXs.image
                case .size20: return Icons.iconArrowLeftSm.image
                case .size24: return Icons.iconArrowLeftMd.image
                case .size32: return Icons.iconArrowLeftLg.image
                }
            }
        }
        
        static let baseColor: UIColor = .white
    }
    
    @IBInspectable var IBimageColor: UIColor? {
        get {
            self.imgView.tintColor
        }
        set {
            self.imgViewColor = newValue ?? Const.baseColor
            self.imgView.tintColor = newValue
        }
    }
    
    @IBInspectable var IBimageWidth: CGFloat {
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
        $0.image = self.sizeType.getImage
        $0.tintColor = self.imgViewColor
        $0.contentMode = .scaleToFill
    }
    
    internal lazy var btn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private var imgViewLeading: CGFloat = 0
    private var imgViewWidth: CGFloat = 16
    private var imgViewColor: UIColor = Const.baseColor
    
    private var sizeType: Const.SizeType
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    init() {
        self.sizeType = .size16
        super.init(frame: .zero)
    }
    
    init(_ sizeType: Const.SizeType = .size16) {
        self.sizeType = sizeType
        super.init(frame: .zero)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.sizeType = .size16
        super.init(coder: aDecoder)
    }
    
    func makeUI() {
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

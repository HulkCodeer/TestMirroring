//
//  ArrowBackBtn.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/05/30.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

internal final class Arrow: UIView {
    enum Const {
        enum SizeType {
            case size16(Direction)
            case size20(Direction)
            case size24(Direction)
            case size32(Direction)
            
            var getImage: UIImage {
                switch self {
                case .size16(let direction):
                    switch direction {
                    case .left:
                        return Icons.iconArrowLeftXs.image
                    case .right:
                        return Icons.iconArrowRightXs.image
                    case .up:
                        return Icons.iconArrowUpXs.image
                    case .down:
                        return Icons.iconArrowDownXs.image
                    }
                    
                case .size20(let direction):
                    switch direction {
                    case .left:
                        return Icons.iconArrowLeftSm.image
                    case .right:
                        return Icons.iconArrowRightSm.image
                    case .up:
                        return Icons.iconArrowUpSm.image
                    case .down:
                        return Icons.iconArrowDownSm.image
                    }
                    
                case .size24(let direction):
                    switch direction {
                    case .left:
                        return Icons.iconArrowLeftMd.image
                    case .right:
                        return Icons.iconArrowRightMd.image
                    case .up:
                        return Icons.iconArrowUpMd.image
                    case .down:
                        return Icons.iconArrowDownMd.image
                    }
                    
                case .size32(let direction):
                    switch direction {
                    case .left:
                        return Icons.iconArrowLeftLg.image
                    case .right:
                        return Icons.iconArrowRightLg.image
                    case .up:
                        return Icons.iconArrowUpLg.image
                    case .down:
                        return Icons.iconArrowDownLg.image
                    }                    
                }
            }
        }
        
        enum Direction {
            case left
            case right
            case down
            case up
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
    private var imgViewWidth: CGFloat = 24
    private var imgViewColor: UIColor = Const.baseColor
    
    private var sizeType: Const.SizeType
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    init() {
        self.sizeType = .size24(.left)
        super.init(frame: .zero)
        self.makeUI()
    }
    
    init(_ sizeType: Const.SizeType = .size24(.left)) {
        self.sizeType = sizeType
        super.init(frame: .zero)
        self.makeUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.sizeType = .size24(.left)
        super.init(coder: aDecoder)
        self.makeUI()
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

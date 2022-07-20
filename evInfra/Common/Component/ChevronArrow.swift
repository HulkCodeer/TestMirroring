//
//  ChevronBtn.swift
//  evInfra
//
//  Created by 박현진 on 2022/06/15.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

internal final class ChevronArrow: UIView {
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
                        return Icons.iconChevronLeftXs.image
                    case .right:
                        return Icons.iconChevronRightXs.image
                    case .up:
                        return Icons.iconChevronUpXs.image
                    case .down:
                        return Icons.iconChevronDownXs.image
                    }
                    
                case .size20(let direction):
                    switch direction {
                    case .left:
                        return Icons.iconChevronLeftSm.image
                    case .right:
                        return Icons.iconChevronRightSm.image
                    case .up:
                        return Icons.iconChevronUpSm.image
                    case .down:
                        return Icons.iconChevronDownSm.image
                    }
                    
                case .size24(let direction):
                    switch direction {
                    case .left:
                        return Icons.iconChevronLeftMd.image
                    case .right:
                        return Icons.iconChevronRightMd.image
                    case .up:
                        return Icons.iconChevronUpMd.image
                    case .down:
                        return Icons.iconChevronDownMd.image
                    }
                    
                case .size32(let direction):
                    switch direction {
                    case .left:
                        return Icons.iconChevronLeftLg.image
                    case .right:
                        return Icons.iconChevronRightLg.image
                    case .up:
                        return Icons.iconChevronUpLg.image
                    case .down:
                        return Icons.iconChevronDownLg.image
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

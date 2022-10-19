//
//  NewTagListViewCell.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/10/18.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

internal final class NewTagListViewCell: UICollectionViewCell {
    
    // MARK: UI
    internal lazy var totalView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
        $0.IBcornerRadius = 15
        $0.IBborderWidth = 1
        $0.IBborderColor = Colors.nt1.color
    }
    
    internal lazy var imgView = UIImageView()
    
    internal lazy var titleLbl = UILabel().then {
        $0.text = ""
        $0.font = .systemFont(ofSize: 14)
        $0.sizeToFit()
    }
    
    internal lazy var btn = UIButton().then {
        $0.isSelected = false
    }
    
    // MARK: VARIABLE
    private let disposeBag = DisposeBag()
    
    // MARK: SYSTEM FUNC
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: FUNC
    private func makeUI() {
        self.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        totalView.addSubview(imgView)
        imgView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        
        totalView.addSubview(titleLbl)
        titleLbl.snp.makeConstraints {
            $0.leading.equalTo(imgView.snp.trailing).offset(4)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-12)
            $0.height.equalTo(22)
        }
        
        totalView.addSubview(btn)
        btn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    internal func getInteresticSize(text: String, cv: UICollectionView) -> CGSize {
        let font = (name: titleLbl.font.fontName, size: titleLbl.font.pointSize)
        let textSize = titleLbl.textSize(font: UIFont(name: font.name, size: font.size)!, text: text)
        let leftPaddingSize = 12 + 16 + 4 // 아이콘 leading + 아이콘 width + 아이콘 trailing
        
        if textSize.width + CGFloat(leftPaddingSize) >= cv.frame.size.width {
            let height = titleLbl.heightForView(text: text, font: UIFont(name: font.name, size: font.size)!, width: cv.frame.size.width)
            return CGSize(width: cv.frame.size.width + CGFloat(leftPaddingSize), height: height + 8)
        } else {
            return CGSize(width: textSize.width + 12 + CGFloat(leftPaddingSize), height: textSize.height + 8)
        }
    }
}


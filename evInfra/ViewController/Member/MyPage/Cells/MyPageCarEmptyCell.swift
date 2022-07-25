//
//  MyPageCarEmptyCell.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit

internal final class MyPageCarEmptyCell: CommonBaseTableViewCell, ReactorKit.View {
    private lazy var emptyTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addDotLineBorder(radius: 10)
        $0.IBborderColor = Colors.contentTertiary.color
        $0.IBborderWidth = 1
    }
    
    private lazy var emptyImgView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Icons.iconCarEmpty.image
    }
    
    private lazy var emptyGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        $0.textColor = Colors.contentSecondary.color
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.text = "내 전기차 등록해보세요!"
    }
    
    internal var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    override func makeUI() {
        super.makeUI()
        // add shadow on cell
        self.contentView.addSubview(emptyTotalView)
        emptyTotalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
                        
        emptyTotalView.addSubview(emptyImgView)
        emptyImgView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(72)
        }
        
        emptyTotalView.addSubview(emptyGuideLbl)
        emptyGuideLbl.snp.makeConstraints {
            $0.leading.equalTo(emptyTotalView)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(20)
        }
    }
        
    internal func bind(reactor: MyPageCarListReactor) {
        
    }
}

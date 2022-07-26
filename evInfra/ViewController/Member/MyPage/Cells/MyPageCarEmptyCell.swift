//
//  MyPageCarEmptyCell.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import UIKit

internal final class MyPageCarEmptyCell: CommonBaseTableViewCell, ReactorKit.View {
    private lazy var emptyTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false        
    }
    
    private lazy var emptyBorderImgView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Icons.carEmptyBorder.image
        $0.tintColor = Colors.contentTertiary.color
    }
    
    private lazy var emptyImgView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Icons.iconCarEmpty.image
        $0.contentMode = .scaleAspectFill
    }
    
    private lazy var emptyGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        $0.textColor = Colors.contentSecondary.color
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.text = "내 전기차 등록해보세요!"
    }
    
    private lazy var moveAddCarBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
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
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(72)
        }
        
        emptyTotalView.addSubview(emptyBorderImgView)
        emptyBorderImgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
                        
        emptyTotalView.addSubview(emptyImgView)
        emptyImgView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(88)
            $0.height.equalTo(48)
        }
        
        emptyTotalView.addSubview(emptyGuideLbl)
        emptyGuideLbl.snp.makeConstraints {
            $0.leading.equalTo(emptyImgView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        emptyTotalView.addSubview(moveAddCarBtn)
        moveAddCarBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
        
    internal func bind(reactor: MyPageCarListReactor) {
        moveAddCarBtn.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { MyPageCarListReactor.Action.moveCarRegisterView }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
}

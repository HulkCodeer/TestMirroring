//
//  MyPageCarTableViewCell.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import UIKit

internal final class MyPageCarListCell: CommonBaseTableViewCell, ReactorKit.View {
    private lazy var backgroundTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.backgroundSecondary.color
    }
            
    private lazy var mainCarBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
            
    private lazy var carImgView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Icons.iconCarEmpty.image
        $0.contentMode = .scaleAspectFill
    }
    
    private lazy var carNumberLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        $0.textColor = Colors.contentPrimary.color
        $0.font = .systemFont(ofSize: 16, weight: .regular)
    }
    
    private lazy var carModelLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        $0.textColor = Colors.contentTertiary.color
        $0.font = .systemFont(ofSize: 14, weight: .regular)
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
        self.contentView.addSubview(backgroundTotalView)
        backgroundTotalView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(72)
        }
        
        backgroundTotalView.addSubview(mainCarBtn)
        mainCarBtn.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(20)
            $0.centerY.equalToSuperview()
        }
        
        backgroundTotalView.addSubview(carImgView)
        carImgView.snp.makeConstraints {
            $0.leading.equalTo(mainCarBtn.snp.trailing).offset(16)
            $0.height.equalTo(48)
            $0.width.equalTo(80)
            $0.centerY.equalToSuperview()
        }
                        
        backgroundTotalView.addSubview(carNumberLbl)
        carNumberLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalTo(carImgView.snp.trailing).offset(16)
            $0.height.equalTo(20)
        }
        
        backgroundTotalView.addSubview(carModelLbl)
        carModelLbl.snp.makeConstraints {
            $0.leading.equalTo(carImgView.snp.trailing).offset(16)
            $0.top.equalTo(carNumberLbl.snp.bottom).offset(4)
            $0.height.equalTo(16)
        }
        
        backgroundTotalView.addSubview(moveAddCarBtn)
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

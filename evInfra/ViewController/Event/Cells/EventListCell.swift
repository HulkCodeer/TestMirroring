//
//  EventListCell.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/09/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import UIKit
import SwiftyJSON

internal final class EventListCell: CommonBaseTableViewCell, ReactorKit.View {
    private lazy var backgroundTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.backgroundSecondary.color
        $0.IBcornerRadius = 10
    }
            
    private lazy var mainCarBtn = MyPageCarListButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Icons.iconStarFillSm.image, for: .selected)
        $0.setImage(Icons.iconStarSm.image, for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: .zero, left: 16, bottom: .zero, right: .zero)
        $0.isSelected = false
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
    
    private lazy var moveCarInfoBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    internal var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.carImgView.image = nil
        self.carModelLbl.text = ""
        self.carNumberLbl.text = ""
        self.mainCarBtn.isSelected = false
        self.disposeBag = DisposeBag()
    }
    
    override func makeUI() {
        super.makeUI()
        // add shadow on cell
        self.contentView.addSubview(backgroundTotalView)
        backgroundTotalView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(72)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        backgroundTotalView.addSubview(carImgView)
        carImgView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(52)
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
        
        backgroundTotalView.addSubview(moveCarInfoBtn)
        moveCarInfoBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        backgroundTotalView.addSubview(mainCarBtn)
        mainCarBtn.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.width.equalTo(36)
            $0.height.equalTo(20)
            $0.centerY.equalToSuperview()
        }
    }
        
    internal func bind(reactor: EventDetailReactor) {
       
    }
}

internal final class MyPageCarListButton: UIButton {
    override var isSelected: Bool {
        didSet {
            self.isSelected ? setImage(Icons.iconStarFillSm.image, for: .selected): setImage(Icons.iconStarSm.image, for: .normal)
            self.tintColor = self.isSelected ? Colors.contentPositive.color : Colors.contentPrimary.color
        }
    }
}

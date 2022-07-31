//
//  MyPageCarTableViewCell.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import UIKit
import SwiftyJSON

internal final class MyPageCarListCell: CommonBaseTableViewCell, ReactorKit.View {
    private lazy var backgroundTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.backgroundSecondary.color
        $0.IBcornerRadius = 10
    }
            
    private lazy var mainCarBtn = MyPageCarListButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Icons.iconStarFillSm.image, for: .selected)
        $0.setImage(Icons.iconStarSm.image, for: .normal)
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
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(20)
            $0.centerY.equalToSuperview()
        }
    }
        
    internal func bind(reactor: MyPageCarListReactor) {
        reactor.state.compactMap { $0.carInfoModel }
            .asDriver(onErrorJustReturn: CarInfoModel(JSON.null))
            .drive(onNext: { [weak self] carInfoModel in
                guard let self = self else { return }
                self.carImgView.sd_setImage(with: URL(string: carInfoModel.dpYes.img))
                
                self.mainCarBtn.isSelected = carInfoModel.mainCar
                
                if carInfoModel.carNum == "TBD" {
                    self.carModelLbl.text = carInfoModel.dpYes.cmpy
                    self.carNumberLbl.text = carInfoModel.dpYes.mdRep
                } else {
                    self.carModelLbl.text = carInfoModel.dpYes.mdSep
                    self.carNumberLbl.text = carInfoModel.carNum
                }
                
            })
            .disposed(by: self.disposeBag)
        
        moveCarInfoBtn.rx.tap
            .map { _ in MyPageCarListReactor.Action.moveCarInfoView }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        mainCarBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard !reactor.currentState.carInfoModel.mainCar else { return }
                
                let popupModel = PopupModel(title: "현재 등록한 차량을\n대표 차량으로 등록하시겠어요?",
                                            message: "대표 차량 등록 시, 필터 등 차량에 맞게 설정됩니다.",
                                            confirmBtnTitle: "대표 차량 설정", cancelBtnTitle: "취소", confirmBtnAction: {
                    Observable.just(MyPageCarListReactor.Action.setChangeMainCar)
                        .bind(to: reactor.action)
                        .disposed(by: self.disposeBag)
                })

                let popup = ConfirmPopupViewController(model: popupModel)
                                            
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                })
            })
            .disposed(by: self.disposeBag)
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

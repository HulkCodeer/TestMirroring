//
//  CarRegistrationViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/07/14.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit

internal final class CarRegistrationViewController: CommonBaseViewController, StoryboardView {
    
    // MARK: UI
    
    private lazy var naviTotalView = CommonNaviView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.naviTitleLbl.text = "차량 등록"
    }
    
    private lazy var skipTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "건너뛰기"
        $0.textColor = Colors.contentPrimary.color
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    }
    
    private lazy var skipBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var carRegisterStepScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.isHidden = false
    }
    
    private lazy var carRegisterStepTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
                 
    private lazy var mainTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.text = "반가워요! 이브이님 😊\n차량에 맞는 전기차 충전소를 찾아드릴게요. "
        $0.numberOfLines = 2
    }
    
    private lazy var subTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentSecondary.color
        $0.textAlignment = .natural
        $0.text = "내 전기차 번호를 등록해보세요. "
        $0.numberOfLines = 1
    }
    
    private lazy var carNumberLookUpTf = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.IBborderColor = Colors.borderOpaque.color
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
        $0.returnKeyType = .next
    }
    
    private lazy var registerNoticeLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.contentTertiary.color
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.text = "등록 주의사항"
    }
    
    private lazy var carOwnerRegisterStepScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.isHidden = false
    }
            
    private lazy var nextBtn = RectButton(level: .primary).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("다음으로", for: .normal)
        $0.setTitle("다음으로", for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.isEnabled = true
        $0.IBcornerRadius = 6
    }
    
    // MARK: VARIABLE
        
            
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        let screenWidth = UIScreen.main.bounds.width
        
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
                        
        self.contentView.addSubview(skipTitleLbl)
        skipTitleLbl.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(naviTotalView.snp.centerY)
            $0.height.equalTo(20)
        }
        
        self.contentView.addSubview(nextBtn)
        nextBtn.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        self.contentView.addSubview(carRegisterStepScrollView)
        carRegisterStepScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom).offset(24)
            $0.width.equalTo(screenWidth)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nextBtn.snp.top)
        }
        
        carRegisterStepScrollView.addSubview(carRegisterStepTotalView)
        carRegisterStepTotalView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(screenWidth - 32)
            $0.centerX.equalToSuperview()
        }
        
        carRegisterStepTotalView.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        carRegisterStepTotalView.addSubview(subTitleLbl)
        subTitleLbl.snp.makeConstraints {
            $0.top.equalTo(mainTitleLbl.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        carRegisterStepTotalView.addSubview(carNumberLookUpTf)
        carNumberLookUpTf.snp.makeConstraints {
            $0.leading.equalToSuperview()
        }
        
        carRegisterStepTotalView.addSubview(registerNoticeLbl)
        registerNoticeLbl.snp.makeConstraints {
            $0.top.equalTo(carNumberLookUpTf.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
                      
        // 차량 소유자 등록 화면
        self.contentView.addSubview(carOwnerRegisterStepScrollView)
        carOwnerRegisterStepScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom).offset(24)
            $0.width.equalTo(screenWidth)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nextBtn.snp.top)
        }
        
        carOwnerRegisterStepScrollView.addSubview(carOwnerRegisterStepScrollView)
        carOwnerRegisterStepScrollView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(screenWidth - 32)
            $0.centerX.equalToSuperview()
        }
    }
    
    internal func bind(reactor: CarRegistrationReactor) {
        nextBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let isFirstStepViewHidden = self.carRegisterStepScrollView.isHidden
                guard !isFirstStepViewHidden else {
//                    Observable.just(SignUpReactor.Action.validUserMoreInfoStep)
//                        .bind(to: reactor.action)
//                        .disposed(by: self.disposeBag)
                    return
                }
                
//                Observable.just(SignUpReactor.Action.validUserInfoStep)
//                    .bind(to: reactor.action)
//                    .disposed(by: self.disposeBag)
            })
            .disposed(by: self.disposeBag)
    }
}

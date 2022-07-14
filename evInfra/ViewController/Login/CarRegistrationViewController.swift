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
    
    private lazy var firstStepScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.isHidden = false
    }
    
    private lazy var secondStepScrollView = UIScrollView().then {
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
    
    private lazy var carRegistrationFirstStepViewController = SignUpFirstStepViewController()
    private lazy var carRegistrationSecondStepViewController = SignUpSecondStepViewController()
            
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
        
        self.contentView.addSubview(firstStepScrollView)
        firstStepScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom).offset(24)
            $0.width.equalTo(screenWidth)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nextBtn.snp.top)
        }
        
        self.contentView.addSubview(secondStepScrollView)
        secondStepScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom).offset(24)
            $0.width.equalTo(screenWidth)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nextBtn.snp.top)
        }
        
        self.addChildViewController(carRegistrationFirstStepViewController)
        firstStepScrollView.addSubview(carRegistrationFirstStepViewController.view)
        carRegistrationFirstStepViewController.view.frame = firstStepScrollView.bounds
        carRegistrationFirstStepViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.addChildViewController(carRegistrationSecondStepViewController)
        secondStepScrollView.addSubview(carRegistrationSecondStepViewController.view)
        carRegistrationSecondStepViewController.view.frame = secondStepScrollView.bounds
        carRegistrationSecondStepViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    internal func bind(reactor: SignUpReactor) {
        nextBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let isFirstStepViewHidden = self.carRegistrationFirstStepViewController.view.isHidden
                
                guard !isFirstStepViewHidden else {
                    let viewcon = CarRegistrationViewController()
                    viewcon.reactor = reactor
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                    return
                }
                                
                self.carRegistrationSecondStepViewController.view.isHidden = isFirstStepViewHidden
                self.carRegistrationFirstStepViewController.view.isHidden = !isFirstStepViewHidden
            })
            .disposed(by: self.disposeBag)
    }
}

//
//  NewPaymentStatusViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/08/21.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

internal final class NewPaymentStatusViewController: CommonBaseViewController {
    // MARK: - UI
    
    private lazy var naviTotalView = CommonNaviView().then {        
        $0.naviTitleLbl.text = "충전충"
    }
    
    private lazy var totalScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
    }
    
    private lazy var totalStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 8
    }
    
    private lazy var chargingInfoTotalView = UIView()
    
    private lazy var stationNameLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
    }
    
    private lazy var chargingGuideLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 2
        $0.text = "충전기 정보를 가져오는데 약간의 시간차가 있어 실제 정보와 오차가 있는 것처럼 보일 수 있습니다."
    }
    
    private lazy var circleView = CircularProgressBar()
    
    private lazy var nextBtn = RectButton(level: .primary).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("충전 대기중", for: .normal)
        $0.setTitle("충전 대기중", for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.isEnabled = false
        $0.IBcornerRadius = 6
    }
    
    
    // MARK: - VARIABLE
    
    // MARK: - SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        let screenWidth = UIScreen.main.bounds.width
        
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(nextBtn)
        nextBtn.snp.makeConstraints {
            $0.width.equalTo(screenWidth)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-16)
            $0.centerX.equalToSuperview()
        }
        
        self.contentView.addSubview(totalScrollView)
        totalScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom)
            $0.leading.trailing.width.centerX.equalToSuperview()
            $0.bottom.equalTo(nextBtn.snp.top)
        }
        
        totalScrollView.addSubview(totalStackView)
        totalStackView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
        
        totalStackView.addSubview(chargingInfoTotalView)
        chargingInfoTotalView.snp.makeConstraints {
            $0.height.equalTo(368)
        }
        
        chargingInfoTotalView.addSubview(stationNameLbl)
        stationNameLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(20)
        }
        
        chargingInfoTotalView.addSubview(chargingGuideLbl)
        chargingGuideLbl.snp.makeConstraints {
            $0.top.equalTo(stationNameLbl.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        chargingInfoTotalView.addSubview(circleView)
        circleView.snp.makeConstraints {
            $0.top.equalTo(chargingGuideLbl.snp.bottom).offset(32)
            $0.width.height.equalTo(168)
            $0.centerX.equalToSuperview()
        }
                    
    }
}

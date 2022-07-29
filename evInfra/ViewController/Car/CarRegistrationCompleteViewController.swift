//
//  CarRegistrationCompleteViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/15.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import UIKit

internal final class CarRegistrationCompleteViewController: CommonBaseViewController, StoryboardView {

    // MARK: UI
            
    private lazy var naviTotalView = CommonNaviView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.naviTitleLbl.text = "차량 등록 완료"
    }
                    
    private lazy var totalScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.isHidden = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        $0.addGestureRecognizer(tapGesture)
    }
    
    private lazy var totalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var welcomeGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.contentPrimary.color
        $0.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        $0.text = "짠! 차량을 등록 완료했어요!️"
    }
    
    private lazy var regDateTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var regDateMainTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.contentPrimary.color
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.text = "EV6와 함께 한지 ⚡5년 12개월 12일째⚡️에요!"
    }
    
    private lazy var regDateSubTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.contentPrimary.color
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.text = "최초등록일 2022.00.00"
    }
    
    private lazy var carNumberTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.IBcornerRadius = 6
        $0.backgroundColor = UIColor(red: 176, green: 224, blue: 244)
    }
    
    private lazy var carNumberLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.contentPrimary.color
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.text = ""
    }
    
    private lazy var carImgView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var carMakeCompanyTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.contentTertiary.color
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.text = "제조사명"
    }
    
    private lazy var carMakeCompanyLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.contentPrimary.color
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.text = ""
    }
    
    private lazy var nextBtn = RectButton(level: .primary).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("EV Infra 시작하기", for: .normal)
        $0.setTitle("EV Infra 시작하기", for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.isEnabled = true
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
                                        
        self.contentView.addSubview(nextBtn)
        nextBtn.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        self.contentView.addSubview(totalScrollView)
        totalScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom).offset(24)
            $0.width.equalTo(screenWidth)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nextBtn.snp.top)
        }
        
        totalScrollView.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(screenWidth)
            $0.centerX.equalToSuperview()
        }
        
        totalView.addSubview(welcomeGuideLbl)
        welcomeGuideLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(24)
        }
        
        totalView.addSubview(regDateTotalView)
        regDateTotalView.snp.makeConstraints {
            $0.top.equalTo(welcomeGuideLbl.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(302)
            $0.height.equalTo(64)
        }
        
        totalView.addSubview(carNumberTotalView)
        carNumberTotalView.snp.makeConstraints {
            $0.top.equalTo(regDateTotalView.snp.bottom).offset(9)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(28)
        }
        
        carNumberTotalView.addSubview(carNumberLbl)
        carNumberLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-8)
            $0.top.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(-4)
        }
        
        totalView.addSubview(carImgView)
        carImgView.snp.makeConstraints {
            $0.top.equalTo(carNumberTotalView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(240)
            $0.height.equalTo(141)
        }
        
        totalView.addSubview(carMakeCompanyTitleLbl)
        carMakeCompanyTitleLbl.snp.makeConstraints {
            $0.top.equalTo(carImgView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(16)
        }
        
        totalView.addSubview(carMakeCompanyLbl)
        carMakeCompanyLbl.snp.makeConstraints {
            $0.top.equalTo(carMakeCompanyTitleLbl.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(20)
        }
    }
    
    internal func bind(reactor: CarRegistrationReactor) {
        
    }
    
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }
}

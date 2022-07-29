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

    enum CarInfoType: CaseIterable {
        case cpcty // 공인 전비
        case btrycpcty // 배터리 용량
        case drvcpcty // 주행거리
        
        internal var typeDesc: String {
            switch self {
            case .cpcty: return "공인 전비"
            case .btrycpcty: return "배터리용량"
            case .drvcpcty: return "주행거리"
            }
        }
        
        internal var typeUnit: String {
            switch self {
            case .cpcty: return "km/kWh"
            case .btrycpcty: return "kW"
            case .drvcpcty: return "km"
            }
        }
    }
    
    enum CarBasicInfoType: CaseIterable {
        case pwrMax // 최대출력
        case carSep // 차종
        case brthY // 연식
        
        internal var typeDesc: String {
            switch self {
            case .pwrMax: return "최대출력"
            case .carSep: return "차종"
            case .brthY: return "연식"
            }
        }
        
        internal var typeUnit: String {
            switch self {
            case .pwrMax: return "kW"
            default: return ""
            }
        }
        
        internal var icon: UIImage {
            switch self {
            case .pwrMax: return Icons.iconElectricSm.image
            case .carSep: return Icons.iconEvSm.image
            case .brthY: return Icons.iconCalendarSm.image
            }
        }
    }
    
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
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
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
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.text = ""
    }
    
    private lazy var carInfoTotalStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 8
        $0.backgroundColor = .white
    }
    
    private lazy var basicInfo = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.contentDisabled.color
        $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        $0.text = "내 차 기본 제원"
    }
    
    private lazy var maximumLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.contentDisabled.color
        $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
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
        
        totalView.addSubview(carInfoTotalStackView)
        carInfoTotalStackView.snp.makeConstraints {
            $0.top.equalTo(carMakeCompanyTitleLbl).offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(64)
        }
                        
        for carInfoType in CarInfoType.allCases {
            let carInfoView = self.createCarInfoTypeView(type: carInfoType)
            self.carInfoTotalStackView.addArrangedSubview(carInfoView)
        }
        
        let lineView = self.createLineView()
        totalView.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.top.equalTo(carInfoTotalStackView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(6)
        }
    }
    
    internal func bind(reactor: CarRegistrationReactor) {
        
    }
    
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    private func createCarInfoTypeView(type: CarInfoType) -> UIView {
        let view = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Colors.backgroundSecondary.color
            $0.IBcornerRadius = 10
        }
                                  
        let topTitleLbl = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textAlignment = .natural
            $0.numberOfLines = 1
            $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            $0.textColor = Colors.contentPrimary.color
        }
        
        view.addSubview(topTitleLbl)
        topTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
            $0.height.equalTo(20)
        }
        
        let bottomTitleLbl = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textAlignment = .natural
            $0.numberOfLines = 1
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = Colors.contentTertiary.color
        }
        
        view.addSubview(bottomTitleLbl)
        bottomTitleLbl.snp.makeConstraints {
            $0.top.equalTo(topTitleLbl.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
            $0.height.equalTo(16)
            $0.bottom.equalToSuperview().offset(-12)
        }
                                        
        return view
    }
    
    private func createCarBasicInfoTypeView(type: CarBasicInfoType) -> UIView {
        let view = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Colors.backgroundSecondary.color
            $0.IBcornerRadius = 10
        }
        
        let imgView = UIImageView().then {
            $0.image =
        }
                                  
        let topTitleLbl = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textAlignment = .natural
            $0.numberOfLines = 1
            $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            $0.textColor = Colors.contentPrimary.color
        }
        
        view.addSubview(topTitleLbl)
        topTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
            $0.height.equalTo(20)
        }
        
        let bottomTitleLbl = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textAlignment = .natural
            $0.numberOfLines = 1
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = Colors.contentTertiary.color
        }
        
        view.addSubview(bottomTitleLbl)
        bottomTitleLbl.snp.makeConstraints {
            $0.top.equalTo(topTitleLbl.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
            $0.height.equalTo(16)
            $0.bottom.equalToSuperview().offset(-12)
        }
                                        
        return view
    }
}

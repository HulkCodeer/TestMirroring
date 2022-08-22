//
//  NewPaymentStatusViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/08/21.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

internal final class NewPaymentStatusViewController: CommonBaseViewController {
    enum ChargeInfoType: String, CaseIterable {
        case amount = "충전량"
        case elapsedTime = "경과 시간"
        case speed = "충전 속도"
        
        internal var toValue: String { self.rawValue }
        internal var unitGuideValue: String {
            switch self {
            case .amount: return "-kWh"
            case .elapsedTime: return "-"
            case .speed: return "-kW"
            }
        }
    }
    
    // MARK: - UI
    
    private lazy var naviTotalView = CommonNaviView().then {        
        $0.naviTitleLbl.text = "충전충"
    }
    
    private lazy var nextBtn = RectButton(level: .primary).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("충전 대기중", for: .normal)
        $0.setTitle("충전 대기중", for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.isEnabled = false
        $0.IBcornerRadius = 6
    }
    
    private lazy var totalScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
    }
    
    private lazy var totalStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 4
        $0.backgroundColor = Colors.backgroundTertiary.color
    }
    
    private lazy var chargeInfoTotalView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
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
    
    private lazy var chargeStatusTotalView = UIView()
    
    private lazy var chargeStatusLbl = UILabel().then {
        $0.text = "충전 대기"
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = Colors.contentDisabled.color
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private lazy var chargeStatusSubLbl = UILabel().then {
        $0.text = "충전 커넥터를 차량과 연결 후 잠시만 기다려 주세요."
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private lazy var chargeSpeedInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.spacing = 0
    }
    
    private lazy var discountInfoTotalView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    private lazy var discountInfoMarginTotalView = UIView()
    
    private lazy var discountMainTitleLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "충전요금 할인"
    }
    
    private lazy var discountEventTitleLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "(이벤트 문구) 할인"
    }
    
    private lazy var discountTitleLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "할인 금액"
    }
    
    private lazy var discountLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "0원"
    }
    
    private lazy var berryInfoTotalView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    private lazy var berryInfoMarginTotalView = UIView()
    
    private lazy var berryMainTitleLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "베리 사용"
    }
    
    private lazy var myBerryHoldTitleLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 2
        $0.text = "보유베리"
    }
    
    private lazy var myBerryHoldLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 2
        $0.text = "0원"
    }
    
    private lazy var myBerryUseTitleLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 2
        $0.text = "사용베리"
    }
    
    private lazy var myBerryUseLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 2
        $0.text = "0원"
    }
    
    private lazy var berryUseTf = UITextField().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.keyboardType = .default
        $0.IBborderColor = Colors.borderOpaque.color
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 4
        $0.placeholder = "베리를 입력해 주세요"
        $0.clearButtonMode = .always
    }
    
    private lazy var berryUseAllBtn = RectButton(level: .primary).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("전액 사용", for: .normal)
        $0.setTitle("전액 사용", for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.isEnabled = false
        $0.IBcornerRadius = 6
    }
    
    private lazy var alwaysUseBerryGuideLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentDisabled.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "항상 이 베리 사용"
    }
    
    private lazy var alwaysUseBerryBtn = CheckBox().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isSelected = false
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
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(48)
            $0.centerX.equalToSuperview()
        }
        
        self.contentView.addSubview(totalScrollView)
        totalScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom)
            $0.leading.trailing.centerX.equalToSuperview()
            $0.width.equalTo(screenWidth)
            $0.bottom.equalTo(nextBtn.snp.top)
        }
        
        totalScrollView.addSubview(totalStackView)
        totalStackView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
        
        totalStackView.addArrangedSubview(chargeInfoTotalView)
        
        chargeInfoTotalView.addSubview(stationNameLbl)
        stationNameLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(20)
        }
        
        chargeInfoTotalView.addSubview(chargingGuideLbl)
        chargingGuideLbl.snp.makeConstraints {
            $0.top.equalTo(stationNameLbl.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.greaterThanOrEqualTo(32)
        }
        
        chargeInfoTotalView.addSubview(circleView)
        circleView.snp.makeConstraints {
            $0.top.equalTo(chargingGuideLbl.snp.bottom).offset(32)
            $0.width.height.equalTo(168)
            $0.centerX.equalToSuperview()
        }
        
        chargeInfoTotalView.addSubview(chargeStatusTotalView)
        chargeStatusTotalView.snp.makeConstraints {
            $0.center.equalTo(circleView)
            $0.width.equalTo(circleView.snp.width)
            $0.height.equalTo(74)
        }
              
        chargeStatusTotalView.addSubview(chargeStatusLbl)
        chargeStatusLbl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        chargeStatusTotalView.addSubview(chargeStatusSubLbl)
        chargeStatusSubLbl.snp.makeConstraints {
            $0.top.equalTo(chargeStatusLbl.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(34)
        }
        
        chargeInfoTotalView.addSubview(chargeSpeedInfoStackView)
        chargeSpeedInfoStackView.snp.makeConstraints {
            $0.top.equalTo(circleView.snp.bottom).offset(32)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(68)
        }
        
        for chargeInfoType in ChargeInfoType.allCases {
            chargeSpeedInfoStackView.addArrangedSubview(self.createChargeInfoView(type: chargeInfoType))
        }
        
        totalStackView.addArrangedSubview(discountInfoTotalView)
        discountInfoTotalView.snp.makeConstraints {
            $0.top.equalTo(chargeInfoTotalView.snp.bottom).offset(4)
            $0.height.equalTo(132)
        }
        
        discountInfoTotalView.addSubview(discountInfoMarginTotalView)
        discountInfoMarginTotalView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(-20)
        }
        
        discountInfoMarginTotalView.addSubview(discountMainTitleLbl)
        discountMainTitleLbl.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        discountInfoMarginTotalView.addSubview(discountEventTitleLbl)
        discountEventTitleLbl.snp.makeConstraints {
            $0.top.equalTo(discountEventTitleLbl.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        discountInfoMarginTotalView.addSubview(discountTitleLbl)
        discountTitleLbl.snp.makeConstraints {
            $0.top.equalTo(discountEventTitleLbl.snp.bottom).offset(24)
            $0.leading.equalToSuperview()
            $0.height.equalTo(20)
            $0.bottom.equalToSuperview()
        }
        
        discountInfoMarginTotalView.addSubview(discountLbl)
        discountLbl.snp.makeConstraints {
            $0.centerY.equalTo(discountTitleLbl.snp.centerY)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        totalStackView.addArrangedSubview(berryInfoTotalView)
        berryInfoTotalView.snp.makeConstraints {
            $0.top.equalTo(discountInfoTotalView.snp.bottom).offset(4)
            $0.height.equalTo(240)
        }
        
        berryInfoTotalView.addSubview(berryInfoMarginTotalView)
        berryInfoMarginTotalView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(-20)
        }
        
        berryInfoMarginTotalView.addSubview(berryMainTitleLbl)
        berryMainTitleLbl.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        berryInfoMarginTotalView.addSubview(myBerryHoldTitleLbl)
        myBerryHoldTitleLbl.snp.makeConstraints {
            $0.top.equalTo(berryMainTitleLbl.snp.bottom).offset(24)
            $0.leading.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        berryInfoMarginTotalView.addSubview(myBerryHoldLbl)
        myBerryHoldLbl.snp.makeConstraints {
            $0.centerY.equalTo(myBerryHoldTitleLbl.snp.centerY)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        berryInfoMarginTotalView.addSubview(myBerryUseTitleLbl)
        myBerryUseTitleLbl.snp.makeConstraints {
            $0.top.equalTo(myBerryHoldTitleLbl.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        berryInfoMarginTotalView.addSubview(myBerryUseLbl)
        myBerryUseLbl.snp.makeConstraints {
            $0.centerY.equalTo(myBerryUseTitleLbl.snp.centerY)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        berryInfoMarginTotalView.addSubview(berryUseAllBtn)
        berryUseAllBtn.snp.makeConstraints {
            $0.top.equalTo(myBerryUseLbl.snp.bottom).offset(16)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalTo(104)
        }
        
        berryInfoMarginTotalView.addSubview(berryUseTf)
        berryUseTf.snp.makeConstraints {
            $0.top.equalTo(myBerryUseTitleLbl).offset(16)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(berryUseAllBtn.snp.leading).offset(-8)
            $0.height.equalTo(40)
            $0.centerY.equalTo(berryUseAllBtn.snp.centerY)
        }
        
        berryInfoMarginTotalView.addSubview(alwaysUseBerryBtn)
        alwaysUseBerryBtn.snp.makeConstraints {
            $0.top.equalTo(berryUseAllBtn.snp.bottom).offset(16)
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(24)
            $0.bottom.equalToSuperview()
        }
        
        berryInfoMarginTotalView.addSubview(alwaysUseBerryGuideLbl)
        alwaysUseBerryGuideLbl.snp.makeConstraints {
            $0.top.equalTo(berryUseAllBtn.snp.bottom).offset(16)
            $0.trailing.equalTo(alwaysUseBerryBtn.snp.leading).offset(-8)
            $0.centerY.equalTo(alwaysUseBerryBtn.snp.centerY)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
    
    // MARK: FUNC
            
    private func createChargeInfoView(type: ChargeInfoType) -> UIView {
        let view = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let valueLbl = UILabel().then {
            $0.text = "\(type.unitGuideValue)"
            $0.font = .systemFont(ofSize: 18, weight: .bold)
            $0.textColor = Colors.contentPrimary.color
            $0.textAlignment = .center
        }
        
        let guideLbl = UILabel().then {
            $0.text = "\(type.toValue)"
            $0.font = .systemFont(ofSize: 16, weight: .regular)
            $0.textColor = Colors.contentPrimary.color
            $0.textAlignment = .center
        }
        view.addSubview(valueLbl)
        valueLbl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        view.addSubview(guideLbl)
        guideLbl.snp.makeConstraints {
            $0.top.equalTo(valueLbl.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        return view
    }
}

//
//  NewPaymentStatusViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/08/21.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import SwiftyJSON
import RxSwift
import ReactorKit

internal final class NewPaymentStatusViewController: CommonBaseViewController, StoryboardView {
    enum ChargeInfoType: String, CaseIterable {
        case chargePower = "충전량"
        case elapsedTime = "경과 시간"
        case speed = "충전 속도"
        
        internal var toValue: String { self.rawValue }
        internal var unitGuideValue: String {
            switch self {
            case .chargePower: return "-kWh"
            case .elapsedTime: return "-"
            case .speed: return "-kW"
            }
        }
    }
    
    // MARK: - UI
            
    private lazy var naviTotalView = CommonNaviView().then {        
        $0.naviTitleLbl.text = "충전중"
    }
    
    private lazy var nextBtn = RectButton(level: .primary).then {
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
    
    private lazy var chargePowerTotalView = UIView()
    private lazy var chargePowerLbl = UILabel().then {
        $0.text = "\(ChargeInfoType.chargePower.unitGuideValue)"
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .center
    }
        
    private lazy var chargePowerGuideLbl = UILabel().then {
        $0.text = "\(ChargeInfoType.chargePower.toValue)"
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .center
    }
    
    private lazy var chargeElapsedTimeTotalView = UIView()
    private lazy var chargeElapsedTimeLbl = UILabel().then {
        $0.text = "\(ChargeInfoType.elapsedTime.unitGuideValue)"
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .center
    }
        
    private lazy var chargeElapsedTimeGuideLbl = Chronometer().then {
        $0.text = "\(ChargeInfoType.elapsedTime.toValue)"
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .center
    }
    
    private lazy var chargeSpeedTotalView = UIView()
    private lazy var chargeSpeedLbl = UILabel().then {
        $0.text = "\(ChargeInfoType.speed.unitGuideValue)"
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .center
    }
        
    private lazy var chargeSpeedGuideLbl = UILabel().then {
        $0.text = "\(ChargeInfoType.speed.toValue)"
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .center
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
        $0.text = "할인"
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
        $0.keyboardType = .numberPad
        $0.IBborderColor = Colors.borderOpaque.color
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
        $0.placeholder = "베리를 입력해 주세요"
        $0.addLeftPadding(padding: 8)
        $0.clearButtonMode = .whileEditing
        $0.delegate = self
    }
    
    private lazy var berryUseAllBtn = RectButton(level: .primary).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("전액 사용", for: .normal)
        $0.setTitle("전액 사용", for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.isEnabled = false
        $0.IBcornerRadius = 6
    }
    
    private lazy var alwaysUseBerryTotalBtn = UIButton()
    
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
    
    private lazy var paymentInfoTotalView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    private lazy var paymentInfoMarginTotalView = UIView()
    
    private lazy var paymentMainTitleLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "결제 정보"
    }
    
    private lazy var currentAmountTotalView = UIView()
    private lazy var currentAmountTitleLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "현재 금액"
    }
    
    private lazy var currentAmountLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "0원"
    }
    
    private lazy var discountEventResultTotalView = UIView()
    private lazy var discountEventResultTitleLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "할인 금액"
    }
    
    private lazy var discountEventResultNameLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = ""
    }
    
    private lazy var discountEventResultAmountLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "0원"
    }
        
    private lazy var useBerryTotalView = UIView()
    private lazy var useBerryTitleLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "베리 사용"
    }
    
    private lazy var useBerryLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "0원"
    }
    
    private lazy var estimatedTitleLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "예상 결제 금액"
    }
    
    private lazy var estimatedLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentNegative.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "0"
    }
    
    private lazy var estimatedWonLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "원"
    }
    
    private lazy var userWarringLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 2
        $0.text = "충전기 정보를 가져오는데 약간의 시간차가 있어 실제 정보와 오차가 있는 것처럼 보일 수 있습니다."
    }
            
    // MARK: - VARIABLE
    
    private let STATUS_READY = 0
    private let STATUS_START = 1
    private let STATUS_FINISH = 2
    private let TIMER_COUNT_NORMAL_TICK = 5 // 30 30초 주기로 충전 상태 가져옴. 시연을 위해 임시 5초
    private let TIMER_COUNT_COMPLETE_TICK = 5 // TODO test 위해 10초로 변경. 시그넷 충전기 테스트 후 시간 정할 것.
    
    private var chargingStartTime = ""
    private var isStopCharging = false
    private var chargingStatus = ChargingStatus.init()
        
    // 충전속도 계산
    private var preChargingKw: String = ""
    private var preUpdateTime: String = ""
    
    private var myPoint = 0 // 소유 베리
    private var willUsePoint = 0 // 사용예정 베리 (충전 계산 시 적용될 최종 베리)
    private var alwaysUsePoint = 0 // 항상 사용할 베리 (베리사용 설정)
    private var prevAlwaysUsePoint = 0 // 설정이 변경되었을 경우 되돌릴 설정베리값
    
    private var timer = Timer()
    
    internal var cpId: String = ""
    internal var connectorId: String = ""
    
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
                
        chargeSpeedInfoStackView.addArrangedSubview(chargePowerTotalView)
        chargeSpeedInfoStackView.addArrangedSubview(chargeElapsedTimeTotalView)
        chargeSpeedInfoStackView.addArrangedSubview(chargeSpeedTotalView)
        
        chargePowerTotalView.addSubview(chargePowerLbl)
        chargePowerLbl.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        chargePowerTotalView.addSubview(chargePowerGuideLbl)
        chargePowerGuideLbl.snp.makeConstraints {
            $0.top.equalTo(chargePowerLbl.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        chargeElapsedTimeTotalView.addSubview(chargeElapsedTimeLbl)
        chargeElapsedTimeLbl.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        chargeElapsedTimeTotalView.addSubview(chargeElapsedTimeGuideLbl)
        chargeElapsedTimeGuideLbl.snp.makeConstraints {
            $0.top.equalTo(chargeElapsedTimeLbl.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        chargeSpeedTotalView.addSubview(chargeSpeedLbl)
        chargeSpeedLbl.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        chargeSpeedTotalView.addSubview(chargeSpeedGuideLbl)
        chargeSpeedGuideLbl.snp.makeConstraints {
            $0.top.equalTo(chargeSpeedLbl.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
                        
        totalStackView.addArrangedSubview(discountInfoTotalView)
        discountInfoTotalView.snp.makeConstraints {
            $0.top.equalTo(chargeInfoTotalView.snp.bottom)
            $0.height.equalTo(132)
        }
        
        let lineView = self.createLineView(color: Colors.backgroundTertiary.color)
        discountInfoTotalView.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(4)
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
        
        let lineView2 = self.createLineView(color: Colors.backgroundTertiary.color)
        berryInfoTotalView.addSubview(lineView2)
        lineView2.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(4)
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
            $0.top.equalTo(myBerryUseTitleLbl.snp.bottom).offset(16)
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
        
        berryInfoMarginTotalView.addSubview(alwaysUseBerryTotalBtn)
        alwaysUseBerryTotalBtn.snp.makeConstraints {
            $0.leading.equalTo(alwaysUseBerryGuideLbl.snp.leading)
            $0.trailing.equalTo(alwaysUseBerryBtn.snp.trailing)
            $0.height.equalTo(44)
        }
        
        totalStackView.addArrangedSubview(paymentInfoTotalView)
        paymentInfoTotalView.snp.makeConstraints {
            $0.top.equalTo(berryInfoTotalView.snp.bottom)
            $0.bottom.equalToSuperview()
        }
        
        let lineView3 = self.createLineView(color: Colors.backgroundTertiary.color)
        paymentInfoTotalView.addSubview(lineView3)
        lineView3.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(4)
        }
        
        paymentInfoTotalView.addSubview(paymentInfoMarginTotalView)
        paymentInfoMarginTotalView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(-40)
        }
        
        paymentInfoMarginTotalView.addSubview(paymentMainTitleLbl)
        paymentMainTitleLbl.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        paymentInfoMarginTotalView.addSubview(currentAmountTotalView)
        currentAmountTotalView.snp.makeConstraints {
            $0.top.equalTo(paymentMainTitleLbl.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        currentAmountTotalView.addSubview(currentAmountTitleLbl)
        currentAmountTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        currentAmountTotalView.addSubview(currentAmountLbl)
        currentAmountLbl.snp.makeConstraints {
            $0.centerY.equalTo(currentAmountTitleLbl.snp.centerY)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        let paymentLineView = self.createLineView(color: Colors.backgroundTertiary.color)
        currentAmountTotalView.addSubview(paymentLineView)
        paymentLineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        paymentInfoMarginTotalView.addSubview(discountEventResultTotalView)
        discountEventResultTotalView.snp.makeConstraints {
            $0.top.equalTo(currentAmountTotalView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        discountEventResultTotalView.addSubview(discountEventResultTitleLbl)
        discountEventResultTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        discountEventResultTotalView.addSubview(discountEventResultNameLbl)
        discountEventResultNameLbl.snp.makeConstraints {
            $0.centerY.equalTo(discountEventResultTitleLbl.snp.centerY)
            $0.leading.equalTo(discountEventResultTitleLbl.snp.trailing)
            $0.height.equalTo(16)
        }
        
        discountEventResultTotalView.addSubview(discountEventResultAmountLbl)
        discountEventResultAmountLbl.snp.makeConstraints {
            $0.centerY.equalTo(discountEventResultNameLbl.snp.centerY)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        let paymentLineView2 = self.createLineView(color: Colors.backgroundTertiary.color)
        discountEventResultTotalView.addSubview(paymentLineView2)
        paymentLineView2.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
                        
        paymentInfoMarginTotalView.addSubview(useBerryTotalView)
        useBerryTotalView.snp.makeConstraints {
            $0.top.equalTo(discountEventResultTotalView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        useBerryTotalView.addSubview(useBerryTitleLbl)
        useBerryTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        useBerryTotalView.addSubview(useBerryLbl)
        useBerryLbl.snp.makeConstraints {
            $0.centerY.equalTo(useBerryTitleLbl.snp.centerY)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        let paymentLineView3 = self.createLineView(color: Colors.backgroundTertiary.color)
        useBerryTotalView.addSubview(paymentLineView3)
        paymentLineView3.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        paymentInfoMarginTotalView.addSubview(estimatedTitleLbl)
        estimatedTitleLbl.snp.makeConstraints {
            $0.top.equalTo(useBerryTotalView.snp.bottom).offset(32)
            $0.leading.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        paymentInfoMarginTotalView.addSubview(estimatedWonLbl)
        estimatedWonLbl.snp.makeConstraints {
            $0.centerY.equalTo(estimatedTitleLbl.snp.centerY)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        paymentInfoMarginTotalView.addSubview(estimatedLbl)
        estimatedLbl.snp.makeConstraints {
            $0.centerY.equalTo(estimatedTitleLbl.snp.centerY)
            $0.trailing.equalTo(estimatedWonLbl.snp.leading).offset(-4)
            $0.height.equalTo(20)
        }
        
        paymentInfoMarginTotalView.addSubview(userWarringLbl)
        userWarringLbl.snp.makeConstraints {
            $0.top.equalTo(estimatedTitleLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(32)
            $0.bottom.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviTotalView.backClosure = {
            GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
        }
        
        let tapTouch = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        totalStackView.addGestureRecognizer(tapTouch)
                
        NotificationCenter.default.addObserver(self, selector: #selector(requestStatusFromFCM), name: Notification.Name(FCMManager.FCM_REQUEST_PAYMENT_STATUS), object: nil)
        
        alwaysUseBerryBtn.rx.tap
            .asDriver()
            .drive(with: self) { obj,_ in
                var preUsePoint = obj.willUsePoint
                if obj.alwaysUseBerryBtn.isSelected {
                    preUsePoint = obj.prevAlwaysUsePoint
                }
                
                Server.setUsePoint(usePoint: preUsePoint, useNow: false) { [weak self]
                    (isSuccess, value) in
                    guard let self = self else { return }
                    let json = JSON(value)
                    self.responseSetUsePoint(response: json)
                }
            }
            .disposed(by: self.disposeBag)
        
        berryUseAllBtn.rx.tap
            .asDriver()
            .drive(with: self) { obj, _ in
                obj.berryUseTf.text = "\(obj.myPoint)"
                obj.savePoint(point: obj.myPoint)
            }
            .disposed(by: self.disposeBag)
        
        nextBtn.rx.tap
            .asDriver()
            .drive(with: self) { obj, _ in
                obj.showStopChargingDialog()
            }
            .disposed(by: self.disposeBag)
        
        requestOpenCharger()
        requestPointInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startTimer(tick: TIMER_COUNT_NORMAL_TICK)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeTimer()
        chargeElapsedTimeGuideLbl.stop()

        removeNotificationCenter()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(reactor: PaymentStatusReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    internal func bind(reactor: PaymentStatusReactor) {
            
    }
    
    // MARK: FUNC
    
    private func showStopChargingDialog() {
        var title = "충전 종료 및 결제하기"
        var msg = "확인 버튼을 누르면 충전이 종료됩니다."
        if chargingStatus.status == STATUS_READY {
            title = "충전 취소"
            msg = "확인 버튼을 누르면 충전이 취소됩니다."
        }
    
        let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in
            self.showProgress()

            self.nextBtn.isEnabled = false
            self.nextBtn.setTitle("충전 중지 요청중입니다.", for: .disabled)
            self.nextBtn.setTitleColor(UIColor(rgb: 0x15435C), for: .disabled)
            self.isStopCharging = true
            
            self.requestStopCharging()
        })
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler:{ (ACTION) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        
        var actions = Array<UIAlertAction>()
        actions.append(ok)
        actions.append(cancel)
        UIAlertController.showAlert(title: title, message: msg, actions: actions)
    }
    
    private func requestStopCharging() {
        let chargingId = getChargingId()
        if chargingId.isEmpty {
            Snackbar().show(message: "오류가 발생하였습니다. 충전하기 페이지 종료후 재시도 바랍니다.")
        } else {
            Server.stopCharging(chargingId: chargingId) { (isSuccess, value) in
                self.hideProgress()
                if isSuccess {
                    self.responseStop(response: JSON(value))
                } else {
                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 충전하기 페이지 종료후 재시도 바랍니다.")
                }
            }
        }
    }
    
    private func responseStop(response: JSON) {
        if response.isEmpty {
            return
        }
        switch (response["code"].stringValue) {
        case "1000":
            startTimer(tick: TIMER_COUNT_COMPLETE_TICK)
            
        case "2003": // CHARGING_CANCEL 충전 하기전에 취소
            Snackbar().show(message: "충전을 취소하였습니다.")
            GlobalDefine.shared.mainNavi?.pop()

        default:
            Snackbar().show(message:response["msg"].stringValue)
        }
    }
    
    private func responseUsePoint(response: JSON) {
        if response.isEmpty {
            return
        }
        if response["code"].stringValue == "1000" {
            let point = response["point"].stringValue
            willUsePoint = Int(point as String)!
            updateBerryUse(point: willUsePoint)
        }
    }
    
    private func startTimer(tick : Int) {
        removeTimer()
        var index = 0
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(tick), repeats: true) { (timer) in
            self.requestChargingStatus()
            index = index + 1
        }
        timer.fire()
    }
    
    private func savePoint(point: Int) {
        if point != willUsePoint && point >= 0 {
            Server.usePoint(point: point) { (isSuccess, value) in
                if isSuccess {
                    let json = JSON(value)
                    self.responseUsePoint(response: json)
                } else {
                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료 후 재시도 바랍니다.")
                }
            }
        }
    }
    
    private func responseSetUsePoint(response: JSON) {
        if response.isEmpty {
            return
        }
        if response["code"].stringValue == "1000" {
            let point = response["use_point"].stringValue
            alwaysUsePoint = Int(point as String)!
            updateBerryUse(point: willUsePoint)
        }
    }
    
    private func removeNotificationCenter() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: Notification.Name(FCMManager.FCM_REQUEST_PAYMENT_STATUS), object: nil)
    }
    
    private func stopCharging() {
        removeTimer()
        chargeElapsedTimeGuideLbl.stop()
                        
        let viewcon = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(ofType: PaymentResultViewController.self)
        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
    }
    
    private func removeTimer() {
        timer.invalidate()
        timer = Timer()
    }
    
    private func updateBerryUse(point: Int) {
        if point == myPoint {
            berryUseAllBtn.backgroundColor = Colors.backgroundDisabled.color
            berryUseAllBtn.setTitleColor(Colors.contentDisabled.color, for: .normal)
        } else {
            berryUseAllBtn.backgroundColor = Colors.backgroundSecondary.color
            berryUseAllBtn.setTitleColor(Colors.contentPrimary.color, for: .normal)
        }
        
        myBerryUseLbl.text = "\(String(point).currency()) 베리"
        if point != alwaysUsePoint { // 설정베리와 사용베리가 다른경우
            alwaysUseBerryGuideLbl.textColor = Colors.contentPrimary.color
            alwaysUseBerryBtn.isSelected = false
            alwaysUseBerryTotalBtn.isUserInteractionEnabled = true
        } else {
            if alwaysUsePoint == prevAlwaysUsePoint { // 설정베리가 변경된적 없는 경우
                alwaysUseBerryGuideLbl.textColor = Colors.contentTertiary.color
                alwaysUseBerryTotalBtn.isUserInteractionEnabled = false
                
                if prevAlwaysUsePoint == 0 {
                    alwaysUseBerryBtn.isSelected = false
                } else {
                    alwaysUseBerryBtn.isSelected = true
                }
            } else { // 설정베리가 변경되어 사용베리와 다른 경우
                alwaysUseBerryGuideLbl.textColor = Colors.contentPrimary.color
                alwaysUseBerryBtn.isSelected = true
                alwaysUseBerryTotalBtn.isUserInteractionEnabled = true
            }
        }
    }
    
    private func requestPointInfo() {
        Server.getPoint() { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json.isEmpty {
                    return
                }
                switch (json["code"].stringValue) {
                case "1000":
                    var totalPoint = json["point"].intValue
                    var usePoint = json["use_point"].intValue
                    if totalPoint < 0 {
                        totalPoint = 0
                    }
                    self.myPoint = totalPoint
                    self.myBerryHoldTitleLbl.text = "\(String(totalPoint).currency()) 베리"
                    
                    if usePoint < 0 {
                        usePoint = self.myPoint
                    }
                    self.willUsePoint = usePoint
                    self.alwaysUsePoint = usePoint
                    self.prevAlwaysUsePoint = usePoint
                    
                    self.updateBerryUse(point: self.willUsePoint)
                    
                default:
                    Snackbar().show(message:json["msg"].stringValue)
                }
            }
        }
    }
    
    // charging id가 있을 경우 충전중인 상태이므로
    // charging id가 없을 경우에만 충전기에 충전 시작을 요청함
    private func requestOpenCharger() {
        let chargingId = getChargingId()
        if chargingId.isEmpty {
            showProgress()
            chargeStatusLbl.text = "충전 요청중"
            chargeStatusSubLbl.text = "충전 요청중 입니다.\n잠시만 기다려 주세요."
            Server.openCharger(cpId: cpId, connectorId: connectorId) { (isSuccess, value) in
                self.hideProgress()
                if isSuccess {
                    let json = JSON(value)
                    self.responseOpenCharger(response: json)
                } else {
                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 충전하기 페이지 종료후 재시도 바랍니다.")
                }
            }
        }
    }
    
    private func responseOpenCharger(response: JSON) {
        if response.isEmpty {
            return
        }
        switch (response["code"].stringValue) {
        case "1000":
            chargeStatusSubLbl.text = "충전 커넥터를 차량과 연결 후\n잠시만 기다려 주세요 "
            setChargingId(chargerId: response["charging_id"].stringValue)
        default:
            Snackbar().show(message:response["msg"].stringValue)
        }
    }
    
    private func setChargingId(chargerId: String) {
        UserDefault().saveString(key: UserDefault.Key.CHARGING_ID, value: chargerId)
    }
    
    @objc private  func requestStatusFromFCM(notification: Notification) {
        if let userInfo = notification.userInfo {
            let cmd = userInfo[AnyHashable("cmd")] as! String
            if cmd == "charging_end" {
                self.stopCharging()
            } else {
                let delayTime = DispatchTime.now() + .seconds(1)
                DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                    self.requestChargingStatus()
                })
            }
        }
    }
    
    private func requestChargingStatus() {
        let chargingId = getChargingId()
        if !chargingId.isEmpty {
            Server.getChargingStatus(chargingId: chargingId) { (isSuccess, value) in
                self.hideProgress()
                if isSuccess {
                    self.responseChargingStatus(response: JSON(value))
                } else {
                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 충전하기 페이지 종료후 재시도 바랍니다.")
                }
            }
        }
    }
    
    private func responseChargingStatus(response: JSON) {
        if response.isEmpty {
            return
        }
        updateDataStructAtResponse(response: response)
        
        switch (chargingStatus.resultCode) {
        case 1000:
            if chargingStatus.status == STATUS_FINISH {
                stopCharging()
            } else {
                updateChargingStatus()
            }
            
        case 2002:
            let popupModel = PopupModel(title: "오류 안내",
                                        message: "충전 상태가 없어 화면을 불러올 수 없습니다.\n결제 오류 발생 시 고객센터로 문의주세요.",
                                        confirmBtnTitle: "나가기", cancelBtnTitle: "고객센터 문의하기", confirmBtnAction: {
                GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
            }, cancelBtnAction: {
                guard let number = URL(string: "tel://070-8633-9009") else { return }
                UIApplication.shared.open(number)
            } , textAlignment: .center)
            
            let popup = VerticalConfirmPopupViewController(model: popupModel)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
            })
        
        default: // error
            Snackbar().show(message: chargingStatus.msg ?? "")
        }
    }
    
    private func updateChargingStatus() {
        if let status = chargingStatus.status {
            if status < STATUS_READY || status > STATUS_FINISH {
                return
            }
        }
        
        if let stationName = chargingStatus.stationName {
            stationNameLbl.text = stationName
        }
        
        if let companyId = chargingStatus.companyId {
            // GSC 외에는 충전 중지 할 수 없으므로 충전 중지 버튼 disable
            if companyId.elementsEqual(CompanyInfo.COMPANY_ID_GSC) {
                if isStopCharging == false {
                    nextBtn.isEnabled = true
                    
                    nextBtn.backgroundColor = Colors.backgroundPositive.color
                    nextBtn.setTitleColor(Colors.contentPrimary.color, for: .normal)
                }
            } else if companyId.elementsEqual(CompanyInfo.COMPANY_ID_KEPCO) {
                nextBtn.isUserInteractionEnabled = false
                nextBtn.backgroundColor = Colors.backgroundDisabled.color
                nextBtn.setTitleColor(Colors.contentDisabled.color, for: .normal)
                if MemberManager.shared.isPartnershipClient(clientId: 23) { // 한전&SK -> 포인트사용 block
                    berryInfoTotalView.isHidden = true
                }
            }
        }
        
        if chargingStatus.status == STATUS_READY {
            chargeStatusLbl.text = "충전 대기"
            chargeStatusSubLbl.text = "충전 커넥터를 차량과 연결 후\n잠시만 기다려 주세요"
            nextBtn.setTitle("충전 취소", for: .normal)
        } else {
            chargeStatusLbl.textColor = UIColor(named: "content-positive")
            chargeStatusSubLbl.text = "충전중"
            nextBtn.setTitle("충전 종료 및 결제하기", for: .normal)
                      
            
            // 충전진행시간
            if chargingStartTime.isEmpty || !chargingStartTime.elementsEqual(chargingStatus.startDate ?? "") {
                chargingStartTime = chargingStatus.startDate ?? ""
            }

            if !chargingStartTime.isEmpty {
                chargeElapsedTimeGuideLbl.setBase(base: getChargingStartTime())
                chargeElapsedTimeGuideLbl.start()
            }
            
            // 충전률
            if let chargingRate = Double(chargingStatus.chargingRate ?? "0") {
                if chargingRate > 0.0 {
                    circleView.setRateProgress(progress: Double(chargingRate))
                }
                chargeStatusLbl.text = "\(Int(chargingRate))%"
            }
            
            // 포인트
            var point = 0.0
            if let pointStr = chargingStatus.usedPoint, !pointStr.isEmpty {
                myBerryUseLbl.text = "\(pointStr.currency()) 베리"
                point = Double(pointStr) ?? 0.0
                willUsePoint = Int(point)
                updateBerryUse(point: willUsePoint)
            }
            
            if let chargingKw = chargingStatus.chargingKw {
                // 충전량
                let chargePower = "\(chargingKw)kWh"
                chargePowerLbl.text = chargePower
                
                var discountAmt = 0.0
                if let discountMsg = chargingStatus.discountMsg, !discountMsg.isEmpty {
                    discountEventTitleLbl.text = discountMsg
                    
                    discountAmt = Double(chargingStatus.discountAmt!) ?? 0.0
                    var discountStr = chargingStatus.discountAmt!.currency()
                    if discountAmt != 0 {
                        discountStr = "- " + discountStr
                    }
                    discountLbl.text = "\(discountStr) 원"
                    discountEventResultAmountLbl.text = "\(discountStr) 원"
                    discountEventResultNameLbl.text = discountMsg
                } else {
                    discountInfoTotalView.isHidden = true
                    discountEventResultTotalView.isHidden = true
                }
                
                if let feeStr = chargingStatus.fee {
                    // 충전 요금
                    currentAmountLbl.text = feeStr.currency() + " 원"
                    
                    // 총 결제 금액
                    let fee = feeStr.parseDouble() ?? 0.0
                    var totalFee = (fee > discountAmt) ? fee - discountAmt : 0
                    point = Double((willUsePoint > myPoint) ? myPoint : willUsePoint)
                    if totalFee > point {
                        totalFee -= point
                    } else {
                        point = totalFee
                        totalFee = 0
                    }
                    estimatedLbl.text = String(totalFee).currency()
                    var berryStr = String(point).currency()
                    if point != 0 {
                        berryStr = "- " + berryStr
                    }
                    useBerryLbl.text = "\(berryStr) 베리"
                }
                
                // 충전속도
                if let updateTime = chargingStatus.updateTime {
                    if (!preChargingKw.isEmpty && !preUpdateTime.isEmpty && !preUpdateTime.elementsEqual(updateTime)) {
                        // 시간차이 계산. 충전량 계산. 속도 계산
                        let preDate = Date().toDate(data: preUpdateTime)
                        let updateDate = Date().toDate(data: updateTime)
                        let sec = Double(updateDate?.timeIntervalSince(preDate!) ?? 0)

                        // 충전량 계산
                        let chargingKw = chargingKw.parseDouble()! - self.preChargingKw.parseDouble()!

                        // 속도 계산: 충전량 / 시간 * 3600
                        if (sec > 0 && chargingKw > 0) {
                            let speed = chargingKw / sec * 3600
                            self.chargeSpeedLbl.text = "\((speed * 100).rounded() / 100) Kw"
                        }
                    }
                    preChargingKw = chargingStatus.chargingKw ?? preChargingKw
                    preUpdateTime = chargingStatus.updateTime ?? preUpdateTime
                }
            }
        }
    }
    
    private func getChargingStartTime() -> Double {
        let date = Date().toDate(data: chargingStartTime)
        return Double(date!.timeIntervalSince1970)
    }
    
    private func updateDataStructAtResponse(response: JSON) {
        chargingStatus.resultCode = response["code"].int ?? 9000
        chargingStatus.status = response["status"].int ?? STATUS_READY
        chargingStatus.cpId = response["cp_id"].string ?? ""
        chargingStatus.startDate = response["s_date"].string ?? ""
        chargingStatus.updateTime = response["u_date"].string ?? ""
        chargingStatus.chargingRate = response["rate"].string ?? "0"
        chargingStatus.chargingKw = response["c_kw"].string ?? "0"
        chargingStatus.usedPoint = response["u_point"].string ?? ""
        chargingStatus.fee = response["fee"].string ?? ""
        chargingStatus.stationName = response["snm"].string ?? ""
        chargingStatus.companyId = response["company_id"].string ?? ""
        chargingStatus.discountAmt = response["discount_amt"].string ?? ""
        chargingStatus.discountMsg = response["discount_msg"].string ?? ""
    }
    
    private func getChargingId() -> String {
        return UserDefault().readString(key: UserDefault.Key.CHARGING_ID)
    }
    
    @objc
    fileprivate func handleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    private func showProgress() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideProgress() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}

extension NewPaymentStatusViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length > 5 {
            textField.IBborderColor = Colors.contentNegative.color
            Snackbar().show(message: "베리 입력은 100,000원을 초과하여 입력하실 수 없습니다.")
            return false
        }
        
        textField.IBborderColor = Colors.borderOpaque.color
        if newString.length > 0 {
            if let point = Int(newString as String) {
                if point > myPoint { // 내가 보유한 포인트보다 큰 수를 입력한 경우 내 포인트를 입력
                    textField.IBborderColor = Colors.contentNegative.color
                    Snackbar().show(message: "사용 베리는 보유 베리보다 많이 입력할 수 없습니다.")
                    return false
                } else {
                    textField.IBborderColor = Colors.contentPrimary.color
                    if newString.hasPrefix("0"){
                        textField.text = String(point)
                        return false
                    }
                    return true
                }
            } else {
                return false // 숫자 이외의 문자 입력받지 않음
            }
        }
        return true
    }
}

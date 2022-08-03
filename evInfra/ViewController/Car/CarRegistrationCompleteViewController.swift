//
//  CarRegistrationCompleteViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/15.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import UIKit
import SwiftyJSON

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
        $0.IBcornerRadius = 10
        $0.backgroundColor = Colors.backgroundSecondary.color
    }
    
    private lazy var regDateTotalViewTriangleImgView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Icons.iconBallonTriangle.image
    }
    
    private lazy var regDateMainTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.contentPrimary.color
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private lazy var registerDateTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.contentPrimary.color
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textAlignment = .center
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
    
    private lazy var basicInfoLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.contentDisabled.color
        $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        $0.text = "내 차 기본 제원"
    }
    
    private lazy var carBasicInfoTotalStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 16
        $0.backgroundColor = .white
    }
    
    private lazy var nextBtn = RectButton(level: .primary).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("EV Infra 시작하기", for: .normal)
        $0.setTitle("EV Infra 시작하기", for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.isEnabled = true
    }
    
    private lazy var deleteCarInfoLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.text = "차량 정보 삭제하기"
        $0.textAlignment = .center
        $0.textColor = Colors.contentTertiary.color
        $0.backgroundColor = .clear
        $0.setUnderline()
    }
    
    private lazy var deleteCarInfoBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
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
        
        self.contentView.addSubview(deleteCarInfoLbl)
        deleteCarInfoLbl.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        self.contentView.addSubview(deleteCarInfoBtn)
        deleteCarInfoBtn.snp.makeConstraints {
            $0.center.equalTo(deleteCarInfoLbl.snp.center)
            $0.width.equalTo(deleteCarInfoLbl.snp.width)
            $0.height.equalTo(deleteCarInfoLbl.snp.height)
        }
                
        self.contentView.addSubview(nextBtn)
        nextBtn.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        self.contentView.addSubview(totalScrollView)
        totalScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom)
            $0.width.equalTo(screenWidth)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nextBtn.snp.top)
        }
        
        totalScrollView.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().offset(24)
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
            $0.height.greaterThanOrEqualTo(64)
        }
        
        totalView.addSubview(regDateTotalViewTriangleImgView)
        regDateTotalViewTriangleImgView.snp.makeConstraints {
            $0.top.equalTo(regDateTotalView.snp.bottom).offset(-1)
            $0.width.equalTo(22)
            $0.height.equalTo(15)
            $0.centerX.equalToSuperview()
        }
        
        regDateTotalView.addSubview(regDateMainTitleLbl)
        regDateMainTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().offset(-4)
            $0.height.equalTo(16)
        }
        
        regDateTotalView.addSubview(registerDateTitleLbl)
        registerDateTitleLbl.snp.makeConstraints {
            $0.top.equalTo(regDateMainTitleLbl.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().offset(-4)
            $0.height.equalTo(16)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        
        totalView.addSubview(carNumberTotalView)
        carNumberTotalView.snp.makeConstraints {
            $0.top.equalTo(regDateTotalViewTriangleImgView.snp.bottom).offset(16)
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
            $0.top.equalTo(carMakeCompanyLbl.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(64)
        }
        
        let lineView = self.createLineView()
        totalView.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.top.equalTo(carInfoTotalStackView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(6)
        }
        
        totalView.addSubview(basicInfoLbl)
        basicInfoLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(lineView.snp.bottom).offset(24)
            $0.height.equalTo(16)
        }
        
        totalView.addSubview(carBasicInfoTotalStackView)
        carBasicInfoTotalStackView.snp.makeConstraints {
            $0.top.equalTo(basicInfoLbl.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-19)
            $0.bottom.greaterThanOrEqualToSuperview().offset(-30)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        naviTotalView.backClosure = {
            guard let _reactor = self.reactor else { return }
            
            switch _reactor.fromViewType {
            case .mypage:
                if let _mainNav = GlobalDefine.shared.mainNavi {
                    let _viewControllers = _mainNav.viewControllers
                    for vc in _viewControllers.reversed() {
                        if let _vc = vc as? NewMyPageViewController {
                            _ = _mainNav.popToViewController(_vc, animated: false)
                            return
                        }
                    }
                }
                
            case .signup:
                GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
                
            }
        }
        
        nextBtn.rx.tap
            .asDriver()
            .drive(onNext: {
                GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
    
    internal func bind(reactor: CarRegistrationCompleteReactor) {
        nextBtn.isHidden = reactor.fromViewType == .mypage
        deleteCarInfoLbl.isHidden = reactor.fromViewType == .signup
        deleteCarInfoBtn.isHidden = reactor.fromViewType == .signup
                        
        reactor.state.compactMap { $0.carInfoModel }
            .asDriver(onErrorJustReturn: CarInfoModel(JSON.null))
            .drive(onNext: { [weak self] carInfoModel in
                guard let self = self else { return }
                
                let startDate = carInfoModel.dpYes.regDate.toDate(dateFormat: "yyyy-MM-dd") ?? Date()
                let endDate = Date()
                let calendar = Calendar.current
                let dateGap = calendar.dateComponents([.year , .month , .day], from: startDate , to: endDate)

                if case let (y? , m? , d?) = (dateGap.year , dateGap.month , dateGap.day) {
                    let yearStr = y == 0 ? "":"\(y)년"
                    let monthStr = m == 0 ? "":"\(m)개월"
                    let dayStr = d == 0 ? "":"\(d)일째"
                    let strJoin = "\(yearStr) \(monthStr) \(dayStr)"
                    self.regDateMainTitleLbl.text = "\(carInfoModel.dpYes.mdSep)와 함께 한지 ⚡\(strJoin)⚡️에요!"
                }
                                
                self.registerDateTitleLbl.text = "최초등록일 \(carInfoModel.dpYes.regDate)"
                self.carNumberLbl.text = carInfoModel.carNum
                self.carImgView.sd_setImage(with: URL(string: "\(carInfoModel.dpYes.img)"), placeholderImage: Icons.iconMypageCarEmpty.image)
                self.carMakeCompanyTitleLbl.text = carInfoModel.dpYes.cmpy
                self.carMakeCompanyLbl.text = "\(carInfoModel.dpYes.mdSep) \(carInfoModel.series.s1.name)"
                                
                
                for carInfoType in CarInfoType.allCases {
                    let carInfoView: UIView
                    switch carInfoType {
                    case .cpcty:
                        carInfoView = self.createCarInfoTypeView(type: carInfoType, typeValue: carInfoModel.dpYes.cpcty)
                        
                    case .btrycpcty:
                        carInfoView = self.createCarInfoTypeView(type: carInfoType, typeValue: carInfoModel.dpYes.btryCpcty)
                        
                    case .drvcpcty:
                        carInfoView = self.createCarInfoTypeView(type: carInfoType, typeValue: carInfoModel.dpNo.drvCpcty)
                    }
                    self.carInfoTotalStackView.addArrangedSubview(carInfoView)
                }
                
                for carBasicInfoType in CarBasicInfoType.allCases {
                    let carBasicInfoView: UIView
                    switch carBasicInfoType {
                    case .pwrMax:
                        carBasicInfoView = self.createCarBasicInfoTypeView(type: carBasicInfoType, typeValue: carInfoModel.dpYes.pwrMax)
                        
                    case .carSep:
                        carBasicInfoView = self.createCarBasicInfoTypeView(type: carBasicInfoType, typeValue: carInfoModel.dpYes.carSep)
                        
                    case .brthY:
                        carBasicInfoView = self.createCarBasicInfoTypeView(type: carBasicInfoType, typeValue: carInfoModel.dpYes.brthY)
                    }
                    self.carBasicInfoTotalStackView.addArrangedSubview(carBasicInfoView)
                }
                
            })
            .disposed(by: self.disposeBag)
        
        
        deleteCarInfoBtn.rx.tap
            .asDriver()
            .drive(onNext: {  _ in
                let popupModel = PopupModel(title: "\(reactor.currentState.carInfoModel.dpYes.mdSep)를(을) 삭제하시겠어요?",
                                            message: "차량 삭제 시, 이 차량의 설정이\n모두 삭제됩니다. 정말 삭제하시겠어요?",
                                            confirmBtnTitle: "삭제하기", cancelBtnTitle: "취소", confirmBtnAction: {
                    Observable.just(CarRegistrationCompleteReactor.Action.deleteCarInfo)
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
    
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    private func createCarInfoTypeView(type: CarInfoType, typeValue: String) -> UIView {
        let typeValue = typeValue.isEmpty ? "-" : typeValue
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
            $0.text = "\(typeValue)\(type.typeUnit)"
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
            $0.text = "\(type.typeDesc)"
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
    
    private func createCarBasicInfoTypeView(type: CarBasicInfoType, typeValue: String) -> UIView {
        let typeValue = typeValue.isEmpty ? "-" : typeValue
        let view = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
        }
        
        let imgView = UIImageView().then {
            $0.image = type.icon
            $0.tintColor = Colors.contentSecondary.color
        }
        
        view.addSubview(imgView)
        imgView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.height.width.equalTo(20)
        }
                                  
        let typeDescLbl = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textAlignment = .left
            $0.numberOfLines = 1
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = Colors.contentPrimary.color
            $0.text = type.typeDesc
        }
        
        view.addSubview(typeDescLbl)
        typeDescLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(1)
            $0.leading.equalTo(imgView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-12)
            $0.height.equalTo(16)
            $0.bottom.equalToSuperview().offset(-3)
        }
        
        let typeUnitLbl = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textAlignment = .right
            $0.numberOfLines = 1
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = Colors.contentPrimary.color
            $0.text = "\(typeValue)\(type.typeUnit)"
        }
        
        view.addSubview(typeUnitLbl)
        typeUnitLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(1)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(16)
            $0.bottom.equalToSuperview().offset(-3)
        }
                                        
        return view
    }
}

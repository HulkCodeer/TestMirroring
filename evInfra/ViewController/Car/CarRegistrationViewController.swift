//
//  CarRegistrationViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/07/14.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import UIKit

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
        $0.numberOfLines = 2
    }
    
    private lazy var subTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentSecondary.color
        $0.textAlignment = .natural
        $0.text = "내 전기차 번호를 등록해보세요. "
        $0.numberOfLines = 1
    }
    
    private lazy var carNumberLookUpTf = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.IBborderColor = Colors.borderOpaque.color
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
        $0.keyboardType = .default
        $0.returnKeyType = .default
        $0.addLeftPadding(padding: 16)
    }
    
    private lazy var registerNoticeLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.contentTertiary.color
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.text = "등록 주의사항"
    }
    
    private lazy var noticeTotalStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 0
        $0.backgroundColor = .white
    }
    
    private lazy var carOwnerRegisterStepScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.isHidden = false
    }
    
    private lazy var carOwnerRegisterStepTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var ownerMainTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 2
        $0.text = "이제, 차량 소유자만 입력하면\n등록이 완료돼요!"
    }
    
    private lazy var ownerTf = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.IBborderColor = Colors.borderOpaque.color
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
        $0.keyboardType = .default
        $0.returnKeyType = .default
        $0.addLeftPadding(padding: 16)
        $0.placeholder = "소유자명"
    }
    
    private lazy var ownerRegisterNoticeLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.contentTertiary.color
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.text = "등록 주의사항"
    }
    
    private lazy var ownerNoticeTotalStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 0
        $0.backgroundColor = .white
    }
    
    private lazy var carInqueryProgressBarTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var circleProgressBarView: CircularProgressBarView = CircularProgressBarView(frame: .zero)
    
    private lazy var lodingMainGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.contentPrimary.color
        $0.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        $0.text = "차량 정보를 불러오고 있어요"
        $0.textAlignment = .center
    }
    
    private lazy var lodingSubGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.contentTertiary.color
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.text = "3~10초정도 걸릴 수 있어요"
        $0.textAlignment = .center
    }
                    
    private lazy var nextBtn = RectButton(level: .primary).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("다음으로", for: .normal)
        $0.setTitle("다음으로", for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.isEnabled = true
    }
    
    // MARK: VARIABLE
        
    private let noticeInfoArray: [String] = [
        "∙ 전기차가 아닌 차량은 등록할 수 없어요.",
        "∙ 법인/리스 차량은 등록이 어려워요.",
        "∙ 차량 출고 및 등록 당일은 정보 조회가 안될 수 있어요."
    ]
    
    private let ownerNoticeInfoArray: [String] = [
        "∙ 공동명의 차량인 경우\n  대표 소유자명으로 입력해주세요.",
        "∙ 전기차가 아닌 차량은 등록할 수 없어요. ",
        "∙ 법인/리스 차량은 등록이 어려워요.",
        "∙ 차량 출고 및 등록 당일은 정보 조회가 안될 수 있어요."
    ]
    
    private var circleViewDuration: TimeInterval = 2
            
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
            $0.top.leading.trailing.equalToSuperview()
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
            $0.top.equalTo(subTitleLbl.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        carRegisterStepTotalView.addSubview(registerNoticeLbl)
        registerNoticeLbl.snp.makeConstraints {
            $0.top.equalTo(carNumberLookUpTf.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
        }
        
        carRegisterStepTotalView.addSubview(noticeTotalStackView)
        noticeTotalStackView.snp.makeConstraints {
            $0.top.equalTo(registerNoticeLbl.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.greaterThanOrEqualToSuperview().offset(-30)
        }
        
        for noticeInfo in noticeInfoArray {
            noticeTotalStackView.addArrangedSubview(self.createNoticeView(noticeDesc: noticeInfo))
        }
                      
        // 차량 소유자 등록 화면
        self.contentView.addSubview(carOwnerRegisterStepScrollView)
        carOwnerRegisterStepScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom).offset(24)
            $0.width.equalTo(screenWidth)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nextBtn.snp.top)
        }

        carOwnerRegisterStepScrollView.addSubview(carOwnerRegisterStepTotalView)
        carOwnerRegisterStepTotalView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(screenWidth - 32)
            $0.centerX.equalToSuperview()
        }
        
        carOwnerRegisterStepTotalView.addSubview(ownerMainTitleLbl)
        ownerMainTitleLbl.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        carOwnerRegisterStepTotalView.addSubview(ownerTf)
        ownerTf.snp.makeConstraints {
            $0.top.equalTo(ownerMainTitleLbl.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        carOwnerRegisterStepTotalView.addSubview(ownerRegisterNoticeLbl)
        ownerRegisterNoticeLbl.snp.makeConstraints {
            $0.top.equalTo(ownerTf.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
        }
        
        carOwnerRegisterStepTotalView.addSubview(ownerNoticeTotalStackView)
        ownerNoticeTotalStackView.snp.makeConstraints {
            $0.top.equalTo(ownerRegisterNoticeLbl.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.greaterThanOrEqualToSuperview().offset(-30)
        }
        
        
        for noticeInfo in ownerNoticeInfoArray {
            ownerNoticeTotalStackView.addArrangedSubview(self.createNoticeView(noticeDesc: noticeInfo))
        }
        
        self.contentView.addSubview(carInqueryProgressBarTotalView)
        carInqueryProgressBarTotalView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
                        
        carInqueryProgressBarTotalView.addSubview(lodingMainGuideLbl)
        lodingMainGuideLbl.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        carInqueryProgressBarTotalView.addSubview(lodingSubGuideLbl)
        lodingSubGuideLbl.snp.makeConstraints {
            $0.top.equalTo(lodingMainGuideLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.greaterThanOrEqualToSuperview().offset(-30)
            $0.height.equalTo(24)
        }
        
//        carInqueryProgressBarTotalView.addSubview(circleProgressBarView)
//        circleProgressBarView.snp.makeConstraints {
//            $0.bottom.equalTo(lodingMainGuideLbl.snp.top).offset(80)
//            $0.width.height.equalTo(40)
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainTitleLbl.text = "반가워요! \(MemberManager.shared.memberNickName)님 😊\n차량에 맞는 전기차 충전소를 찾아드릴게요."
    }
    
    internal func bind(reactor: CarRegistrationReactor) {
        nextBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                Observable.just(CarRegistrationReactor.Action.moveNextView)
                    .bind(to: reactor.action)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.nextViewType }
            .asDriver(onErrorJustReturn: .none)
            .drive(onNext: { [weak self] viewType in
                guard let self = self else { return }
                
                self.carRegisterStepScrollView.isHidden = viewType != .carRegister
                self.carOwnerRegisterStepScrollView.isHidden = viewType != .owner
                self.carInqueryProgressBarTotalView.isHidden = viewType != .carInquery
                
                if viewType == .carInquery {
                    self.circleProgressBarView.progressAnimation(duration: self.circleViewDuration)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func createNoticeView(noticeDesc: String) -> UILabel {
        return UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = noticeDesc
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = Colors.contentTertiary.color
            $0.numberOfLines = 2
        }
    }
}

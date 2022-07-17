//
//  SignUpSecondStepViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/07/14.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import UIKit

internal final class SignUpUserMoreInfoStepViewController: CommonBaseViewController, StoryboardView {

    // MARK: UI
    
    private lazy var totalScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.isHidden = false
    }
    
    private lazy var totalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var mainTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.text = "EV Infra 내에서 사용될\n정보를 입력해주세요."
        $0.numberOfLines = 2
    }
    
    private lazy var loginInfoGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentSecondary.color
        $0.textAlignment = .natural
        $0.text = ""
        $0.numberOfLines = 1
    }
            
    private lazy var requiredGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        let tempText = "*은 필수항목 입니다."
        let attributeText = NSMutableAttributedString(string: tempText)
        let allRange = NSMakeRange(0, attributeText.length)
        attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.contentSecondary.color], range: allRange)
        attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular)], range: allRange)
        var chageRange = (attributeText.string as NSString).range(of: "*")
        attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.backgroundPositive.color], range: chageRange)
        attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], range: chageRange)
        $0.attributedText = attributeText
        $0.numberOfLines = 1
    }
    
    private lazy var ageGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        let tempText = "연령대*"
        let attributeText = NSMutableAttributedString(string: tempText)
        let allRange = NSMakeRange(0, attributeText.length)
        attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.contentPrimary.color], range: allRange)
        attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)], range: allRange)
        var chageRange = (attributeText.string as NSString).range(of: "*")
        attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.backgroundPositive.color], range: chageRange)
        attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], range: chageRange)
        $0.attributedText = attributeText
        $0.numberOfLines = 1
    }
    
    private lazy var selectBoxTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.IBborderColor = Colors.borderOpaque.color
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
    }
    
    private lazy var selectBoxTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.text = "20대"
        $0.numberOfLines = 1
    }
    
    private lazy var selectBoxArrow = ChevronArrow.init(.size24(.down)).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.IBimageColor = Colors.contentPrimary.color
    }
    
    private lazy var selectBoxTotalBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var genderGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        let tempText = "성별*"
        let attributeText = NSMutableAttributedString(string: tempText)
        let allRange = NSMakeRange(0, attributeText.length)
        attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.contentPrimary.color], range: allRange)
        attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)], range: allRange)
        var chageRange = (attributeText.string as NSString).range(of: "*")
        attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.backgroundPositive.color], range: chageRange)
        attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], range: chageRange)
        $0.attributedText = attributeText
        $0.numberOfLines = 1
    }
    
    private lazy var genderTotalStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.spacing = 26
        $0.backgroundColor = .white
    }
    
    // MARK: VARIABLE
    
    private var genderRadioArr: [Radio] = []
    
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
//        self.contentView.addSubview(totalView)
//        totalView.snp.makeConstraints {
//            $0.top.equalToSuperview()
//            $0.leading.equalToSuperview().offset(16)
//            $0.trailing.equalToSuperview().offset(-16)
//            $0.bottom.equalToSuperview()
//        }
//
//        totalView.addSubview(mainTitleLbl)
//        mainTitleLbl.snp.makeConstraints {
//            $0.leading.top.trailing.equalToSuperview()
//            $0.height.equalTo(54)
//        }
//
//        totalView.addSubview(loginInfoGuideLbl)
//        loginInfoGuideLbl.snp.makeConstraints {
//            $0.top.equalTo(mainTitleLbl.snp.bottom).offset(8)
//            $0.leading.equalToSuperview()
//            $0.height.equalTo(41)
//        }
//
//        totalView.addSubview(requiredGuideLbl)
//        requiredGuideLbl.snp.makeConstraints {
//            $0.top.equalTo(loginInfoGuideLbl.snp.bottom).offset(4)
//            $0.leading.equalToSuperview()
//            $0.height.equalTo(16)
//        }
//
//        totalView.addSubview(ageGuideLbl)
//        ageGuideLbl.snp.makeConstraints {
//            $0.top.equalTo(requiredGuideLbl.snp.bottom).offset(24)
//            $0.leading.trailing.equalToSuperview()
//            $0.height.equalTo(20)
//        }
//
//        totalView.addSubview(selectBoxTotalView)
//        selectBoxTotalView.snp.makeConstraints {
//            $0.top.equalTo(ageGuideLbl.snp.bottom).offset(8)
//            $0.leading.trailing.equalToSuperview()
//            $0.height.equalTo(48)
//            $0.bottom.equalToSuperview()
//        }
//
//        selectBoxTotalView.addSubview(selectBoxTitleLbl)
//        selectBoxTitleLbl.snp.makeConstraints {
//            $0.leading.equalToSuperview().offset(16)
//            $0.centerY.equalToSuperview()
//        }
//
//        selectBoxTotalView.addSubview(selectBoxArrow)
//        selectBoxArrow.snp.makeConstraints {
//            $0.trailing.equalToSuperview().offset(-16)
//            $0.centerY.equalToSuperview()
//            $0.width.height.equalTo(24)
//        }
//
//        selectBoxTotalView.addSubview(selectBoxTotalBtn)
//        selectBoxTotalBtn.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
//
//        totalView.addSubview(genderGuideLbl)
//        genderGuideLbl.snp.makeConstraints {
//            $0.top.equalTo(selectBoxTotalView.snp.bottom).offset(27)
//            $0.leading.equalToSuperview()
//        }
//
//        totalView.addSubview(genderTotalStackView)
//        genderTotalStackView.snp.makeConstraints {
//            $0.top.equalTo(genderGuideLbl.snp.bottom).offset(16)
//            $0.leading.trailing.bottom.equalToSuperview()
//        }
    }
    
    internal func bind(reactor: SignUpReactor) {
        reactor.state.compactMap { $0.signUpUserData }
            .asDriver(onErrorJustReturn: Login(.none))
            .drive(onNext: { [weak self] userData in
                guard let self = self else { return }
                                                                
                switch userData.loginType {
                case .apple:
                    self.loginInfoGuideLbl.text = "추후 해당 정보를 기반한 맞춤형 정보를 제공할 예정입니다."
                    
                case .kakao:
                    self.loginInfoGuideLbl.text = "카카오에서 제공된 정보이며, 추후 해당 정보를 기반한 맞춤형 정보를 제공할 예정입니다."
                    
                default:
                    self.loginInfoGuideLbl.text = "추후 해당 정보를 기반한 맞춤형 정보를 제공할 예정입니다."
                }
                                                                         
                self.selectBoxTitleLbl.text = userData.displayAgeRang
                
                for genderType in Login.Gender.allCases {
                    let genderView = self.createGenderView(type: genderType, reactor: reactor)
                    
                    genderView.rx.tap
                        .map { SignUpReactor.Action.setGenderType(genderType) }
                        .bind(to: reactor.action)
                        .disposed(by: self.disposeBag)
                    
                    self.genderTotalStackView.addArrangedSubview(genderView)
                }
                
                // 구현해야함
//                if let gender = user.gender, !gender.isEmpty {
//                    if gender.equals("남성") {
//                        radioMale.isSelected = true
//                    } else if gender.equals("여성") {
//                        radioFemale.isSelected = true
//                    } else {
//                        radioOther.isSelected = true
//                    }
//                    genderSelected = gender
//                }
                
            })
            .disposed(by: self.disposeBag)
        
        
        selectBoxTotalBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.view.endEditing(true)
                
//                let rowVC = NewBottomSheetViewController()
//                rowVC.items = reactor.currentState.quitAccountReasonList?.compactMap { $0.reasonMessage } ?? []
//                rowVC.headerTitleStr = "탈퇴 사유 선택"
//                rowVC.view.frame = GlobalDefine.shared.mainNavi?.view.bounds ?? UIScreen.main.bounds
//                self.addChildViewController(rowVC)
//                self.view.addSubview(rowVC.view)
//                                                                              
//                rowVC.selectedCompletion = { [weak self] index in
//                    guard let self = self else { return }
//                    reactor.selectedReasonIndex = index
//                    self.selectBoxTitleLbl.text = rowVC.items[index]
//                    self.nextBtn.isEnabled = true
//                    self.reasonTotalView.isHidden = false
//                    rowVC.view.removeFromSuperview()
//                    rowVC.removeFromParentViewController()
//                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func createGenderView(type: Login.Gender, reactor: SignUpReactor) -> UIButton {
        let view = UIButton().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
        }
                        
        let genderSelectBtn = Radio().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
        }
        
        reactor.state.compactMap { $0.genderType }
            .asDriver(onErrorJustReturn: .man)
            .drive(onNext: { genderType in
                genderSelectBtn.isSelected = type == genderType
            })
            .disposed(by: self.disposeBag)
                                        
        view.addSubview(genderSelectBtn)
        genderSelectBtn.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        let genderTitleLbl = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = type.value
            $0.textAlignment = .natural
            $0.numberOfLines = 1
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = Colors.contentPrimary.color
            $0.isUserInteractionEnabled = false
        }
        
        view.addSubview(genderTitleLbl)
        genderTitleLbl.snp.makeConstraints {
            $0.leading.equalTo(genderSelectBtn.snp.trailing).offset(8)
            $0.centerY.equalTo(genderSelectBtn.snp.centerY)
            $0.trailing.equalToSuperview()
        }
                                        
        return view
    }
}
